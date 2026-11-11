import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/quotes/presentation/phone_widget_sheet.dart';
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
          data: const MediaQueryData(disableAnimations: true),
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
  testWidgets('Widget preview saves its locale and Material color roles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = BookProvider();
    addTearDown(provider.dispose);
    await tester.runAsync(() => provider.initialized);
    await tester.pumpWidget(
      _testApp(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => PhoneWidgetSheet.show(context),
                child: const Text('Open preview'),
              ),
            ),
          ),
        ),
        bookProvider: provider,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open preview'));
    await tester.pumpAndSettle();
    expect(find.textContaining('launcher controls'), findsOneWidget);
    final applyButton = find.text('Apply to Phone Widget');
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('widget_quote_language'), 'en');
    expect(prefs.getInt('widget_quote_color_primary'), isNotNull);
    expect(prefs.getInt('widget_quote_color_onPrimary'), isNotNull);
    expect(prefs.getInt('widget_quote_color_surface'), isNotNull);
    expect(prefs.getInt('widget_quote_color_onSurface'), isNotNull);
    expect(prefs.getInt('widget_quote_color_surfaceContainer'), isNotNull);
    expect(prefs.getInt('widget_quote_color_outlineVariant'), isNotNull);
    expect(prefs.getInt('widget_quote_color_secondary'), isNotNull);
    expect(prefs.getInt('widget_quote_color_onSecondary'), isNotNull);
    expect(tester.takeException(), isNull);
  });
}
