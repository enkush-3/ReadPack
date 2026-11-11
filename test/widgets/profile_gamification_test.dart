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
import 'package:readpack/features/profile/presentation/page/profile_page.dart';
import 'package:readpack/helper/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers/secure_storage_mock.dart';

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

Widget createProfileTestWidget({required BookProvider bookProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: ThemeProvider()),
      ChangeNotifierProvider<BookProvider>.value(value: bookProvider),
    ],
    child: MaterialApp(
      locale: const Locale('mn'),
      supportedLocales: const [Locale('mn'), Locale('en')],
      localizationsDelegates: const [
        TestAppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        Routes.onboarding: (_) =>
            const Scaffold(body: Text('OnboardingScreen')),
        Routes.auth: (_) => const Scaffold(body: Text('AuthScreen')),
        Routes.settings: (_) => const Scaffold(body: Text('SettingsScreen')),
      },
      home: const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Scaffold(body: ProfilePage()),
      ),
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
    mockSecureStorage();
  });

  group('Profile Gamification & Habits Tests', () {
    testWidgets(
      'ProfilePage renders XP level, Weekly League, and Reading Habits',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bookProvider = BookProvider();
        addTearDown(bookProvider.dispose);
        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 100)),
        );
        bookProvider.loginWithEmail('reader@test.com', 'Reader');

        await tester.pumpWidget(
          createProfileTestWidget(bookProvider: bookProvider),
        );
        await tester.pumpAndSettle();

        // Check XP & Level progression card
        expect(find.text('Түвшин ба Цол'), findsOneWidget);
        expect(
          find.text('${bookProvider.userProfile.xp} XP'),
          findsAtLeastNWidgets(1),
        );

        // Check Weekly League & Leaderboard
      expect(find.text('Сарын Лидерборд'), findsOneWidget);
        expect(find.textContaining('Сарын Лидерборд'), findsOneWidget);

        // Check Reading Habit insights & heat-map
        expect(find.text('Уншлагын цагийн хуваарь'), findsOneWidget);
        expect(find.textContaining('20:00 - 22:30'), findsOneWidget);

        // Check Settings button navigates to Settings
        final settingsBtn = find.byIcon(Icons.settings_outlined);
        expect(settingsBtn, findsOneWidget);
        await tester.tap(settingsBtn);
        await tester.pumpAndSettle();

        // Navigated to settings
        expect(find.text('SettingsScreen'), findsOneWidget);
      },
    );
  });
}
