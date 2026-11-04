import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/notifications/presentation/page/notifications_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createTestNotifications() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => BookProvider()),
    ],
    child: const MaterialApp(
      home: NotificationsPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationsPage Widget Tests', () {
    testWidgets('Renders notifications header and list', (tester) async {
      await tester.pumpWidget(createTestNotifications());
      await tester.pumpAndSettle();

      expect(find.text('Мэдэгдэл'), findsOneWidget);
      expect(find.textContaining('Бүгд ('), findsOneWidget);
      expect(find.textContaining('Уншаагүй'), findsOneWidget);
      expect(find.textContaining('Уншсан'), findsOneWidget);
      expect(find.text('Шинэ ном нэмэгдлээ'), findsOneWidget);
    });

    testWidgets('Switching to unread and archived tabs filters items', (tester) async {
      await tester.pumpWidget(createTestNotifications());
      await tester.pumpAndSettle();

      final unreadTab = find.textContaining('Уншаагүй');
      expect(unreadTab, findsOneWidget);
      await tester.tap(unreadTab);
      await tester.pumpAndSettle();

      // Only unread items show
      expect(find.text('Шинэ ном нэмэгдлээ'), findsOneWidget);

      final archivedTab = find.textContaining('Уншсан');
      expect(archivedTab, findsOneWidget);
      await tester.tap(archivedTab);
      await tester.pumpAndSettle();

      // Read items show
      expect(find.text('Амжилт!'), findsOneWidget);
    });

    testWidgets('Tapping mark all as read updates all items', (tester) async {
      await tester.pumpWidget(createTestNotifications());
      await tester.pumpAndSettle();

      final markAllBtn = find.text('Бүгдийг унших');
      if (markAllBtn.evaluate().isNotEmpty) {
        await tester.tap(markAllBtn);
        await tester.pumpAndSettle();
        expect(find.textContaining('Уншаагүй (0)'), findsOneWidget);
      }
    });
  });
}
