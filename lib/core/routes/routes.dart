import 'package:flutter/material.dart';
import 'package:readpack/app_shell.dart';
import 'package:readpack/features/auth/presentation/page/auth.dart';

class Routes {
  Routes._(_);

  static const String auth = '/auth';
  static const String verify = '/verify';
  static const String appshell = '/shell';

  
  static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case auth:
      return MaterialPageRoute(builder: (_) => AuthPage());
    case appshell:
      return MaterialPageRoute(builder: (_) => AppShell());

      
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Route not found')),
        ),
      );
    }
  }

}