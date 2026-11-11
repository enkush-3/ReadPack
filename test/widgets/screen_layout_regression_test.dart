import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/home/presentation/page/home.dart';
import 'package:readpack/features/library/presentation/page/saved_page.dart';
import 'package:readpack/features/search/presentation/page/search.dart';
import 'package:readpack/helper/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers/secure_storage_mock.dart';

Widget _testApp({
  required Widget child,
  required BookProvider bookProvider,
  Locale locale = const Locale('mn'),
  double textScale = 1,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: ThemeProvider()),
      ChangeNotifierProvider<BookProvider>.value(value: bookProvider),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: child,
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

  Future<void> setCompactViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Search filters and results fit a 360dp screen at 2x text', (
    tester,
  ) async {
    await setCompactViewport(tester);
    final provider = BookProvider();
    addTearDown(provider.dispose);
    await tester.runAsync(() => provider.initialized);

    await tester.pumpWidget(
      _testApp(
        child: const SearchPage(),
        bookProvider: provider,
        locale: const Locale('en'),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Browse by Reading Mood'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home feed and continue card fit a 360dp screen at 2x text', (
    tester,
  ) async {
    await setCompactViewport(tester);
    final provider = BookProvider();
    addTearDown(provider.dispose);
    await tester.runAsync(() => provider.initialized);
    provider.loginWithEmail('reader@example.com', 'Test Reader');
    provider.updateReadingProgress(provider.books.first.id, 20, 0.35, 1);

    await tester.pumpWidget(
      _testApp(
        child: const HomePage(),
        bookProvider: provider,
        locale: const Locale('en'),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Library quote filters and actions wrap without overflow', (
    tester,
  ) async {
    await setCompactViewport(tester);
    final provider = BookProvider();
    addTearDown(provider.dispose);
    await tester.runAsync(() => provider.initialized);

    await tester.pumpWidget(
      _testApp(
        child: const SavedPage(initialSegment: 3),
        bookProvider: provider,
        locale: const Locale('en'),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });


}
