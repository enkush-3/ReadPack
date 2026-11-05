import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/data/book_repository.dart';
import 'package:readpack/features/details/presentation/page/book_detail.dart';
import 'package:readpack/features/home/presentation/page/home.dart';
import 'package:readpack/features/home/widgets/header.dart';
import 'package:readpack/features/profile/presentation/page/profile_page.dart';
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

Widget createLocalizedTestWidget({
  required Widget child,
  Locale locale = const Locale('mn'),
  BookProvider? bookProvider,
  ThemeProvider? themeProvider,
}) {
  final tp = themeProvider ?? ThemeProvider();
  final bp = bookProvider ?? BookProvider();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: tp),
      ChangeNotifierProvider<BookProvider>.value(value: bp),
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
      home: Scaffold(body: child),
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

  group('Deep Verification of Features and Localization', () {
    testWidgets('ProfilePage renders 2026 Reading Challenge card and achievements',
        (tester) async {
      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));

      await tester.pumpWidget(createLocalizedTestWidget(
        child: const ProfilePage(),
        bookProvider: bookProvider,
      ));
      await tester.pumpAndSettle();

      // Check reading challenge
      expect(find.text('2026'), findsWidgets);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);

      // Check achievements
      expect(find.text('Уншлагын амжилтууд'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    });

    testWidgets('ProfilePage displays localized guest user name in English and Mongolian',
        (tester) async {
      final guestProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      guestProvider.loginAsGuest();
      final themeProvider = ThemeProvider();

      // Test Mongolian
      await tester.pumpWidget(createLocalizedTestWidget(
        child: const ProfilePage(),
        locale: const Locale('mn'),
        bookProvider: guestProvider,
        themeProvider: themeProvider,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Зочин уншигч'), findsOneWidget);

      // Switch to English
      themeProvider.setLocale(const Locale('en'));
      await tester.pumpWidget(createLocalizedTestWidget(
        child: const ProfilePage(),
        locale: const Locale('en'),
        bookProvider: guestProvider,
        themeProvider: themeProvider,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Guest Reader'), findsOneWidget);
    });

    testWidgets('HomeHeader displays streak flame badge and opens sheet with 7 days',
        (tester) async {
      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));

      await tester.pumpWidget(createLocalizedTestWidget(
        child: HomeHeader(userName: bookProvider.userProfile.name),
        bookProvider: bookProvider,
      ));
      await tester.pumpAndSettle();

      // Find streak flame button and tap it
      final flameFinder = find.text('🔥');
      expect(flameFinder, findsOneWidget);
      await tester.tap(flameFinder);
      await tester.pumpAndSettle();

      // Streak sheet should be open with 7 days of the week in Mongolian
      expect(find.text('7 хоногийн амжилт'), findsOneWidget);
      expect(find.text('Да'), findsOneWidget);
      expect(find.text('Мя'), findsOneWidget);
      expect(find.text('Лх'), findsOneWidget);
      expect(find.text('Пү'), findsOneWidget);
      expect(find.text('Ба'), findsOneWidget);
      expect(find.text('Бя'), findsOneWidget);
      expect(find.text('Ня'), findsOneWidget);
    });

    testWidgets('BookDetailPage allows submitting inline review using account user profile',
        (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final book = BookRepository.getInitialBooks().first;
      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));

      await tester.pumpWidget(createLocalizedTestWidget(
        child: BookDetailPage(book: book),
        bookProvider: bookProvider,
      ));
      await tester.pumpAndSettle();

      // In overview tab (tab 0), reviews form is removed
      expect(find.text('Сэтгэгдэл илгээх'), findsNothing);

      // Tap 'Сэтгэгдэл' tab (tab 2)
      final reviewsTab = find.text('Сэтгэгдэл');
      expect(reviewsTab, findsOneWidget);
      await tester.tap(reviewsTab);
      await tester.pumpAndSettle();

      final submitButton = find.text('Сэтгэгдэл илгээх');
      expect(submitButton, findsOneWidget);

      // Name textfield is removed; only comment TextField remains
      final textFields = find.byType(TextField);
      expect(textFields, findsOneWidget);

      // Enter comment
      await tester.enterText(textFields.first, 'Гайхалтай урам зориг өгсөн гайхамшигт бүтээл!');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify review was added with account user name (bookProvider.userProfile.name)
      final updatedBook = bookProvider.books.firstWhere((b) => b.id == book.id);
      expect(updatedBook.reviews.any((r) => r.userName == bookProvider.userProfile.name), isTrue);
    });

    testWidgets('BookDetailPage displays sign-in prompt in reviews tab when user is guest',
        (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final book = BookRepository.getInitialBooks().first;
      final guestProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      guestProvider.loginAsGuest();

      await tester.pumpWidget(createLocalizedTestWidget(
        child: BookDetailPage(book: book),
        bookProvider: guestProvider,
      ));
      await tester.pumpAndSettle();

      // Tap 'Сэтгэгдэл' tab
      await tester.tap(find.text('Сэтгэгдэл'));
      await tester.pumpAndSettle();

      // Guest prompt should be displayed
      expect(find.text('Сэтгэгдэл бичихийн тулд нэвтэрнэ үү'), findsOneWidget);
      expect(find.text('Нэвтрэх / Бүртгүүлэх'), findsOneWidget);
      expect(find.text('Сэтгэгдэл илгээх'), findsNothing);
    });

    testWidgets('HomePage renders 2-column SliverGrid for books', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bookProvider = BookProvider();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));

      await tester.pumpWidget(createLocalizedTestWidget(
        child: const HomePage(),
        bookProvider: bookProvider,
      ));
      await tester.pumpAndSettle();

      // Find SliverGrid
      final sliverGridFinder = find.byType(SliverGrid);
      expect(sliverGridFinder, findsOneWidget);

      final sliverGrid = tester.widget<SliverGrid>(sliverGridFinder);
      final delegate = sliverGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
      expect(delegate.childAspectRatio, 0.68);
    });
  });
}
