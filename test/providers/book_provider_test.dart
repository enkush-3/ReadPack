import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/helpers/book_provider_persistence.dart';
import 'package:readpack/data/services/book_api_service.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/collection.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BookProvider', () {
    test('fresh install has no fabricated personal activity', () async {
      final provider = BookProvider();
      await provider.initialized;

      expect(provider.books, isNotEmpty);
      expect(provider.featuredBooks.length, lessThanOrEqualTo(4));
      expect(provider.bookmarks, isEmpty);
      expect(provider.notifications, isEmpty);
      expect(provider.collections, isEmpty);
      expect(provider.recentSearches, isEmpty);
    });

    test('retryInitialization recovers from an initialization error', () async {
      SharedPreferences.setMockInitialValues({
        BookProviderPersistence.keyBookmarks: ['invalid-json'],
      });
      final provider = BookProvider();
      final firstInitialization = provider.initialized;

      expect(provider.retryInitialization(), same(firstInitialization));
      await firstInitialization;
      expect(provider.errorMessage, isNotNull);

      SharedPreferences.setMockInitialValues({});
      await provider.retryInitialization();

      expect(provider.errorMessage, isNull);
      expect(provider.books, isNotEmpty);
      expect(provider.bookmarks, isEmpty);
    });

    test(
      'remote fetch errors stay separate from local initialization data',
      () async {
        final apiService = _ControllableBookApiService();
        final provider = BookProvider(apiService: apiService);
        await provider.initialized;
        final localBooks = provider.books;

        apiService.shouldFailFetchBooks = true;
        await provider.fetchRemoteBooks();

        expect(
          provider.remoteBooksErrorMessage,
          contains('catalog unavailable'),
        );
        expect(provider.errorMessage, isNull);
        expect(provider.books, same(localBooks));

        apiService.shouldFailFetchBooks = false;
        await provider.fetchRemoteBooks();

        expect(provider.remoteBooksErrorMessage, isNull);
        expect(provider.books, same(localBooks));
      },
    );

    test(
      'cleared activity lists stay empty after restarting provider',
      () async {
        final createdAt = DateTime.utc(2026, 1, 1);
        SharedPreferences.setMockInitialValues({
          BookProviderPersistence.keyBookmarks: [
            jsonEncode(
              Bookmark(
                id: 'bookmark-1',
                bookId: 'book-1',
                bookTitle: 'Test Book',
                chapterTitle: 'Chapter 1',
                pageNumber: 4,
                quote: 'A saved quote.',
                createdAt: createdAt,
              ).toJson(),
            ),
          ],
          BookProviderPersistence.keyNotifications: [
            jsonEncode(
              NotificationItem(
                id: 'notification-1',
                title: 'Test notification',
                message: 'A test message.',
                time: 'Just now',
                type: 'system',
                createdAt: createdAt,
              ).toJson(),
            ),
          ],
          BookProviderPersistence.keyCollections: [
            jsonEncode(
              BookCollection(
                id: 'collection-1',
                name: 'Test collection',
                createdAt: createdAt,
              ).toJson(),
            ),
          ],
          BookProviderPersistence.keyRecentSearches: ['Persisted search'],
        });

        final provider = BookProvider();
        await provider.initialized;

        expect(provider.bookmarks, hasLength(1));
        expect(provider.notifications, hasLength(1));
        expect(provider.collections, hasLength(1));
        expect(provider.recentSearches, ['Persisted search']);

        provider.removeBookmark('bookmark-1');
        provider.clearAllNotifications();
        provider.deleteCollection('collection-1');
        provider.clearRecentSearches();
        await Future<void>.delayed(Duration.zero);

        final restartedProvider = BookProvider();
        await restartedProvider.initialized;

        expect(restartedProvider.bookmarks, isEmpty);
        expect(restartedProvider.notifications, isEmpty);
        expect(restartedProvider.collections, isEmpty);
        expect(restartedProvider.recentSearches, isEmpty);
      },
    );

    test(
      'rapid remote save, favorite, and reading changes survive restart',
      () async {
        final client = MockClient((request) async {
          final remoteResponse = {
            'docs': [
              {
                'key': '/works/OL123W',
                'title': 'Remote Catalog Story',
                'author_name': ['Reader Author'],
                'cover_i': 123,
                'number_of_pages_median': 180,
              },
            ],
          };
          return http.Response(jsonEncode(remoteResponse), 200);
        });
        final apiService = BookApiService(
          client: client,
          backendBaseUrl: 'http://catalog.test/api/v1',
        );
        final provider = BookProvider(apiService: apiService);
        await provider.initialized;
        await provider.fetchRemoteBooks(query: 'Remote Catalog Story');
        await Future.wait([
          provider.toggleSaveBook('ol_OL123W'),
          provider.toggleFavoriteBook('ol_OL123W'),
          provider.updateReadingPosition(
            'ol_OL123W',
            currentPage: 58,
            progress: 0.32,
          ),
          provider.updateReadingProgress('ol_OL123W', 72, 0.42),
        ]);

        final restartedProvider = BookProvider(
          apiService: BookApiService(
            client: client,
            backendBaseUrl: 'http://catalog.test/api/v1',
          ),
        );
        await restartedProvider.initialized;

        final restoredBook = restartedProvider.books.firstWhere(
          (book) => book.id == 'ol_OL123W',
        );
        expect(restoredBook.isSaved, isTrue);
        expect(restoredBook.isFavorite, isTrue);
        expect(restoredBook.progress, 0.42);
        expect(restoredBook.currentPage, 72);
      },
    );

    test('toggleSaveBook toggles saved state and updates savedBooks', () async {
      final provider = BookProvider();
      await provider.initialized;

      final firstBook = provider.books.first;
      final initialSaved = firstBook.isSaved;

      await provider.toggleSaveBook(firstBook.id);
      final updatedBook = provider.books.firstWhere(
        (b) => b.id == firstBook.id,
      );
      expect(updatedBook.isSaved, !initialSaved);

      if (!initialSaved) {
        expect(provider.savedBooks.any((b) => b.id == firstBook.id), true);
      }
    });

    test('toggleFavoriteBook toggles favorite state', () async {
      final provider = BookProvider();
      await provider.initialized;

      final book = provider.books.first;
      final initialFav = book.isFavorite;

      await provider.toggleFavoriteBook(book.id);
      final updated = provider.books.firstWhere((b) => b.id == book.id);
      expect(updated.isFavorite, !initialFav);
    });

    test('updateReadingProgress updates progress and user stats', () async {
      final provider = BookProvider();
      await provider.initialized;

      final book = provider.books.first;
      final initialMinutes = provider.userProfile.minutesReadToday;

      await provider.updateReadingProgress(book.id, 50, 0.45);
      final updated = provider.books.firstWhere((b) => b.id == book.id);

      expect(updated.currentPage, 50);
      expect(updated.progress, 0.45);
      expect(provider.userProfile.minutesReadToday, initialMinutes + 1);
    });

    test('addBookmark and removeBookmark manage quotes list', () async {
      final provider = BookProvider();
      await provider.initialized;

      final initialCount = provider.bookmarks.length;
      final newBookmark = Bookmark(
        id: 'test_bm_99',
        bookId: 'b1',
        bookTitle: 'Test Book',
        chapterTitle: 'Chapter 1',
        pageNumber: 5,
        quote: 'This is a memorable quote.',
        createdAt: DateTime.now(),
      );

      provider.addBookmark(newBookmark);
      expect(provider.bookmarks.length, initialCount + 1);
      expect(provider.bookmarks.first.id, 'test_bm_99');

      provider.removeBookmark('test_bm_99');
      expect(provider.bookmarks.length, initialCount);
    });

    test('Live search query filters books accurately', () async {
      final provider = BookProvider();
      await provider.initialized;

      provider.setSearchQuery('Orwell');
      expect(provider.searchResults.any((b) => b.title.contains('1984')), true);

      provider.setSearchQuery('non_existent_book_query_xyz');
      expect(provider.searchResults.isEmpty, true);

      provider.setSearchQuery('');
      expect(provider.searchResults.length, provider.books.length);
    });

    test('Sorting by rating and title works', () async {
      final provider = BookProvider();
      await provider.initialized;

      provider.setSearchQuery('');
      provider.applyFilters(sortBy: 'rating');
      final ratingSorted = provider.searchResults;
      for (int i = 0; i < ratingSorted.length - 1; i++) {
        expect(ratingSorted[i].rating >= ratingSorted[i + 1].rating, true);
      }

      provider.applyFilters(sortBy: 'title');
      final titleSorted = provider.searchResults;
      for (int i = 0; i < titleSorted.length - 1; i++) {
        expect(
          titleSorted[i].title.compareTo(titleSorted[i + 1].title) <= 0,
          true,
        );
      }
    });

    test('Recent searches can be added, deduplicated, and cleared', () async {
      final provider = BookProvider();
      await provider.initialized;

      provider.setSearchQuery('Dostoevsky');
      expect(provider.recentSearches.first, 'Dostoevsky');

      provider.removeRecentSearch('Dostoevsky');
      expect(provider.recentSearches.contains('Dostoevsky'), false);

      provider.clearRecentSearches();
      expect(provider.recentSearches.isEmpty, true);
    });
  });
}

class _ControllableBookApiService extends BookApiService {
  _ControllableBookApiService()
    : super(
        client: MockClient((_) async => http.Response('{}', 200)),
        backendBaseUrl: 'http://catalog.test/api/v1',
      );

  bool shouldFailFetchBooks = false;

  @override
  Future<List<Book>> fetchBooks({
    String query = '',
    bool preferCentralBackend = true,
  }) async {
    if (shouldFailFetchBooks) throw StateError('catalog unavailable');
    return [];
  }
}
