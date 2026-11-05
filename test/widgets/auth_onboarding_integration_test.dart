import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/auth/presentation/page/auth.dart';
import 'package:readpack/helper/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Map<String, dynamic> _mnMap;
late Map<String, dynamic> _enMap;

class TestAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const TestAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    final l10n = AppLocalizations(locale);
    l10n.sentences = locale.languageCode == 'en' ? _enMap : _mnMap;
    return SynchronousFuture<AppLocalizations>(l10n);
  }

  @override
  bool shouldReload(TestAppLocalizationsDelegate old) => false;
}

Widget createAuthTestWidget({
  required BookProvider bookProvider,
  Locale locale = const Locale('mn'),
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: ThemeProvider()),
      ChangeNotifierProvider<BookProvider>.value(value: bookProvider),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('mn'), Locale('en')],
      localizationsDelegates: const [
        TestAppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        Routes.appshell: (_) => const Scaffold(body: Text('AppShellScreen')),
        Routes.onboarding: (_) => const Scaffold(body: Text('OnboardingScreen')),
      },
      home: const AuthPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final mnStr = await rootBundle.loadString('assets/locales/mn.json');
    final enStr = await rootBundle.loadString('assets/locales/en.json');
    _mnMap = json.decode(mnStr) as Map<String, dynamic>;
    _enMap = json.decode(enStr) as Map<String, dynamic>;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthPage and Onboarding Entrypoint Tests', () {
    testWidgets('AuthPage top nav has goal personalization button that navigates to Onboarding',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));

      await tester.pumpWidget(createAuthTestWidget(bookProvider: bookProvider));
      await tester.pumpAndSettle();

      final goalButton = find.byIcon(Icons.tune_rounded);
      expect(goalButton, findsOneWidget);

      await tester.tap(goalButton);
      await tester.pumpAndSettle();

      expect(find.text('OnboardingScreen'), findsOneWidget);
    });

    testWidgets('AuthPage skip button logs in as guest and navigates to AppShell',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));

      await tester.pumpWidget(createAuthTestWidget(bookProvider: bookProvider));
      await tester.pumpAndSettle();

      final skipButton = find.text('Алгасах');
      expect(skipButton, findsOneWidget);

      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(find.text('AppShellScreen'), findsOneWidget);
      expect(bookProvider.userProfile.isGuest, isTrue);
    });

    testWidgets('AuthPage renders cleanly on narrow 360px mobile screen without overflow even at 2.0x text scale',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: createAuthTestWidget(bookProvider: bookProvider),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });

    testWidgets('AuthPage Google button authenticates user (isGuest == false) instead of guest mode',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      bookProvider.loginAsGuest();
      expect(bookProvider.userProfile.isGuest, isTrue);

      await tester.pumpWidget(createAuthTestWidget(bookProvider: bookProvider));
      await tester.pumpAndSettle();

      final googleBtn = find.text('Google');
      expect(googleBtn, findsOneWidget);
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      expect(bookProvider.userProfile.isGuest, isFalse);
    });
  });
}
