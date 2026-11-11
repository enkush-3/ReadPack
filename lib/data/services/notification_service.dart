import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:readpack/data/services/auth_api_service.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

enum NotificationServiceStatus {
  ready,
  scheduled,
  canceled,
  permissionDenied,
  firebaseNotConfigured,
  pushPermissionDenied,
  unauthenticated,
  tokenUnavailable,
  unsupportedPlatform,
  failed,
}

class NotificationServiceResult {
  final NotificationServiceStatus status;
  final String? message;

  const NotificationServiceResult(this.status, {this.message});

  bool get succeeded =>
      status == NotificationServiceStatus.ready ||
      status == NotificationServiceStatus.scheduled ||
      status == NotificationServiceStatus.canceled;
}

class NotificationSetupResult {
  final bool localNotificationsReady;
  final bool pushReady;
  final NotificationServiceStatus localStatus;
  final NotificationServiceStatus pushStatus;

  const NotificationSetupResult({
    required this.localNotificationsReady,
    required this.pushReady,
    required this.localStatus,
    required this.pushStatus,
  });
}

class NotificationService {
  static const int dailyReminderId = 4101;
  static const String _channelId = 'daily_reading_reminders';
  static const String _channelName = 'Reading reminders';

  final FlutterLocalNotificationsPlugin _localNotifications;
  final Future<String> Function() _loadTimezone;
  FirebaseMessaging? _messagingInstance;

  FirebaseMessaging get _messaging =>
      _messagingInstance ??= FirebaseMessaging.instance;

  bool _localReady = false;
  bool _localPermissionGranted = false;
  bool _pushReady = false;
  NotificationServiceStatus _pushStatus =
      NotificationServiceStatus.firebaseNotConfigured;
  timezone.Location? _location;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  AuthApiService? _registeredAuthService;
  String? _registeredUserId;

  NotificationService({
    FlutterLocalNotificationsPlugin? localNotifications,
    FirebaseMessaging? messaging,
    Future<String> Function()? loadTimezone,
  }) : _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _messagingInstance = messaging,
       _loadTimezone = loadTimezone ?? _readSystemTimezone;

  Future<NotificationSetupResult> initialize() async {
    final platformSupported = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!platformSupported) {
      return const NotificationSetupResult(
        localNotificationsReady: false,
        pushReady: false,
        localStatus: NotificationServiceStatus.unsupportedPlatform,
        pushStatus: NotificationServiceStatus.unsupportedPlatform,
      );
    }

