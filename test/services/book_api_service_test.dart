import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/data/services/book_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BookApiService Tests', () {
    const mockSuccessJson = '''
    {
      "count": 1,
      "results": [
        {
          "id": 1342,
          "title": "Pride and Prejudice",
          "authors": [
            {"name": "Austen, Jane", "birth_year": 1775, "death_year": 1817}
          ],
          "subjects": [
            "Courtship -- Fiction",
            "Sisters -- Fiction",
            "Love stories",
            "England -- Fiction"
          ],
          "formats": {
            "image/jpeg": "https://www.gutenberg.org/cache/epub/1342/pg1342.cover.medium.jpg",
            "audio/mpeg": "https://example.org/pride-and-prejudice.mp3"
          },
          "download_count": 54200
        }
      ]
    }
    ''';

    const mockOpenLibraryJson = '''
    {
      "docs": [
        {
          "key": "/works/OL12345W",
          "title": "Unrated Remote Book",
          "author_name": ["A. Author"]
        }
      ]
    }
    ''';

    const mockSparseCentralCatalogJson = '''
    {
      "results": [
        {
          "id": "central-book-1",
          "title": "Sparse Catalog Book",
          "author": "Catalog Author"
        }
      ]
    }
    ''';

    test(
      'fetchBooks parses remote Gutendex payload correctly and caches',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            mockSuccessJson,
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final service = BookApiService(client: mockClient);
        final books = await service.fetchBooks();

        expect(books.length, 1);
        final book = books.first;
        expect(book.id, 'api_1342');
        expect(book.title, 'Pride and Prejudice');
        expect(book.author, 'Jane Austen');
        expect(book.category, 'book.categories.romance');
        expect(book.hasAudio, isTrue);
        expect(book.chapters, isEmpty);
        expect(book.reviews, isEmpty);
        expect(book.rating, 0.0);
        expect(book.reviewsCount, 0);
        expect(book.pages, 0);
        expect(book.readTimeMinutes, 0);
        expect(book.description, isEmpty);
        expect(book.keyTakeaways, isEmpty);

        // Verify cached in SharedPreferences
        final cached = await service.getCachedBooks();
        expect(cached.length, 1);
        expect(cached.first.title, 'Pride and Prejudice');
      },
    );

    test(
      'OpenLibrary metadata does not imply book content or ratings',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            mockOpenLibraryJson,
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final service = BookApiService(client: mockClient);
        final books = await service.fetchBooks(query: 'Unrated Remote Book');

        expect(books, hasLength(1));
        expect(books.first.chapters, isEmpty);
        expect(books.first.reviews, isEmpty);
        expect(books.first.rating, 0.0);
        expect(books.first.reviewsCount, 0);
        expect(books.first.pages, 0);
        expect(books.first.readTimeMinutes, 0);
        expect(books.first.image, isNull);
        expect(books.first.description, isEmpty);
        expect(books.first.keyTakeaways, isEmpty);
      },
    );

    test(
      'central catalog results do not inherit model metric defaults',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(mockSparseCentralCatalogJson, 200);
        });

        final service = BookApiService(client: mockClient);
        final books = await service.fetchBooks();

        expect(books, hasLength(1));
        expect(books.first.id, 'central-book-1');
        expect(books.first.rating, 0.0);
        expect(books.first.reviewsCount, 0);
        expect(books.first.pages, 0);
        expect(books.first.readTimeMinutes, 0);
        expect(books.first.chapters, isEmpty);
        expect(books.first.reviews, isEmpty);
      },
    );

    test('sparse remote cache entries keep metrics unknown', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        BookApiService.cacheKey,
        jsonEncode([
          {
            'id': 'ol_cached_sparse',
            'title': 'Sparse Cached Book',
            'author': 'Cached Author',
          },
        ]),
      );

      final service = BookApiService(
        client: MockClient((request) async => http.Response('', 500)),
      );
      final books = await service.getCachedBooks();

      expect(books, hasLength(1));
      expect(books.first.rating, 0.0);
      expect(books.first.reviewsCount, 0);
      expect(books.first.pages, 0);
      expect(books.first.readTimeMinutes, 0);
      expect(books.first.chapters, isEmpty);
      expect(books.first.reviews, isEmpty);
    });

    test('legacy remote cache removes generated content and metrics', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        BookApiService.cacheKey,
        jsonEncode([
          {
            'id': 'api_1342',
            'title': 'Pride and Prejudice',
            'author': 'Jane Austen',
            'rating': 4.2,
            'reviewsCount': 54200,
            'pages': 222,
            'readTimeMinutes': 244,
            'chapters': [
              {
                'id': 'api_1342_c1',
                'title': 'Part 1: The Beginning',
                'content': 'Generated prose',
              },
              {
                'id': 'source-chapter-1',
                'title': 'Source chapter',
                'content': 'Verified source text',
              },
            ],
            'reviews': [
              {
                'id': 'rev_api_1342_1',
                'userName': 'Open Reader',
                'rating': 5.0,
                'comment': 'Generated review',
              },
              {
                'id': 'source-review-1',
                'userName': 'Catalog Reader',
                'rating': 4.0,
                'comment': 'Verified review',
              },
            ],
            'keyTakeaways': [
              'Classic wisdom that withstands the test of historical eras.',
              'Verified source takeaway',
            ],
          },
        ]),
      );

      final service = BookApiService(
        client: MockClient((request) async => http.Response('', 500)),
      );
      final books = await service.getCachedBooks();

      expect(books, hasLength(1));
      expect(books.first.rating, 0.0);
      expect(books.first.reviewsCount, 0);
      expect(books.first.pages, 0);
      expect(books.first.readTimeMinutes, 0);
      expect(books.first.chapters.map((chapter) => chapter.id), [
        'source-chapter-1',
      ]);
      expect(books.first.reviews.map((review) => review.id), [
        'source-review-1',
      ]);
      expect(books.first.keyTakeaways, ['Verified source takeaway']);
    });

    test('legacy OpenLibrary cache removes its generated chapters', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        BookApiService.cacheKey,
        jsonEncode([
          {
            'id': 'ol_OL12345W',
            'title': 'Unrated Remote Book',
            'author': 'A. Author',
            'description': 'Generated OpenLibrary description',
            'rating': 4.6,
            'reviewsCount': 180,
            'pages': 240,
            'readTimeMinutes': 264,
            'image': 'assets/public/books/atomic_habits.png',
            'chapters': [
              {
                'id': 'ol_OL12345W_c1',
                'title': '1-р бүлэг: Оршил ба үндсэн санаа',
                'content': 'Generated prose',
              },
            ],
            'reviews': [
              {
                'id': 'rev_ol_OL12345W_1',
                'userName': 'OpenLibrary Reader',
                'rating': 5.0,
                'comment': 'Generated review',
              },
            ],
            'keyTakeaways': [
              'A. Author-ийн дэвшүүлсэн гол философи болон практик зарчмууд.',
              'Системтэй сэтгэлгээ ба тууштай дадлыг хэвшүүлэх арга зам.',
              'OpenLibrary олон улсын номын сангаас баталгаажсан бүтээл.',
            ],
          },
        ]),
      );

      final service = BookApiService(
        client: MockClient((request) async => http.Response('', 500)),
      );
      final books = await service.getCachedBooks();

      expect(books, hasLength(1));
      expect(books.first.rating, 0.0);
      expect(books.first.reviewsCount, 0);
      expect(books.first.pages, 0);
      expect(books.first.readTimeMinutes, 0);
      expect(books.first.description, isEmpty);
      expect(books.first.image, isNull);
      expect(books.first.chapters, isEmpty);
      expect(books.first.reviews, isEmpty);
      expect(books.first.keyTakeaways, isEmpty);
      expect(books.first.tags, isEmpty);
    });

    test('fetchBooks appends search query to URI', () async {
      String? requestedUrl;
      final mockClient = MockClient((request) async {
        requestedUrl = request.url.toString();
        return http.Response(mockSuccessJson, 200);
      });

      final service = BookApiService(client: mockClient);
      await service.fetchBooks(query: 'Jane Austen');

      expect(requestedUrl, contains('search=Jane%20Austen'));
    });

    test('fetchBooks falls back to cache on HTTP error', () async {
      final prefs = await SharedPreferences.getInstance();
      final sampleCached = [
        {
          'id': 'api_999',
          'title': 'Cached Title',
          'author': 'Cached Author',
          'description': 'Cached description',
          'rating': 4.5,
          'reviewsCount': 100,
          'category': 'book.categories.business',
          'pages': 250,
          'readTimeMinutes': 250,
          'image': 'assets/public/books/atomic_habits.png',
          'colorHex': 4281155152,
          'progress': 0.0,
          'currentPage': 0,
          'currentChapterIndex': 0,
          'isSaved': false,
          'isFavorite': false,
          'hasAudio': true,
          'audioDurationMinutes': 250,
          'keyTakeaways': ['Takeaway 1'],
          'tags': ['Classic'],
          'reviews': [],
          'chapters': [],
        },
      ];
      await prefs.setString(BookApiService.cacheKey, jsonEncode(sampleCached));

      final failingClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final service = BookApiService(client: failingClient);
      final books = await service.fetchBooks();

      expect(books.isNotEmpty, isTrue);
      expect(books.first.title, 'Cached Title');
      expect(service.lastCatalogErrorMessage, contains('HTTP 500'));
    });

    test(
      'fetchBooks falls back to repository if network fails and cache is empty',
      () async {
        final failingClient = MockClient((request) async {
          throw http.ClientException('Network down');
        });

        final service = BookApiService(client: failingClient);
        final books = await service.fetchBooks();

        expect(books.length, greaterThanOrEqualTo(16));
        expect(service.lastCatalogErrorMessage, contains('Network down'));
      },
    );

    test(
      'private user data is not sent without an authenticated session',
      () async {
        final hitPaths = <String>[];
        final mockClient = MockClient((request) async {
          hitPaths.add('${request.method} ${request.url.path}');
          return http.Response('Not found', 404);
        });

        final service = BookApiService(client: mockClient);
        final books = await service.fetchBooks();
        final syncRes = await service.syncUserReadingToTree(
          userIdOrEmail: 'usr_bat_01',
          book: books.first,
        );
        expect(syncRes, isNull);
        expect(
          hitPaths.where((path) => path.startsWith('POST /api/v1/users/')),
          isEmpty,
        );
      },
    );

    test(
      'BookProvider actions automatically sync with Express + MongoDB backend',
      () async {
        final hitPaths = <String>[];
        final mockClient = MockClient((request) async {
          hitPaths.add('${request.method} ${request.url.path}');
          return http.Response(mockSuccessJson, 200);
        });

        final apiService = BookApiService(client: mockClient);
        final provider = BookProvider(apiService: apiService);
        await Future.delayed(const Duration(milliseconds: 50));

        provider.loginWithEmail('bat@readpack.app', 'Bat-Erdene');
        provider.updateReadingProgress(provider.books.first.id, 40, 0.5, 1);
        provider.toggleSaveBook(provider.books.first.id);
        provider.updateUserProfile(dailyGoalMinutes: 45);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(hitPaths.where((path) => path.contains('/auth/login')), isEmpty);
        expect(
          hitPaths.where((path) => path.startsWith('POST /api/v1/users/')),
          isEmpty,
        );
        expect(
          hitPaths.where((path) => path.startsWith('PUT /api/v1/users/')),
          isEmpty,
        );
      },
    );
  });
}
