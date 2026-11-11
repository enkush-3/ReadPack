import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/app_shell.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers/secure_storage_mock.dart';

Widget createTestAppShell({
  int initialIndex = 0,
  required BookProvider bookProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<BookProvider>.value(value: bookProvider),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: AppShell(initialIndex: initialIndex),
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

  group('AppShell 4-Tab Navigation (No Crash Guarantee)', () {
    testWidgets('Renders Home tab initially without crash', (tester) async {
      final provider = BookProvider();
      addTearDown(provider.dispose);
      await tester.runAsync(() => provider.initialized);
      await tester.pumpWidget(createTestAppShell(bookProvider: provider));
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.explore_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('Tapping all 4 bottom tabs switches pages without RangeError', (
      tester,
    ) async {
      final provider = BookProvider();
      addTearDown(provider.dispose);
      await tester.runAsync(() => provider.initialized);
      await tester.pumpWidget(createTestAppShell(bookProvider: provider));
      await tester.pumpAndSettle();

      // Tap Tab 1: Search
      await tester.tap(find.byIcon(Icons.explore_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search_rounded), findsWidgets);

      // Tap Tab 2: Saved / Library (Used to crash with RangeError: 2 not in 0..1)
      await tester.tap(find.byIcon(Icons.bookmark_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Миний Сан'), findsOneWidget);
      expect(find.text('Уншиж буй'), findsOneWidget);
      expect(find.text('Ишлэлүүд'), findsOneWidget);
      expect(find.text('Хадгалсан'), findsWidgets);

      // Tap Tab 3: Profile (Used to crash with RangeError: 3 not in 0..1)
      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Тавтай морилно уу!'), findsOneWidget);

      // Tap Tab 0: Back to Home
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsOneWidget);
    });
  });
}
