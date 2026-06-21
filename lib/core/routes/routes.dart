import 'package:flutter/material.dart';
import 'package:readpack/features/auth/presentation/page/auth.dart';
import 'package:readpack/features/home/presentation/page/home.dart';

class Routes {
  Routes._(_);

  static const String auth = '/auth';
  static const String verify = '/verify';
  static const String home = '/home';

  
  static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case auth:
      return MaterialPageRoute(builder: (_) => AuthPage());
    case home:
      return MaterialPageRoute(builder: (_) => HomePage());
    
    
    
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Route not found')),
        ),
      );
    }
  }

}