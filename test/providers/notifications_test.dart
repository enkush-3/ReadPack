import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/helpers/book_provider_persistence.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Notifications Provider Tests', () {
    test('starts with no fabricated notifications', () async {
      final provider = BookProvider();
      await provider.initialized;

      expect(provider.notifications, isEmpty);
      expect(provider.unreadNotificationsCount, 0);
    });

    test(
      'markNotificationAsRead marks notification and decrements unread count',
      () async {
        _seedNotifications([_notification('unread-notification')]);
        final provider = BookProvider();
        await provider.initialized;

        final unreadNotif = provider.notifications.firstWhere((n) => !n.isRead);
        final initialUnread = provider.unreadNotificationsCount;

        provider.markNotificationAsRead(unreadNotif.id);

        final updated = provider.notifications.firstWhere(
          (n) => n.id == unreadNotif.id,
        );
        expect(updated.isRead, true);
        expect(provider.unreadNotificationsCount, initialUnread - 1);
      },
    );

    test(
      'markAllNotificationsAsRead marks all notifications as read',
      () async {
        _seedNotifications([
          _notification('unread-one'),
          _notification('unread-two'),
        ]);
        final provider = BookProvider();
        await provider.initialized;

        expect(provider.unreadNotificationsCount, greaterThan(0));
        provider.markAllNotificationsAsRead();
        expect(provider.unreadNotificationsCount, 0);
        expect(provider.notifications.every((n) => n.isRead), true);
      },
    );

    test('deleteNotification removes notification from list', () async {
      _seedNotifications([_notification('notification-to-delete')]);
      final provider = BookProvider();
      await provider.initialized;

      final initialCount = provider.notifications.length;
      final targetId = provider.notifications.first.id;

      provider.deleteNotification(targetId);
      expect(provider.notifications.length, initialCount - 1);
      expect(provider.notifications.any((n) => n.id == targetId), false);
    });
  });
}

void _seedNotifications(List<NotificationItem> notifications) {
  SharedPreferences.setMockInitialValues({
    BookProviderPersistence.keyNotifications: notifications
        .map((notification) => jsonEncode(notification.toJson()))
        .toList(),
  });
}

NotificationItem _notification(String id) => NotificationItem(
  id: id,
  title: 'Test notification',
  message: 'Notification test message.',
  time: 'Just now',
  type: 'system',
  createdAt: DateTime.utc(2026, 1, 1),
);
