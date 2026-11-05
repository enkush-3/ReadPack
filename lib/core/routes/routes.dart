import 'package:flutter/material.dart';
import 'package:readpack/app_shell.dart';
import 'package:readpack/features/auth/presentation/page/auth.dart';
import 'package:readpack/features/details/presentation/page/book_detail.dart';
import 'package:readpack/features/leaderboard/presentation/page/leaderboard_page.dart';
import 'package:readpack/features/notifications/presentation/page/notifications_page.dart';
import 'package:readpack/features/onboarding/presentation/page/onboarding_page.dart';
import 'package:readpack/features/reader/presentation/page/reader_page.dart';
import 'package:readpack/features/settings/presentation/page/settings_page.dart';
import 'package:readpack/models/book.dart';

class Routes {
  Routes._();

  static const String auth = '/auth';
  static const String verify = '/verify';
  static const String appshell = '/shell';
  static const String bookDetail = '/book-detail';
  static const String reader = '/reader';
  static const String notifications = '/notifications';
  static const String onboarding = '/onboarding';
  static const String leaderboard = '/leaderboard';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return _buildAnimatedRoute(
          settings: settings,
          builder: (_) => const AuthPage(),
        );

      case onboarding:
        return _buildAnimatedRoute(
          settings: settings,
          builder: (_) => const OnboardingPage(),
        );

      case '/':
      case '':
      case appshell:
        int initialIndex = 0;
        if (settings.arguments is int) {
          initialIndex = settings.arguments as int;
        }
        return _buildAnimatedRoute(
          settings: settings,
          builder: (_) => AppShell(initialIndex: initialIndex),
        );

      case notifications:
        return _buildAnimatedRoute(
          settings: settings,
          builder: (_) => const NotificationsPage(),
        );

      case leaderboard:
        return _buildAnimatedRoute(
          settings: settings,
          builder: (_) => const LeaderboardPage(),
        );

      case Routes.settings:
        return _buildAnimatedRoute(
          settings: settings,
          builder: (_) => const SettingsPage(),
        );

      case bookDetail:
        if (settings.arguments is Book) {
          final book = settings.arguments as Book;
          return _buildAnimatedRoute(
            settings: settings,
            builder: (_) => BookDetailPage(book: book),
          );
        }
        return _errorRoute('Book data is missing');

      case reader:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final book = args['book'] as Book;
          final initialChapterIndex =
              args['initialChapterIndex'] as int? ?? 0;
          final openAudio = args['openAudio'] as bool? ?? false;
          return _buildAnimatedRoute(
            settings: settings,
            builder: (_) => ReaderPage(
              book: book,
              initialChapterIndex: initialChapterIndex,
              openAudioInitially: openAudio,
            ),
          );
        } else if (settings.arguments is Book) {
          return _buildAnimatedRoute(
            settings: settings,
            builder: (_) => ReaderPage(book: settings.arguments as Book),
          );
        }
        return _errorRoute('Reader parameters are missing');

      default:
        return _errorRoute('Хуудас олдсонгүй: ${settings.name}');
    }
  }

  static Route<dynamic> _buildAnimatedRoute({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slideTween = Tween<Offset>(
          begin: const Offset(0.04, 0.0),
          end: Offset.zero,
        ).animate(curve);
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

        return SlideTransition(
          position: slideTween,
          child: FadeTransition(
            opacity: fadeTween,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Алдаа')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}