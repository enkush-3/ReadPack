import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:readpack/data/book_repository.dart';
import 'package:readpack/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookApiService {
  static const String _gutendexBaseUrl = 'https://gutendex.com/books/';
  static const String cacheKey = 'readpack_cached_api_books';
  static const Duration defaultTimeout = Duration(seconds: 6);

  final http.Client _client;

  BookApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches books from Gutendex REST API with query support and offline cache fallback.
  Future<List<Book>> fetchBooks({String query = ''}) async {
    final uri = query.trim().isEmpty
        ? Uri.parse(_gutendexBaseUrl)
        : Uri.parse('$_gutendexBaseUrl?search=${Uri.encodeComponent(query.trim())}');

    try {
      final response = await _client.get(uri).timeout(defaultTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final List<dynamic> results = data['results'] as List<dynamic>? ?? [];

        final books = <Book>[];
        for (final item in results) {
          if (item is Map<String, dynamic>) {
            final book = _parseGutendexBook(item);
            if (book != null) {
              books.add(book);
            }
          }
        }

        if (books.isNotEmpty) {
          await _cacheBooks(books);
          return books;
        }
      }
    } on SocketException {
      // Offline mode
    } on TimeoutException {
      // Network timeout
    } catch (_) {
      // Fallback on any network or parsing error
    }

    // Attempt cache fallback
    final cached = await getCachedBooks();
    if (cached.isNotEmpty) {
      return cached;
    }

    // Default to bundled curated repository
    return BookRepository.getInitialBooks();
  }

  Book? _parseGutendexBook(Map<String, dynamic> map) {
    try {
      final int id = map['id'] as int? ?? 0;
      final String title = map['title'] as String? ?? 'Untitled';

      final List<dynamic> authors = map['authors'] as List<dynamic>? ?? [];
      String authorName = 'Unknown Author';
      if (authors.isNotEmpty && authors.first is Map<String, dynamic>) {
        final rawAuthor = authors.first['name'] as String? ?? 'Unknown Author';
        // Gutendex format is usually "Lastname, Firstname"
        final parts = rawAuthor.split(', ');
        authorName = parts.length > 1 ? '${parts[1]} ${parts[0]}' : rawAuthor;
      }

      final List<dynamic> subjects = map['subjects'] as List<dynamic>? ?? [];
      final category = _mapSubjectsToCategory(subjects);

      final Map<String, dynamic> formats =
          map['formats'] as Map<String, dynamic>? ?? {};
      final String coverUrl = formats['image/jpeg'] as String? ??
          'assets/public/books/atomic_habits.png';

      final int downloadCount = map['download_count'] as int? ?? 120;
      final double rating = (4.0 + (downloadCount % 10) * 0.1).clamp(4.0, 5.0);
      final int pages = 180 + (id % 240);
      final int readTime = (pages * 1.1).toInt();

      final chapters = [
        BookChapter(
          id: 'api_${id}_c1',
          title: 'Part 1: The Beginning',
          estimatedMinutes: (readTime / 4).round().clamp(5, 30),
          content:
              'A remarkable classic work by $authorName exploring the depths of human nature, philosophy, and discovery.\n\n"The foundation of knowledge begins with an open mind and relentless curiosity."\n\nThis volume, titled $title, has reached readers worldwide through open-access digital archives.',
        ),
        BookChapter(
          id: 'api_${id}_c2',
          title: 'Part 2: Deeper Horizons',
          estimatedMinutes: (readTime / 4).round().clamp(5, 30),
          content:
              'Continuing through the masterwork: $title.\n\nEvery turning page reveals new insights into human character and timeless wisdom carefully preserved for future generations.',
        ),
      ];

      return Book(
        id: 'api_$id',
        title: title,
        author: authorName,
        description:
            'A renowned digital classic by $authorName. Part of the public literature index with over $downloadCount active global readers.',
        rating: double.parse(rating.toStringAsFixed(1)),
        reviewsCount: downloadCount.clamp(12, 4500),
        category: category,
        pages: pages,
        readTimeMinutes: readTime,
        image: coverUrl,
        colorHex: 0xFF2C3E50,
        progress: 0.0,
        currentPage: 0,
        currentChapterIndex: 0,
        isSaved: false,
        isFavorite: false,
        hasAudio: true,
        audioDurationMinutes: readTime,
        keyTakeaways: [
          'Classic wisdom that withstands the test of historical eras.',
          'Fundamental principles of human perspective and creative imagination.',
          'Essential reading preserved in the public open archives.',
        ],
        tags: [
          'Classic',
          category.replaceAll('book.categories.', ''),
          'OpenAccess',
        ],
        reviews: [
          BookReview(
            id: 'rev_api_${id}_1',
            userName: 'Open Reader',
            rating: 5.0,
            comment:
                'An absolute masterpiece! Accessible online through ReadPack.',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            helpfulCount: 8,
          ),
        ],
        chapters: chapters,
      );
    } catch (_) {
      return null;
    }
  }

  String _mapSubjectsToCategory(List<dynamic> subjects) {
    final lower = subjects.map((s) => s.toString().toLowerCase()).join(' ');
    if (lower.contains('science') ||
        lower.contains('physics') ||
        lower.contains('nature') ||
        lower.contains('biology')) {
      return 'book.categories.science';
    }
    if (lower.contains('history') ||
        lower.contains('war') ||
        lower.contains('biography') ||
        lower.contains('revolution')) {
      return 'book.categories.history';
    }
    if (lower.contains('business') ||
        lower.contains('economy') ||
        lower.contains('finance') ||
        lower.contains('money')) {
      return 'book.categories.business';
    }
    if (lower.contains('love') ||
        lower.contains('romance') ||
        lower.contains('marriage')) {
      return 'book.categories.romance';
    }
    if (lower.contains('adventure') ||
        lower.contains('voyage') ||
        lower.contains('travel') ||
        lower.contains('journey')) {
      return 'book.categories.adventure';
    }
    return 'book.categories.all';
  }

  Future<void> _cacheBooks(List<Book> books) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = books.take(20).map((b) => b.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(list));
    } catch (_) {}
  }

  Future<List<Book>> getCachedBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(cacheKey);
      if (str != null && str.isNotEmpty) {
        final List<dynamic> list = jsonDecode(str) as List<dynamic>;
        return list
            .map((item) => Book.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
