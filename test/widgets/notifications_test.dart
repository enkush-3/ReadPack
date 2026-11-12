import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/notifications/presentation/page/notifications_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers/secure_storage_mock.dart';

Widget createTestNotifications({required BookProvider bookProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<BookProvider>.value(value: bookProvider),
    ],
    child: const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: NotificationsPage(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockSecureStorage();
  });

  group('NotificationsPage Widget Tests', () {
    testWidgets('Renders notifications header and list', (tester) async {
      final provider = BookProvider();
      addTearDown(provider.dispose);
      await tester.runAsync(() => provider.initialized);
      await tester.pumpWidget(createTestNotifications(bookProvider: provider));
      await tester.pumpAndSettle();

      expect(find.text('Мэдэгдэл'), findsOneWidget);
      expect(find.textContaining('Бүгд ('), findsOneWidget);
      expect(find.textContaining('Уншаагүй'), findsOneWidget);
      expect(find.textContaining('Уншсан'), findsOneWidget);
      expect(find.text('Мэдэгдэл байхгүй байна'), findsOneWidget);
      expect(find.text('Шинэ ном нэмэгдлээ'), findsNothing);
    });

    testWidgets('Switching to unread and archived tabs filters items', (
      tester,
    ) async {
      final provider = BookProvider();
      addTearDown(provider.dispose);
      await tester.runAsync(() => provider.initialized);
      await tester.pumpWidget(createTestNotifications(bookProvider: provider));
      await tester.pumpAndSettle();

      final unreadTab = find.textContaining('Уншаагүй');
      expect(unreadTab, findsOneWidget);
      await tester.tap(unreadTab);
      await tester.pumpAndSettle();

      expect(find.text('Уншаагүй мэдэгдэл алга'), findsOneWidget);

      final archivedTab = find.textContaining('Уншсан');
      expect(archivedTab, findsOneWidget);
      await tester.tap(archivedTab);
      await tester.pumpAndSettle();

      expect(find.text('Уншсан мэдэгдэл алга'), findsOneWidget);
    });

    testWidgets('Hides mark all when there are no unread notifications', (
      tester,
    ) async {
      final provider = BookProvider();
      addTearDown(provider.dispose);
      await tester.runAsync(() => provider.initialized);
      await tester.pumpWidget(createTestNotifications(bookProvider: provider));
      await tester.pumpAndSettle();

      expect(find.text('Бүгдийг унших'), findsNothing);
      expect(find.textContaining('Уншаагүй (0)'), findsOneWidget);
    });
  });
}
