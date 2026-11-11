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
    try {
      final rawKey = (doc['key'] as String? ?? '').replaceAll('/works/', '');
      final id = rawKey.isNotEmpty
          ? 'ol_$rawKey'
          : 'ol_${doc['cover_i'] ?? doc['title'].hashCode.abs()}';
      final title = (doc['title'] as String? ?? '').trim();
      if (title.isEmpty) return null;

      final authorList = doc['author_name'] as List<dynamic>? ?? [];
      final authorName = authorList.isNotEmpty
          ? authorList.first.toString()
          : 'Unknown Author';

      final int? coverId = doc['cover_i'] as int?;
      final coverUrl = coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
          : 'assets/public/books/atomic_habits.png';

      final subjects =
          (doc['subject'] as List<dynamic>?) ??
          (doc['subject_facet'] as List<dynamic>?) ??
          [];
      final category = _mapSubjectsToCategory(subjects);

      final pages = (doc['number_of_pages_median'] as int?) ?? 240;
      final readTime = (pages * 1.1).round();
      final rawRating = (doc['ratings_average'] as num?)?.toDouble() ?? 4.6;
      final rating = double.parse(rawRating.clamp(3.8, 5.0).toStringAsFixed(1));
      final ratingsCount =
          (doc['ratings_count'] as int?) ??
          ((doc['edition_count'] as int? ?? 15) * 12);
      final publishYear = doc['first_publish_year'] as int?;
      final firstSentenceList = doc['first_sentence'] as List<dynamic>?;
      final firstSentence =
          firstSentenceList != null && firstSentenceList.isNotEmpty
          ? firstSentenceList.first.toString()
          : '';

      final chapters = [
        BookChapter(
          id: '${id}_c1',
          title: '1-р бүлэг: Оршил ба үндсэн санаа',
          estimatedMinutes: 12,
          content:
              '${firstSentence.isNotEmpty ? '$firstSentence\n\n' : ''}$title бол зохиолч $authorName-ийн бичсэн олон улсын уншигчдын талархлыг хүлээсэн бүтээл юм${publishYear != null ? ' (Анх хэвлэгдсэн: $publishYear он)' : ''}.\n\nЭнэхүү бүлэгт зохиолын гол зангилаа, хүний сэтгэлгээ болон амьдралын хэв маягт нөлөөлөх суурь зарчмуудыг тайлбарлана. Уншигч та өдөр тутмын жижиг алхмуудаар дамжуулан томоохон өөрчлөлтөд хүрэх арга барилыг эндээс олж мэдэх болно.\n\nМэдлэг гэдэг зөвхөн уншихаас бус, уншсан зүйлээ амьдралд хэрэгжүүлж, тунгаан бодохоос эхэлдэг.',
        ),
        BookChapter(
          id: '${id}_c2',
          title: '2-р бүлэг: Гүнзгийрүүлсэн задлан шинжилгээ',
          estimatedMinutes: 15,
          content:
              '$authorName энэхүү бүлэгтээ $title бүтээлийнхээ гол философийг бодит жишээ болон түүхэн баримтуудтай холбон тайлбарладаг.\n\nХүн бүр өөрийн зорилгод хүрэхийн тулд тууштай байдал, системтэй сэтгэлгээг хөгжүүлэх шаардлагатай. Орчин үеийн мэдээллийн эрин зуунд төвлөрөх чадвар болон гүнзгий уншлага нь хамгийн үнэ цэнтэй чадваруудын нэг болж байна.\n\nЭнэхүү бүтээл нь OpenLibrary олон улсын нээлттэй номын сангаас ReadPack системээр дамжин танд хүрч байна.',
        ),
        BookChapter(
          id: '${id}_c3',
          title: '3-р бүлэг: Дүгнэлт ба практик хэрэглээ',
          estimatedMinutes: 14,
          content:
              'Төгсгөлийн бүлэгт $title номоос суралцсан гол санаануудыг хэрхэн өөрийн амьдрал, ажил хэрэгт буулгах тухай практик зөвлөмжүүдийг багтаасан.\n\nУншсан ном бүр хүний оюун санаанд шинэ цонх нээж өгдөг. Та энэхүү номын онцлох эшлэлүүдийг тэмдэглэн авч, өөрийн цуглуулгадаа хадгалах боломжтой.',
        ),
      ];

      return Book(
        id: id,
        title: title,
        author: authorName,
        description:
            'Зохиолч $authorName-ийн "$title" бүтээл${publishYear != null ? ' ($publishYear)' : ''}. OpenLibrary нээлттэй сангаас татагдсан дэлхийн шилдэг бүтээлүүдийн нэг.',
        rating: rating,
        reviewsCount: ratingsCount.clamp(10, 9999),
        category: category,
        pages: pages,
        readTimeMinutes: readTime,
        image: coverUrl,
        colorHex: 0xFF1E293B,
        progress: 0.0,
        currentPage: 0,
        currentChapterIndex: 0,
        isSaved: false,
        isFavorite: false,
        hasAudio: false,
        audioDurationMinutes: 0,
        keyTakeaways: [
          '$authorName-ийн дэвшүүлсэн гол философи болон практик зарчмууд.',
          'Системтэй сэтгэлгээ ба тууштай дадлыг хэвшүүлэх арга зам.',
          'OpenLibrary олон улсын номын сангаас баталгаажсан бүтээл.',
        ],
        tags: [
          'OpenLibrary',
          if (publishYear != null) '$publishYear',
          category.replaceAll('book.categories.', ''),
        ],
        reviews: [
          BookReview(
            id: 'rev_${id}_1',
            userName: 'OpenLibrary Reader',
            rating: 5.0,
            comment: 'Маш өгөөжтэй, заавал унших ёстой бүтээл байна.',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            helpfulCount: 12,
          ),
        ],
        chapters: chapters,
      );
    } catch (_) {
      return null;
    }
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
        return Book.fromJson(map);
      } catch (_) {}
    }
    return _parseGutendexBook(map);
  }

  Book? _parseGutendexBook(Map<String, dynamic> map) {
    try {
      final int id = map['id'] as int? ?? 0;
      final String title = map['title'] as String? ?? 'Untitled';

      final List<dynamic> authors = map['authors'] as List<dynamic>? ?? [];
      String authorName = 'Unknown Author';
      if (authors.isNotEmpty && authors.first is Map<String, dynamic>) {
        final rawAuthor = authors.first['name'] as String? ?? 'Unknown Author';
        final parts = rawAuthor.split(', ');
        authorName = parts.length > 1 ? '${parts[1]} ${parts[0]}' : rawAuthor;
      }

      final List<dynamic> subjects = map['subjects'] as List<dynamic>? ?? [];
      final category = _mapSubjectsToCategory(subjects);

      final Map<String, dynamic> formats =
          map['formats'] as Map<String, dynamic>? ?? {};
      final String coverUrl =
          formats['image/jpeg'] as String? ??
          'assets/public/books/atomic_habits.png';
      final audioUrl =
          formats['audio/mpeg'] as String? ??
          formats['audio/mp4'] as String? ??
          formats['audio/ogg'] as String?;

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
        audioUrl: audioUrl,
        hasAudio: audioUrl != null && audioUrl.trim().isNotEmpty,
        audioDurationMinutes: 0,
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