    final localStatus = await _initializeLocalNotifications();
    final pushStatus = await _initializeFirebaseMessaging();
    return NotificationSetupResult(
      localNotificationsReady: _localReady && _localPermissionGranted,
      pushReady: _pushReady,
      localStatus: localStatus,
      pushStatus: pushStatus,
    );
  }

  Future<NotificationServiceResult> scheduleDailyReminder({
    required int hour,
    int minute = 0,
    bool enabled = true,
    String languageCode = 'mn',
  }) async {
    if (hour < 0 || hour > 23) {
      throw RangeError.range(hour, 0, 23, 'hour');
    }
    if (minute < 0 || minute > 59) {
      throw RangeError.range(minute, 0, 59, 'minute');
    }

    if (!enabled) return cancelDailyReminder();

    if (!_localReady || !_localPermissionGranted || _location == null) {
      final setup = await initialize();
      if (!setup.localNotificationsReady) {
        return NotificationServiceResult(
          setup.localStatus == NotificationServiceStatus.permissionDenied
              ? NotificationServiceStatus.permissionDenied
              : setup.localStatus,
        );
      }
    }

    final location = _location;
    if (location == null) {
      return const NotificationServiceResult(
        NotificationServiceStatus.failed,
        message: 'The device time zone is unavailable.',
      );
    }

    try {
      final now = timezone.TZDateTime.now(location);
      final scheduledDate = nextDailyOccurrence(
        now: now,
        location: location,
        hour: hour,
        minute: minute,
      );
      final reminder = _localizedReminder(languageCode);
      await _localNotifications.zonedSchedule(
        id: dailyReminderId,
        scheduledDate: scheduledDate,
        title: reminder.$1,
        body: reminder.$2,
        notificationDetails: _reminderDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_reading_reminder',
      );
      return const NotificationServiceResult(
        NotificationServiceStatus.scheduled,
      );
    } catch (error) {
      return NotificationServiceResult(
        NotificationServiceStatus.failed,
        message: 'Could not schedule the reminder: $error',
      );
    }
  }

  Future<NotificationServiceResult> cancelDailyReminder() async {
    try {
      await _localNotifications.cancel(id: dailyReminderId);
      return const NotificationServiceResult(
        NotificationServiceStatus.canceled,
      );
    } catch (error) {
      return NotificationServiceResult(
        NotificationServiceStatus.failed,
        message: 'Could not cancel the reminder: $error',
      );
    }
  }

  Future<NotificationServiceResult> registerPushDevice({
    required AuthApiService authApi,
    required String userId,
    required bool isAuthenticated,
  }) async {
    if (!_pushReady) {
      return NotificationServiceResult(_pushStatus);
    }
    if (!isAuthenticated || userId.trim().isEmpty) {
      return const NotificationServiceResult(
        NotificationServiceStatus.unauthenticated,
      );
    }
    if (!await authApi.hasStoredSession()) {
      return const NotificationServiceResult(
        NotificationServiceStatus.unauthenticated,
      );
    }

    try {
      final previousUserId = _registeredUserId;
      final previousAuthApi = _registeredAuthService;
      if (previousUserId != null &&
          (previousUserId != userId || !identical(previousAuthApi, authApi))) {
        await unregisterPushDevice(
          authApi: previousAuthApi!,
          userId: previousUserId,
        );
      }

      // The backend stores FCM registration tokens for Firebase Admin sends.
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      if (token == null || token.trim().isEmpty) {
        return const NotificationServiceResult(
          NotificationServiceStatus.tokenUnavailable,
        );
      }
      await _registerToken(authApi, userId, token);
      _listenForTokenRefresh(authApi: authApi, userId: userId);
      return const NotificationServiceResult(NotificationServiceStatus.ready);
    } on FirebaseException catch (error) {
      return NotificationServiceResult(
        NotificationServiceStatus.tokenUnavailable,
        message: error.message,
      );
    } catch (error) {
      return NotificationServiceResult(
        NotificationServiceStatus.failed,
        message: 'Could not register this device: $error',
      );
    }
  }

  Future<NotificationServiceResult> unregisterPushDevice({
    required AuthApiService authApi,
    required String userId,
  }) async {
    if (userId.trim().isEmpty || !await authApi.hasStoredSession()) {
      return const NotificationServiceResult(
        NotificationServiceStatus.unauthenticated,
      );
    }

    try {
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      if (token == null || token.trim().isEmpty) {
        return const NotificationServiceResult(
          NotificationServiceStatus.tokenUnavailable,
        );
      }
      await authApi.requestAuthorized(
        'DELETE',
        '/users/${Uri.encodeComponent(userId)}/devices',
        body: {'token': token},
      );
      if (_registeredUserId == userId &&
          identical(_registeredAuthService, authApi)) {
        await stopPushRegistration();
      }
      return const NotificationServiceResult(
        NotificationServiceStatus.canceled,
      );
    } on FirebaseException catch (error) {
      return NotificationServiceResult(
        NotificationServiceStatus.tokenUnavailable,
        message: error.message,
      );
    } catch (error) {
      return NotificationServiceResult(
        NotificationServiceStatus.failed,
        message: 'Could not unregister this device: $error',
      );
    }
  }

  Future<void> stopPushRegistration() async {
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
    _registeredAuthService = null;
    _registeredUserId = null;
  }

  Future<void> dispose() async {
    await stopPushRegistration();
    await _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = null;
  }

  static timezone.TZDateTime nextDailyOccurrence({
    required timezone.TZDateTime now,
    required timezone.Location location,
    required int hour,
    required int minute,
  }) {
    if (hour < 0 || hour > 23) {
      throw RangeError.range(hour, 0, 23, 'hour');
    }
    if (minute < 0 || minute > 59) {
      throw RangeError.range(minute, 0, 59, 'minute');
    }

    var occurrence = timezone.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!occurrence.isAfter(now)) {
      occurrence = timezone.TZDateTime(
        location,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }
    return occurrence;
  }

  Future<NotificationServiceStatus> _initializeLocalNotifications() async {
    if (_localReady && _localPermissionGranted && _location != null) {
      return NotificationServiceStatus.ready;
    }

    try {
      timezone_data.initializeTimeZones();
      final timezoneId = await _loadTimezone();
      _location = timezone.getLocation(timezoneId);

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      final initialized = await _localNotifications.initialize(
        settings: initializationSettings,
      );
      if (initialized == false) return NotificationServiceStatus.failed;
      _localReady = true;

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        _localPermissionGranted =
            await androidPlugin.requestNotificationsPermission() ?? true;
      } else {
        final iosPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        _localPermissionGranted =
            await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      return _localPermissionGranted
          ? NotificationServiceStatus.ready
          : NotificationServiceStatus.permissionDenied;
    } catch (_) {
      _localReady = false;
      _localPermissionGranted = false;
      return NotificationServiceStatus.failed;
    }
  }

  Future<NotificationServiceStatus> _initializeFirebaseMessaging() async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final permission = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final authorized =
          permission.authorizationStatus == AuthorizationStatus.authorized ||
          permission.authorizationStatus == AuthorizationStatus.provisional;
      if (!authorized) {
        _pushReady = false;
        _pushStatus = NotificationServiceStatus.pushPermissionDenied;
        return _pushStatus;
      }
      _pushReady = true;
      _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen(
        _showForegroundMessage,
      );
      _pushStatus = NotificationServiceStatus.ready;
      return _pushStatus;
    } on FirebaseException {
      _pushReady = false;
      _pushStatus = NotificationServiceStatus.firebaseNotConfigured;
      return _pushStatus;
    } catch (_) {
      _pushReady = false;
      _pushStatus = NotificationServiceStatus.firebaseNotConfigured;
      return _pushStatus;
    }
  }

  void _listenForTokenRefresh({
    required AuthApiService authApi,
    required String userId,
  }) {
    if (identical(_registeredAuthService, authApi) &&
        _registeredUserId == userId &&
        _tokenSubscription != null) {
      return;
    }
    _tokenSubscription?.cancel();
    _registeredAuthService = authApi;
    _registeredUserId = userId;
    // This stream emits refreshed FCM registration tokens required by Admin
    // Messaging. `onRegistered` emits a Firebase Installation ID instead.
    // ignore: deprecated_member_use
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) async {
      if (!await authApi.hasStoredSession()) return;
      try {
        await _registerToken(authApi, userId, token);
      } catch (_) {
        // A later token refresh or app launch retries registration.
      }
    });
  }

  Future<void> _registerToken(
    AuthApiService authApi,
    String userId,
    String token,
  ) async {
    await authApi.requestAuthorized(
      'POST',
      '/users/${Uri.encodeComponent(userId)}/devices',
      body: {
        'token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      },
    );
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null || !_localReady || !_localPermissionGranted) {
      return;
    }
    try {
      final messageId = message.messageId?.hashCode;
      final notificationId = messageId == null
          ? DateTime.now().millisecondsSinceEpoch % 2147483647
          : messageId.abs() % 2147483647;
      await _localNotifications.show(
        id: notificationId,
        title: notification.title,
        body: notification.body,
        notificationDetails: _reminderDetails(),
      );
    } catch (_) {
      // Foreground delivery remains best-effort when local notification access
      // is unavailable.
    }
  }

  NotificationDetails _reminderDetails() => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Daily reminders to continue reading.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );

  (String, String) _localizedReminder(String languageCode) =>
      languageCode.toLowerCase().startsWith('en')
      ? ('Time to read', 'Take a few minutes for a good book today.')
      : ('Унших цаг боллоо', 'Өнөөдөр дуртай номдоо хэдэн минут зориулаарай.');

  static Future<String> _readSystemTimezone() async =>
      (await FlutterTimezone.getLocalTimezone()).identifier;
}
