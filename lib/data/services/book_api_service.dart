import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:readpack/data/book_repository.dart';
import 'package:readpack/data/services/api_configuration.dart';
import 'package:readpack/data/services/auth_api_service.dart';
import 'package:readpack/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookApiService {
  static String get defaultBackendBaseUrl => ApiConfiguration.baseUrl;
  static const String openLibrarySearchUrl =
      'https://openlibrary.org/search.json';
  static const String _gutendexBaseUrl = 'https://gutendex.com/books/';
  static const String cacheKey = 'readpack_cached_api_books';
  static const Duration defaultTimeout = Duration(seconds: 6);
  static const String _legacyFallbackCover =
      'assets/public/books/atomic_habits.png';

  late final http.Client _client;
  late final AuthApiService _authService;
  final String backendBaseUrl;

  BookApiService({
    http.Client? client,
    AuthApiService? authService,
    String? backendBaseUrl,
  }) : backendBaseUrl = backendBaseUrl ?? defaultBackendBaseUrl {
    _client = client ?? http.Client();
    _authService =
        authService ??
        AuthApiService(client: _client, baseUrl: this.backendBaseUrl);
  }

  AuthApiService get authService => _authService;

  /// Fetches books via Smart Read-Through Search:
  /// 1. Local/Central Express+MongoDB Catalog first (`$backendBaseUrl/books/search`)
  /// 2. OpenLibrary REST API (`https://openlibrary.org/search.json`)
  /// 3. Gutendex REST API (`https://gutendex.com/books/`)
  /// 4. Offline Cache & Local Seed Repository fallback
  Future<List<Book>> fetchBooks({
    String query = '',
    bool preferCentralBackend = true,
  }) async {
    final trimmed = query.trim();

    // If a specific search query is provided, check if our local curated DB already has it
    if (trimmed.isNotEmpty) {
      final localBooks = BookRepository.getInitialBooks();
      final lowerQuery = trimmed.toLowerCase();
      final localMatches = localBooks.where((b) {
        return b.title.toLowerCase().contains(lowerQuery) ||
            b.author.toLowerCase().contains(lowerQuery);
      }).toList();
      // We still check remote if localMatches is empty, or enrich alongside local DB
      if (localMatches.isEmpty) {
        final openLibBooks = await fetchFromOpenLibrary(trimmed);
        if (openLibBooks.isNotEmpty) {
          await _cacheBooks(openLibBooks);
          return openLibBooks;
        }
      }
    }

    final endpoints = preferCentralBackend
        ? [
            '$backendBaseUrl/books/search',
            openLibrarySearchUrl,
            _gutendexBaseUrl,
          ]
        : [openLibrarySearchUrl, _gutendexBaseUrl];

    for (final baseEndpoint in endpoints) {
      final Uri uri;
      if (baseEndpoint == openLibrarySearchUrl) {
        final q = trimmed.isEmpty ? 'bestseller' : trimmed;
        uri = Uri.parse(
          '$openLibrarySearchUrl?q=${Uri.encodeComponent(q)}&limit=10&Search=${Uri.encodeComponent(trimmed)}&search=${Uri.encodeComponent(trimmed)}',
        );
      } else {
        uri = trimmed.isEmpty
            ? Uri.parse(baseEndpoint)
            : Uri.parse('$baseEndpoint?search=${Uri.encodeComponent(trimmed)}');
      }

      try {
        final response = await _client.get(uri).timeout(defaultTimeout);
        if (response.statusCode == 200) {
          final Map<String, dynamic> data =
              jsonDecode(utf8.decode(response.bodyBytes))
                  as Map<String, dynamic>;

          final books = <Book>[];

          // 1. Parse OpenLibrary 'docs' array if present
          final List<dynamic>? docs = data['docs'] as List<dynamic>?;
          if (docs != null && docs.isNotEmpty) {
            for (final doc in docs) {
              if (doc is Map<String, dynamic>) {
                final book = _parseOpenLibraryDoc(doc);
                if (book != null) {
                  books.add(book);
                }
              }
            }
          }

          // 2. Parse Central DB or Gutendex 'results' array if present
          final List<dynamic> results = data['results'] as List<dynamic>? ?? [];
          for (final item in results) {
            if (item is Map<String, dynamic>) {
              final book = _parseRemoteBook(item);
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
      } catch (_) {
        // Try next endpoint or fall back to local cache
      }
    }

    final cached = await getCachedBooks();
    if (cached.isNotEmpty) {
      return cached;
    }

    return BookRepository.getInitialBooks();
  }

  /// Directly queries OpenLibrary API (`https://openlibrary.org/search.json`)
  /// when a book is not found in the local database.
  Future<List<Book>> fetchFromOpenLibrary(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    final uri = Uri.parse(
      '$openLibrarySearchUrl?q=${Uri.encodeComponent(trimmed)}&limit=10&search=${Uri.encodeComponent(trimmed)}',
    );
    try {
      final response = await _client.get(uri).timeout(defaultTimeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        final List<dynamic>? docs = data['docs'] as List<dynamic>?;
        if (docs != null && docs.isNotEmpty) {
          final books = <Book>[];
          for (final doc in docs) {
            if (doc is Map<String, dynamic>) {
              final book = _parseOpenLibraryDoc(doc);
              if (book != null) {
                books.add(book);
              }
            }
          }
          if (books.isNotEmpty) return books;
        }

        // Also support mock clients returning 'results'
        final List<dynamic>? results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final books = <Book>[];
          for (final item in results) {
            if (item is Map<String, dynamic>) {
              final book = _parseRemoteBook(item);
              if (book != null) {
                books.add(book);
              }
            }
          }
          if (books.isNotEmpty) return books;
        }
      }
    } catch (_) {}
    return [];
  }

  Book? _parseOpenLibraryDoc(Map<String, dynamic> doc) {
    final title = _readNonEmptyString(doc['title']);
    final rawKey = _readNonEmptyString(doc['key']);
    if (title == null || rawKey == null) return null;

    final bookKey = rawKey.replaceAll('/works/', '');
    if (bookKey.isEmpty) return null;
    return _buildOpenLibraryBook(doc, bookKey, title);
  }

  Book _buildOpenLibraryBook(
    Map<String, dynamic> doc,
    String bookKey,
    String title,
  ) => Book.fromJson(
    _openLibraryBookFields(doc: doc, bookKey: bookKey, title: title),
  );

  Map<String, dynamic> _openLibraryBookFields({
    required Map<String, dynamic> doc,
    required String bookKey,
    required String title,
  }) => {
    'id': 'ol_$bookKey',
    'title': title,
    'author': _readOpenLibraryAuthor(doc['author_name']),
    'description': _readDescription(doc['description']),
    'rating': _readRating(doc['ratings_average']),
    'reviewsCount': _readNonNegativeInt(doc['ratings_count']),
    'category': _mapSubjectsToCategory(_readOpenLibrarySubjects(doc)),
    'pages': _readNonNegativeInt(doc['number_of_pages_median']),
    'readTimeMinutes': _readOpenLibraryReadingMinutes(doc),
    'image': _readOpenLibraryCoverUrl(doc),
    'colorHex': 0xFF1E293B,
    'tags': _readOpenLibrarySubjects(doc),
  };

  List<String> _readOpenLibrarySubjects(Map<String, dynamic> doc) {
    final subjects = _readSubjects(doc['subject']);
    if (subjects.isNotEmpty) return subjects;
    return _readSubjects(doc['subject_facet']);
  }

  String? _readOpenLibraryCoverUrl(Map<String, dynamic> doc) {
    final coverId = _readNonNegativeInt(doc['cover_i']);
    if (coverId == 0) return null;
    return 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
  }

  int _readOpenLibraryReadingMinutes(Map<String, dynamic> doc) {
    return _estimateReadingMinutes(
      _readNonNegativeInt(doc['number_of_pages_median']),
    );
  }

  /// Synchronizes a book and reading progress into the Express + MongoDB
  /// Central Books Catalog and the user's `UserAccountTree.readingTree`.
  Future<Map<String, dynamic>?> syncUserReadingToTree({
    required String userIdOrEmail,
    required Book book,
    String shelfId = 'currently_reading',
    String status = 'reading',
    int minutesRead = 0,
    Map<String, dynamic>? highlight,
    Map<String, dynamic>? note,
  }) async {
    try {
      return await _authService.requestAuthorized(
        'POST',
        '/users/${Uri.encodeComponent(userIdOrEmail)}/reading',
        body: {
          'book': book.toJson(),
          'shelfId': shelfId,
          'status': status,
          'progress': book.progress,
          'currentChapter': book.currentChapterIndex,
          'currentPage': book.currentPage,
          'minutesRead': minutesRead,
          if (highlight != null) 'highlight': highlight,
          if (note != null) 'note': note,
        },
      );
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> recordReadingEvent({
    required String userId,
    required String eventId,
    required int minutesRead,
    Book? book,
    String? bookId,
  }) async {
    if (minutesRead <= 0 ||
        eventId.trim().isEmpty ||
        (book == null && (bookId == null || bookId.trim().isEmpty))) {
      return null;
    }
    try {
      return await _authService.requestAuthorized(
        'POST',
        '/users/${Uri.encodeComponent(userId)}/reading/events',
        body: {
          'eventId': eventId,
          'minutesRead': minutesRead,
          'timezoneOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
          if (book != null) 'book': book.toJson(),
          if (book == null && bookId != null) 'bookId': bookId,
        },
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchLeaderboard({String period = 'weekly'}) =>
      _authService.fetchLeaderboard(period: period);

  /// Updates user profile & preferences in the MongoDB `UserAccountTree`.
  Future<Map<String, dynamic>?> updateUserPreferencesTree({
    required String userIdOrEmail,
    required Map<String, dynamic> payload,
  }) async {
    try {
      return await _authService.updateUserTree(userIdOrEmail, payload);
    } catch (_) {}
    return null;
  }

  /// Synchronizes a book directly into the Central Books Catalog (`POST /api/v1/books/sync`).
  Future<Map<String, dynamic>?> syncBookToCentralCatalog(Book book) async {
    try {
      return await _authService.requestAuthorized(
        'POST',
        '/books/sync',
        body: {'book': book.toJson()},
      );
    } catch (_) {}
    return null;
  }

  Book? _parseRemoteBook(Map<String, dynamic> map) {
    if (map['id'] is String && map['author'] is String) {
      try {
        return Book.fromJson(_normalizeRemoteBookMetrics(map));
      } catch (_) {}
    }
    return _parseGutendexBook(map);
  }

  Map<String, dynamic> _normalizeRemoteBookMetrics(Map<String, dynamic> map) {
    return {
      ...map,
      'rating': _readRating(map['rating']),
      'reviewsCount': _readNonNegativeInt(map['reviewsCount']),
      'pages': _readNonNegativeInt(map['pages']),
      'readTimeMinutes': _readNonNegativeInt(map['readTimeMinutes']),
    };
  }

  Book? _parseGutendexBook(Map<String, dynamic> map) {
    final bookId = _readNonNegativeInt(map['id']);
    final title = _readNonEmptyString(map['title']);
    if (bookId == 0 || title == null) return null;

    return _buildGutendexBook(map, bookId, title);
  }

  Book _buildGutendexBook(Map<String, dynamic> map, int bookId, String title) =>
      Book.fromJson(
        _gutendexBookFields(map: map, bookId: bookId, title: title),
      );

  Map<String, dynamic> _gutendexBookFields({
    required Map<String, dynamic> map,
    required int bookId,
    required String title,
  }) => {
    'id': 'api_$bookId',
    'title': title,
    'author': _readGutendexAuthor(map['authors']),
    'description': _readDescription(map['description']),
    'rating': 0,
    'reviewsCount': 0,
    'category': _mapSubjectsToCategory(_readSubjects(map['subjects'])),
    'pages': 0,
    'readTimeMinutes': 0,
    'image': _readHttpsUrl(_readFormats(map['formats'])['image/jpeg']),
    'colorHex': 0xFF2C3E50,
    'audioUrl': _readGutendexAudioUrl(map['formats']),
    'tags': _readSubjects(map['subjects']),
  };

  String? _readGutendexAudioUrl(Object? rawFormats) {
    final formats = _readFormats(rawFormats);
    return _readHttpsUrl(formats['audio/mpeg']) ??
        _readHttpsUrl(formats['audio/mp4']) ??
        _readHttpsUrl(formats['audio/ogg']);
  }

  String _readOpenLibraryAuthor(Object? rawAuthors) {
    if (rawAuthors is! List) return 'Unknown Author';
    for (final author in rawAuthors) {
      if (author is String && author.trim().isNotEmpty) return author.trim();
    }
    return 'Unknown Author';
  }

  String _readGutendexAuthor(Object? rawAuthors) {
    if (rawAuthors is! List) return 'Unknown Author';
    for (final author in rawAuthors) {
      if (author is! Map<String, dynamic>) continue;
      final name = _readNonEmptyString(author['name']);
      if (name == null) continue;
      final parts = name.split(', ');
      return parts.length > 1 ? '${parts[1]} ${parts[0]}' : name;
    }
    return 'Unknown Author';
  }

  String _readDescription(Object? rawDescription) {
    if (rawDescription is String) return rawDescription.trim();
    if (rawDescription is Map<String, dynamic>) {
      return _readNonEmptyString(rawDescription['value']) ?? '';
    }
    return '';
  }

  String? _readNonEmptyString(Object? rawText) {
    if (rawText is! String || rawText.trim().isEmpty) return null;
    return rawText.trim();
  }

  int _readNonNegativeInt(Object? rawNumber) {
    if (rawNumber is! int || rawNumber < 0) return 0;
    return rawNumber;
  }

  double _readRating(Object? rawRating) {
    if (rawRating is! num) return 0;
    final rating = rawRating.toDouble();
    return rating.isFinite && rating >= 0 && rating <= 5 ? rating : 0;
  }

  List<String> _readSubjects(Object? rawSubjects) {
    if (rawSubjects is! List) return const [];
    return rawSubjects
        .whereType<String>()
        .map((subject) => subject.trim())
        .where((subject) => subject.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _readFormats(Object? rawFormats) {
    if (rawFormats is Map<String, dynamic>) return rawFormats;
    return const {};
  }

  String? _readHttpsUrl(Object? rawUrl) {
    final url = _readNonEmptyString(rawUrl);
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return uri.toString();
  }

  int _estimateReadingMinutes(int pages) {
    if (pages == 0) return 0;
    return (pages * 1.1).round();
  }

  String _mapSubjectsToCategory(List<String> subjects) {
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
            .map(
              (item) => Book.fromJson(
                _normalizeCachedBook(item as Map<String, dynamic>),
              ),
            )
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Map<String, dynamic> _normalizeCachedBook(Map<String, dynamic> cachedBook) {
    final normalizedBook = _normalizeRemoteBookMetrics(cachedBook);
    final bookId = _readNonEmptyString(cachedBook['id']);
    if (bookId == null || !_isRemoteCatalogBookId(bookId)) {
      return normalizedBook;
    }
    if (cachedBook['image'] == _legacyFallbackCover) {
      normalizedBook['image'] = null;
    }
    if (!_hasLegacyRemoteContent(cachedBook, bookId)) return normalizedBook;
    return _removeLegacyRemoteContent(normalizedBook, cachedBook, bookId);
  }

  bool _isRemoteCatalogBookId(String bookId) =>
      bookId.startsWith('api_') || bookId.startsWith('ol_');

  bool _hasLegacyRemoteContent(Map<String, dynamic> cachedBook, String bookId) {
    if (!_isRemoteCatalogBookId(bookId)) return false;
    final author = _readNonEmptyString(cachedBook['author']) ?? '';
    return _cachedList(
          cachedBook['chapters'],
        ).any((chapter) => _isLegacyGeneratedChapter(chapter, bookId)) ||
        _cachedList(
          cachedBook['reviews'],
        ).any((review) => _isLegacyGeneratedReview(review, bookId)) ||
        _cachedList(cachedBook['keyTakeaways']).any(
          (takeaway) => _isLegacyGeneratedTakeaway(takeaway, bookId, author),
        );
  }

  Map<String, dynamic> _removeLegacyRemoteContent(
    Map<String, dynamic> normalizedBook,
    Map<String, dynamic> cachedBook,
    String bookId,
  ) {
    final author = _readNonEmptyString(cachedBook['author']) ?? '';
    return {
      ..._legacyRemoteMetadata(normalizedBook),
      ..._legacyCachedContent(cachedBook, bookId, author),
    };
  }

  Map<String, dynamic> _legacyRemoteMetadata(
    Map<String, dynamic> normalizedBook,
  ) => {
    ...normalizedBook,
    'description': '',
    'rating': 0,
    'reviewsCount': 0,
    'pages': 0,
    'readTimeMinutes': 0,
    'tags': const <String>[],
  };

  Map<String, dynamic> _legacyCachedContent(
    Map<String, dynamic> cachedBook,
    String bookId,
    String author,
  ) => {
    'chapters': _cachedList(
      cachedBook['chapters'],
    ).where((chapter) => !_isLegacyGeneratedChapter(chapter, bookId)).toList(),
    'reviews': _cachedList(
      cachedBook['reviews'],
    ).where((review) => !_isLegacyGeneratedReview(review, bookId)).toList(),
    'keyTakeaways': _cachedList(cachedBook['keyTakeaways'])
        .where(
          (takeaway) => !_isLegacyGeneratedTakeaway(takeaway, bookId, author),
        )
        .toList(),
  };

  List<dynamic> _cachedList(Object? value) => value is List ? value : const [];

  bool _isLegacyGeneratedChapter(Object? value, String bookId) {
    if (value is! Map<String, dynamic>) return false;
    final chapterId = value['id'];
    final title = value['title'];
    if (bookId.startsWith('api_')) {
      return (chapterId == '${bookId}_c1' &&
              title == 'Part 1: The Beginning') ||
          (chapterId == '${bookId}_c2' && title == 'Part 2: Deeper Horizons');
    }
    return (chapterId == '${bookId}_c1' &&
            title == '1-р бүлэг: Оршил ба үндсэн санаа') ||
        (chapterId == '${bookId}_c2' &&
            title == '2-р бүлэг: Гүнзгийрүүлсэн задлан шинжилгээ') ||
        (chapterId == '${bookId}_c3' &&
            title == '3-р бүлэг: Дүгнэлт ба практик хэрэглээ');
  }

  bool _isLegacyGeneratedReview(Object? value, String bookId) {
    if (value is! Map<String, dynamic>) return false;
    final userName = bookId.startsWith('api_')
        ? 'Open Reader'
        : 'OpenLibrary Reader';
    return value['id'] == 'rev_${bookId}_1' && value['userName'] == userName;
  }

  bool _isLegacyGeneratedTakeaway(Object? value, String bookId, String author) {
    if (bookId.startsWith('api_')) {
      return const {
        'Classic wisdom that withstands the test of historical eras.',
        'Fundamental principles of human perspective and creative imagination.',
        'Essential reading preserved in the public open archives.',
      }.contains(value);
    }
    return value ==
            '$author-ийн дэвшүүлсэн гол философи болон практик зарчмууд.' ||
        value == 'Системтэй сэтгэлгээ ба тууштай дадлыг хэвшүүлэх арга зам.' ||
        value == 'OpenLibrary олон улсын номын сангаас баталгаажсан бүтээл.';
  }
}
