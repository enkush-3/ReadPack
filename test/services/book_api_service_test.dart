import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
            "image/jpeg": "https://www.gutenberg.org/cache/epub/1342/pg1342.cover.medium.jpg"
          },
          "download_count": 54200
        }
      ]
    }
    ''';

    test('fetchBooks parses remote Gutendex payload correctly and caches',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(mockSuccessJson, 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
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
      expect(book.chapters.length, 2);

      // Verify cached in SharedPreferences
      final cached = await service.getCachedBooks();
      expect(cached.length, 1);
      expect(cached.first.title, 'Pride and Prejudice');
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
        }
      ];
      await prefs.setString(
          BookApiService.cacheKey, jsonEncode(sampleCached));

      final failingClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final service = BookApiService(client: failingClient);
      final books = await service.fetchBooks();

      expect(books.isNotEmpty, isTrue);
      expect(books.first.title, 'Cached Title');
    });

    test('fetchBooks falls back to repository if network fails and cache is empty',
        () async {
      final failingClient = MockClient((request) async {
        throw http.ClientException('Network down');
      });

      final service = BookApiService(client: failingClient);
      final books = await service.fetchBooks();

      expect(books.length, greaterThanOrEqualTo(16));
    });

    test('syncUserAccountTree and syncUserReadingToTree communicate with Express + MongoDB Tree API',
        () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/auth/login')) {
          return http.Response(
            jsonEncode({
              'status': 'authenticated',
              'userAccountTree': {
                'userId': 'usr_bat_01',
                'email': 'bat@readpack.app',
                'profileNode': {'displayName': 'Bat-Erdene'},
                'readingTree': {'shelves': []},
              },
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/reading')) {
          return http.Response(
            jsonEncode({
              'status': 'synced',
              'source': 'central_db',
              'centralBook': {'id': '1', 'title': 'Atomic Habits'},
            }),
            201,
          );
        }
        return http.Response('Not found', 404);
      });

      final service = BookApiService(client: mockClient);
      final authRes = await service.syncUserAccountTree(
        email: 'bat@readpack.app',
        name: 'Bat-Erdene',
      );
      expect(authRes, isNotNull);
      expect(authRes!['status'], 'authenticated');

      final books = await service.fetchBooks();
      final syncRes = await service.syncUserReadingToTree(
        userIdOrEmail: 'bat@readpack.app',
        book: books.first,
      );
      expect(syncRes, isNotNull);
      expect(syncRes!['source'], 'central_db');
    });
  });
}
