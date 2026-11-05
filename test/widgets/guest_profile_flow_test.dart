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
      routes: {
        Routes.auth: (_) => const Scaffold(body: Text('AuthScreen')),
      },
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
  });

  group('Guest Mode & Profile Decoupling Tests', () {
    testWidgets('Guest Profile hides personal synced cards and shows ProfileGuestCard',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
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
    });

    testWidgets('Authenticated Profile renders all personal user cards and hides ProfileGuestCard',
        (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      bookProvider.loginWithEmail('user@test.com', 'Test User');

      await tester.pumpWidget(createProfileTestWidget(bookProvider));
      await tester.pumpAndSettle();

      // Guest card must not be present
      expect(find.byType(ProfileGuestCard), findsNothing);

      // Personal cards must be present
      expect(find.byType(ProfileXpCard), findsOneWidget);
      expect(find.byType(ProfileLeagueCard), findsOneWidget);
      expect(find.byType(ProfileChallengeCard), findsOneWidget);
      expect(find.byType(ProfileHabitsCard), findsOneWidget);
      expect(find.byType(ProfileAchievementsCard), findsOneWidget);
    });

    testWidgets('Tapping login on ProfileGuestCard navigates to AuthScreen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      bookProvider.loginAsGuest();

      await tester.pumpWidget(createProfileTestWidget(bookProvider));
      await tester.pumpAndSettle();

      final loginBtn = find.text('Нэвтрэх / Бүртгүүлэх');
      expect(loginBtn, findsOneWidget);

      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text('AuthScreen'), findsOneWidget);
    });
  });
}
