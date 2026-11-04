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
import 'package:readpack/features/onboarding/presentation/page/onboarding_page.dart';
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

Widget createOnboardingWidget({
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
        Routes.appshell: (_) => const Scaffold(body: Text('AppShell')),
      },
      home: const Scaffold(body: OnboardingPage()),
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

  group('Onboarding Flow Tests', () {
    testWidgets('Renders Step 1 with Reading Goals and can navigate to Celebration',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      final initialXp = bookProvider.userProfile.xp;

      await tester.pumpWidget(createOnboardingWidget(bookProvider: bookProvider));
      await tester.pumpAndSettle();

      // Step 1: Goals
      expect(find.text('Алхам 1/3'), findsOneWidget);
      expect(find.text('Таны унших гол зорилго юу вэ?'), findsOneWidget);
      expect(find.text('Хувь хүний хөгжил'), findsWidgets);
      expect(find.text('Карьер & Бизнес'), findsOneWidget);

      // Tap next to Step 2
      final nextButton = find.text('Дараах');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 2: Genres
      expect(find.text('Алхам 2/3'), findsOneWidget);
      expect(find.text('Дуртай номын төрлүүдээ сонгоно уу'), findsOneWidget);

      // Select extra genre
      final historyChip = find.text('Түүх');
      expect(historyChip, findsOneWidget);
      await tester.tap(historyChip);
      await tester.pumpAndSettle();

      // Tap next to Step 3
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 3: Targets
      expect(find.text('Алхам 3/3'), findsOneWidget);
      expect(find.text('Өдөрт хэдэн минут унших зорилготой вэ?'), findsOneWidget);
      expect(find.text('2026 онд хэдэн ном унших вэ?'), findsOneWidget);

      // Tap next to Step 4 (Celebration)
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 4: Celebration
      expect(find.text('Бүх зүйл бэлэн боллоо!'), findsOneWidget);
      expect(find.text('+100 XP Бонус нэмэгдлээ!'), findsOneWidget);
      expect(find.text('Уншиж эхлэх'), findsOneWidget);

      // Tap start reading
      await tester.tap(find.text('Уншиж эхлэх'));
      await tester.pumpAndSettle();

      // XP increased by +100
      expect(bookProvider.userProfile.xp, initialXp + 100);
      expect(bookProvider.userProfile.onboardingCompleted, isTrue);
      expect(bookProvider.userProfile.favoriteGenres.contains('Түүх'), isTrue);
    });

    testWidgets('Skip button completes onboarding immediately', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      final initialXp = bookProvider.userProfile.xp;

      await tester.pumpWidget(createOnboardingWidget(bookProvider: bookProvider));
      await tester.pumpAndSettle();

      final skipButton = find.text('Алгасах');
      expect(skipButton, findsOneWidget);
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(bookProvider.userProfile.onboardingCompleted, isTrue);
      expect(bookProvider.userProfile.xp, initialXp + 100);
    });

    testWidgets('Renders onboarding correctly in English', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));

      await tester.pumpWidget(createOnboardingWidget(
        bookProvider: bookProvider,
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Step 1/3'), findsOneWidget);
      expect(find.text('What is your main reading goal?'), findsOneWidget);
      expect(find.text('Personal Growth'), findsWidgets);
      expect(find.text('Career & Business'), findsOneWidget);

      final nextButton = find.text('Next');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('Step 2/3'), findsOneWidget);
      expect(find.text('Select your favorite genres'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('Step 3/3'), findsOneWidget);
      expect(find.text('Daily reading target'), findsOneWidget);
      expect(find.text('How many books in 2026?'), findsOneWidget);

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('All set! Your profile is ready'), findsOneWidget);
      expect(find.text('+100 XP Bonus awarded!'), findsOneWidget);
      expect(find.text('Start Reading'), findsOneWidget);

      await tester.tap(find.text('Start Reading'));
      await tester.pumpAndSettle();

      expect(bookProvider.userProfile.onboardingCompleted, isTrue);
      expect(bookProvider.userProfile.favoriteGenres.contains('History'), isTrue);
    });
  });
}
