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
import 'package:readpack/features/profile/widgets/profile_achievements_card.dart';
import 'package:readpack/features/profile/widgets/profile_challenge_card.dart';
import 'package:readpack/features/profile/widgets/profile_guest_card.dart';
import 'package:readpack/features/profile/widgets/profile_habits_card.dart';
import 'package:readpack/features/profile/widgets/profile_league_card.dart';
import 'package:readpack/features/profile/widgets/profile_xp_card.dart';
import 'package:readpack/helper/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers/secure_storage_mock.dart';

late Map<String, dynamic> _mnMap;

class _LocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    final l10n = AppLocalizations(locale);
    l10n.sentences = _mnMap;
    return SynchronousFuture<AppLocalizations>(l10n);
  }

  @override
  bool shouldReload(_LocalizationsDelegate old) => false;
}

Widget createProfileTestWidget(BookProvider bookProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: ThemeProvider()),
      ChangeNotifierProvider.value(value: bookProvider),
    ],
    child: MaterialApp(
      locale: const Locale('mn'),
      localizationsDelegates: const [
        _LocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {Routes.auth: (_) => const Scaffold(body: Text('AuthScreen'))},
      home: const ProfilePage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final mnStr = await rootBundle.loadString('assets/locales/mn.json');
    _mnMap = json.decode(mnStr) as Map<String, dynamic>;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockSecureStorage();
  });

  group('Guest Mode & Profile Decoupling Tests', () {
    testWidgets(
      'Guest Profile hides personal synced cards and shows ProfileGuestCard',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bookProvider = BookProvider();
        addTearDown(bookProvider.dispose);
        await tester.runAsync(() => bookProvider.initialized);
        bookProvider.loginAsGuest();

        await tester.pumpWidget(createProfileTestWidget(bookProvider));
        await tester.pumpAndSettle();

        // Guest card must be displayed
        expect(find.byType(ProfileGuestCard), findsOneWidget);
        expect(find.text('Нэвтрэх / Бүртгүүлэх'), findsOneWidget);

        // Personal synced user cards MUST NOT be displayed for guest
        expect(find.byType(ProfileXpCard), findsNothing);
        expect(find.byType(ProfileLeagueCard), findsNothing);
        expect(find.byType(ProfileChallengeCard), findsNothing);
        expect(find.byType(ProfileHabitsCard), findsNothing);
        expect(find.byType(ProfileAchievementsCard), findsNothing);

        // Fake guest email and Edit Profile pencil button MUST NOT be displayed for guest, while Settings icon is available
        expect(find.text('guest@readpack.app'), findsNothing);
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'Authenticated Profile renders all personal user cards and hides ProfileGuestCard',
      (tester) async {
        tester.view.physicalSize = const Size(800, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bookProvider = BookProvider();
        addTearDown(bookProvider.dispose);
        await tester.runAsync(() => bookProvider.initialized);
        bookProvider.loginWithEmail('user@test.com', 'Test User');

        await tester.pumpWidget(createProfileTestWidget(bookProvider));
        await tester.pumpAndSettle();

        // Guest card must not be present
        expect(find.byType(ProfileGuestCard), findsNothing);

        // Personal cards and Settings button must be present
        expect(find.byType(ProfileXpCard), findsOneWidget);
        expect(find.byType(ProfileLeagueCard), findsOneWidget);
        expect(find.byType(ProfileHabitsCard), findsOneWidget);
        expect(find.byType(ProfileAchievementsCard), findsOneWidget);
        expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      },
    );

    testWidgets('Tapping login on ProfileGuestCard navigates to AuthScreen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      addTearDown(bookProvider.dispose);
      await tester.runAsync(() => bookProvider.initialized);
      bookProvider.loginAsGuest();

      await tester.pumpWidget(createProfileTestWidget(bookProvider));
      await tester.pumpAndSettle();

      final loginBtn = find.text('Нэвтрэх / Бүртгүүлэх');
      expect(loginBtn, findsOneWidget);

      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text('AuthScreen'), findsOneWidget);
    });

    testWidgets(
      'ProfilePage renders without overflow on 360px screen at 2.0x text scale',
      (tester) async {
        tester.view.physicalSize = const Size(360, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final bookProvider = BookProvider();
        addTearDown(bookProvider.dispose);
        await tester.runAsync(() => bookProvider.initialized);
        bookProvider.loginAsGuest();

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: createProfileTestWidget(bookProvider),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
