import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/data/book_repository.dart';
import 'package:readpack/features/details/presentation/page/book_detail.dart';
import 'package:readpack/helper/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers/secure_storage_mock.dart';

Widget _testApp({required Widget child, required BookProvider bookProvider}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: ThemeProvider()),
        ChangeNotifierProvider<BookProvider>.value(value: bookProvider),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: child,
        ),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockSecureStorage();
  });
  testWidgets('Book detail tabs stay available while scrolling at 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = BookProvider();
    addTearDown(provider.dispose);
    await tester.runAsync(() => provider.initialized);
    final book = BookRepository.getInitialBooks().first;
    await tester.pumpWidget(_testApp(child: BookDetailPage(book: book), bookProvider: provider));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    final overviewTab = find.text('Overview').first;
    expect(overviewTab, findsOneWidget);
    expect(tester.getTopLeft(overviewTab).dy, lessThan(140));
    expect(tester.takeException(), isNull);
  });
}
