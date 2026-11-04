import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Notifications Provider Tests', () {
    test('Initializes with default notifications and correct unread count', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.notifications.isNotEmpty, true);
      expect(provider.unreadNotificationsCount, greaterThan(0));
    });

    test('markNotificationAsRead marks notification and decrements unread count', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final unreadNotif = provider.notifications.firstWhere((n) => !n.isRead);
      final initialUnread = provider.unreadNotificationsCount;

      provider.markNotificationAsRead(unreadNotif.id);

      final updated = provider.notifications.firstWhere((n) => n.id == unreadNotif.id);
      expect(updated.isRead, true);
      expect(provider.unreadNotificationsCount, initialUnread - 1);
    });

    test('markAllNotificationsAsRead marks all notifications as read', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.unreadNotificationsCount, greaterThan(0));
      provider.markAllNotificationsAsRead();
      expect(provider.unreadNotificationsCount, 0);
      expect(provider.notifications.every((n) => n.isRead), true);
    });

    test('deleteNotification removes notification from list', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final initialCount = provider.notifications.length;
      final targetId = provider.notifications.first.id;

      provider.deleteNotification(targetId);
      expect(provider.notifications.length, initialCount - 1);
      expect(provider.notifications.any((n) => n.id == targetId), false);
    });
  });
}
