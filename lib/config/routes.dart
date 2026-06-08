import 'package:flutter/material.dart';
import '../pages/auth/auth.dart';
import '../pages/home/home.dart';
import '../pages/profile/profile.dart';
import '../pages/search/search.dart';
import '../pages/books/book_details.dart';
import '../pages/books/my_books.dart';
import '../pages/books/reader.dart';

/// App route constants
class Routes {
  Routes._();

  static const String auth = '/auth';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String bookDetails = '/book-details';
  static const String myBooks = '/my-books';
  static const String reader = '/reader';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
          return MaterialPageRoute(builder: (_) => AuthPages());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      // case bookDetails:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => BookDetailsPage(bookId: args?['bookId'] as String?),
      //   );
      case myBooks:
        return MaterialPageRoute(builder: (_) => const SavedPage());
      // case reader:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => ReaderPage(bookId: args?['bookId'] as String),
      //   );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}