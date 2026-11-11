import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/data/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

void main() {
  setUpAll(timezone_data.initializeTimeZones);

  group('NotificationService.nextDailyOccurrence', () {
    test('uses today when the reminder time is still ahead', () {
      final location = timezone.getLocation('Etc/UTC');
      final now = timezone.TZDateTime(location, 2026, 11, 12, 8, 15);

      final next = NotificationService.nextDailyOccurrence(
        now: now,
        location: location,
        hour: 9,
        minute: 30,
      );

      expect(next, timezone.TZDateTime(location, 2026, 11, 12, 9, 30));
    });

    test('moves to tomorrow when reminder time has passed', () {
      final location = timezone.getLocation('Etc/UTC');
      final now = timezone.TZDateTime(location, 2026, 11, 12, 21, 0);

      final next = NotificationService.nextDailyOccurrence(
        now: now,
        location: location,
        hour: 20,
        minute: 0,
      );

      expect(next, timezone.TZDateTime(location, 2026, 11, 13, 20, 0));
    });

    test('preserves the requested wall-clock time across daylight saving', () {
      final location = timezone.getLocation('America/New_York');
      final now = timezone.TZDateTime(location, 2026, 3, 8, 8, 0);

      final next = NotificationService.nextDailyOccurrence(
        now: now,
        location: location,
        hour: 9,
        minute: 0,
      );

      expect(next.hour, 9);
      expect(next.minute, 0);
      expect(next.location.name, 'America/New_York');
    });

    test('rejects invalid clock values', () {
      final location = timezone.getLocation('Etc/UTC');
      final now = timezone.TZDateTime(location, 2026, 11, 12, 8, 0);

      expect(
        () => NotificationService.nextDailyOccurrence(
          now: now,
          location: location,
          hour: 24,
          minute: 0,
        ),
        throwsRangeError,
      );
    });
  });
}
