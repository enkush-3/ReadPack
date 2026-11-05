import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/core/themes/themes.dart';
import 'package:readpack/helper/translation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ReadPack',
            locale: themeProvider.locale,
            supportedLocales: const [
              Locale('mn'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: BookTheme.lightTheme,
            darkTheme: BookTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: Routes.appshell,
            onGenerateRoute: Routes.generateRoute,
          );
        },
      ),
    );
  }
}