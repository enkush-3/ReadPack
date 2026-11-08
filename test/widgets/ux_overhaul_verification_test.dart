import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/app_shell.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/auth/presentation/page/verification_page.dart';
import 'package:readpack/features/home/widgets/continue_reading_card.dart';
import 'package:readpack/features/settings/presentation/page/settings_page.dart';
import 'package:readpack/helper/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Map<String, dynamic> _mnMap;
late Map<String, dynamic> _enMap;

class TestAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const TestAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['mn', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    final l10n = AppLocalizations(locale);
    l10n.sentences = locale.languageCode == 'en' ? _enMap : _mnMap;
    return SynchronousFuture<AppLocalizations>(l10n);
  }

  @override
  bool shouldReload(TestAppLocalizationsDelegate old) => false;
}

Widget createTestWidget({
  required Widget child,
  BookProvider? bookProvider,
  Locale locale = const Locale('mn'),
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: ThemeProvider()),
      ChangeNotifierProvider<BookProvider>.value(
        value: bookProvider ?? BookProvider(),
      ),
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
        Routes.onboarding: (_) => const Scaffold(body: Text('Onboarding')),
        Routes.auth: (_) => const Scaffold(body: Text('Auth')),
      },
      home: child,
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

  group('UX Overhaul and Verification Tests', () {
    testWidgets('VerificationPage renders 6 OTP boxes and timer',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VerificationPage(
            arguments: {
              'purpose': 'signup',
              'target': 'reader@test.com',
              'name': 'Test Reader',
              'isPhone': false,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Баталгаажуулах код'), findsOneWidget);
      expect(find.textContaining('reader@test.com'), findsOneWidget);
      expect(find.textContaining('Дахин код авах'), findsOneWidget);
      expect(find.text('Баталгаажуулах'), findsOneWidget);
    });

    testWidgets(
        'AppShell hides ContinueReadingCard for guest and shows for logged-in user with reading progress',
        (tester) async {
      final guestProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      guestProvider.loginAsGuest();

      // Test Guest: ContinueReadingCard must NOT be shown
      await tester.pumpWidget(
        createTestWidget(
          child: const AppShell(),
          bookProvider: guestProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ContinueReadingCard), findsNothing);

      // Test Logged in user with reading progress:
      final userProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      userProvider.loginWithEmail('user@test.com', 'Test User');
      // Simulate reading progress on first book
      userProvider.updateReadingProgress(
        userProvider.books.first.id,
        20,
        0.35,
        1,
      );

      await tester.pumpWidget(
        createTestWidget(
          child: const AppShell(),
          bookProvider: userProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ContinueReadingCard), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap close button and verify it dismisses the card
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(ContinueReadingCard), findsNothing);
    });

    testWidgets(
        'SettingsPage renders merged profile card with edit icon and bottom logout button, without downloaded books tile',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final userProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      userProvider.loginWithEmail('user@test.com', 'Test User');

      await tester.pumpWidget(
        createTestWidget(
          child: const SettingsPage(),
          bookProvider: userProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Merged card details
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Бүртгэлтэй'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsAtLeastNWidgets(1));
      expect(find.text('Мэдээлэл засах'), findsNothing);

      // Downloaded books tile was removed per user request
      expect(find.text('Татсан номууд'), findsNothing);

      // Logout button at the bottom
      expect(find.text('Гарах (Logout)'), findsOneWidget);
    });

    testWidgets(
        'SettingsPage guest mode shows login button and hides 2026 challenge',
        (tester) async {
      final guestProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      guestProvider.loginAsGuest();

      await tester.pumpWidget(
        createTestWidget(
          child: const SettingsPage(),
          bookProvider: guestProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Зочин уншигч'), findsOneWidget);
      expect(find.text('Нэвтрэх / Бүртгүүлэх'), findsOneWidget);
      expect(find.text('2026'), findsNothing);
      expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);
    });
  });
}
