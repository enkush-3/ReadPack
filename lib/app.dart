import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';

import 'core/themes/themes.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      locale: const Locale('en'),
      supportedLocales: const [
        Locale('mn'),
        Locale('en'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      theme: BookTheme.lightTheme,
      darkTheme: BookTheme.darkTheme,
      themeMode: ThemeMode.system,

      initialRoute: Routes.appshell,
      onGenerateRoute: Routes.generateRoute,
      
    );
  }
}