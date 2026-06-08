import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'pages/auth/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadPact',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      initialRoute: Routes.auth,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}