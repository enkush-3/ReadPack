import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/helpers/book_data_loader.dart';
import 'package:readpack/core/providers/helpers/book_provider_persistence.dart';
import 'package:readpack/data/book_repository.dart';
import 'package:readpack/data/services/book_api_service.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/collection.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:readpack/models/user_stats.dart';
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
      expect(provider.savedBooks, isEmpty);
      expect(provider.continueReadingBooks, isEmpty);
      expect(provider.books.every((book) => !book.isFavorite), isTrue);
    });

    test('retryInitialization recovers from an initialization error', () async {
      SharedPreferences.setMockInitialValues({
        BookProviderPersistence.storageKey(
          BookProviderPersistence.keyBookmarks,
        ): [
          'invalid-json',
        ],
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
      'service fallback keeps catalog errors available for search retry',
      () async {
        final service = BookApiService(
          client: MockClient((request) async {
            throw http.ClientException('Catalog offline', request.url);
          }),
        );
        final provider = BookProvider(apiService: service);
        await provider.initialized;

        await provider.fetchRemoteBooks(query: 'unknown search phrase');

        expect(provider.remoteBooksErrorMessage, contains('Catalog offline'));
        expect(provider.errorMessage, isNull);
        expect(provider.books, isNotEmpty);
      },
    );

    test('new search requests supersede stale remote results', () async {
      final service = _ControllableBookApiService();
      final oldResponse = Completer<List<Book>>();
      final currentResponse = Completer<List<Book>>();
      service.pendingResponses['old query'] = oldResponse;
      service.pendingResponses['current query'] = currentResponse;
      final provider = BookProvider(apiService: service);
      await provider.initialized;
      final template = BookRepository.getInitialBooks().first;
      final oldBook = template.copyWith(
        id: 'remote-old-result',
        title: 'Old Query Result',
      );
      final currentBook = template.copyWith(
        id: 'remote-current-result',
        title: 'Current Query Result',
      );

      provider.setSearchQuery('old query');
      provider.setSearchQuery('current query');
      expect(provider.isFetchingRemote, isTrue);

      oldResponse.complete([oldBook]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(provider.books.any((book) => book.id == oldBook.id), isFalse);
      expect(provider.isFetchingRemote, isTrue);

      currentResponse.complete([currentBook]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(provider.books.any((book) => book.id == currentBook.id), isTrue);
      expect(provider.isFetchingRemote, isFalse);
      provider.dispose();
    });

    test('reset filters invalidates an in-flight search', () async {
      final service = _ControllableBookApiService();
      final pendingResponse = Completer<List<Book>>();
      service.pendingResponses['pending query'] = pendingResponse;
      final provider = BookProvider(apiService: service);
      await provider.initialized;
      final staleBook = BookRepository.getInitialBooks().first.copyWith(
        id: 'remote-reset-result',
        title: 'Stale Search Result',
      );

      provider.setSearchQuery('pending query');
      expect(provider.isFetchingRemote, isTrue);
      provider.resetFilters();
      expect(provider.isFetchingRemote, isFalse);

      pendingResponse.complete([staleBook]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.searchQuery, isEmpty);
      expect(provider.books.any((book) => book.id == staleBook.id), isFalse);
      expect(provider.isFetchingRemote, isFalse);
      provider.dispose();
    });

    test(
      'cleared activity lists stay empty after restarting provider',
      () async {
        final createdAt = DateTime.utc(2026, 1, 1);
        SharedPreferences.setMockInitialValues({
          BookProviderPersistence.storageKey(
            BookProviderPersistence.keyBookmarks,
          ): [
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
          BookProviderPersistence.storageKey(
            BookProviderPersistence.keyNotifications,
          ): [
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
          BookProviderPersistence.storageKey(
            BookProviderPersistence.keyCollections,
          ): [
            jsonEncode(
              BookCollection(
                id: 'collection-1',
                name: 'Test collection',
                createdAt: createdAt,
              ).toJson(),
            ),
          ],
          BookProviderPersistence.storageKey(
            BookProviderPersistence.keyRecentSearches,
          ): [
            'Persisted search',
          ],
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

    test('local reading state is isolated between accounts', () async {
      final curated = (await BookDataLoader.loadInitialState()).books.first;
      final remoteBook = curated.copyWith(
        id: 'account-private-remote-book',
        title: 'Private Remote Book',
        isSaved: true,
        isFavorite: true,
        progress: 0.42,
        currentPage: 58,
      );

      await BookProviderPersistence.persistSavedBooks([
        curated.copyWith(isSaved: true),
        remoteBook,
      ], userId: 'reader-a');
      await BookProviderPersistence.persistFavorites([
        curated.copyWith(isFavorite: true),
        remoteBook,
      ], userId: 'reader-a');
      await BookProviderPersistence.persistReadingProgress([
        curated.copyWith(progress: 0.42, currentPage: 58),
        remoteBook,
      ], userId: 'reader-a');
      await BookProviderPersistence.persistRemoteUserBooks([
        remoteBook,
      ], userId: 'reader-a');

      final ownerState = await BookDataLoader.loadInitialState(
        userId: 'reader-a',
      );
      final otherState = await BookDataLoader.loadInitialState(
        userId: 'reader-b',
      );
      final ownerRemoteBook = ownerState.books.firstWhere(
        (book) => book.id == remoteBook.id,
      );
      final otherCuratedBook = otherState.books.firstWhere(
        (book) => book.id == curated.id,
      );

      expect(ownerRemoteBook.progress, 0.42);
      expect(ownerRemoteBook.isSaved, isTrue);
      expect(otherState.books.any((book) => book.id == remoteBook.id), isFalse);
      expect(otherCuratedBook.progress, 0);
      expect(otherCuratedBook.isSaved, isFalse);
      expect(otherCuratedBook.isFavorite, isFalse);
    });

    test('legacy activity moves only to its recorded account owner', () async {
      final curated = BookRepository.getInitialBooks().first;
      final previousOwner = UserProfile.freshUser(
        name: 'Reader A',
        email: 'reader-a@example.com',
        userId: 'reader-a',
      );
      SharedPreferences.setMockInitialValues({
        BookProviderPersistence.keyUserProfile: jsonEncode(
          previousOwner.toJson(),
        ),
        BookProviderPersistence.keySavedBooks: [curated.id],
        BookProviderPersistence.keyRecentSearches: ['legacy search'],
        BookProviderPersistence.keyReadingProgress: jsonEncode({
          curated.id: {'progress': 0.5, 'currentPage': 40, 'chapterIndex': 1},
        }),
      });

      await BookProviderPersistence.migrateLegacyActivityToAccount('reader-a');
      final migratedState = await BookDataLoader.loadInitialState(
        userId: 'reader-a',
      );
      final otherState = await BookDataLoader.loadInitialState(
        userId: 'reader-b',
      );
      final migratedBook = migratedState.books.firstWhere(
        (book) => book.id == curated.id,
      );

      expect(migratedBook.isSaved, isTrue);
      expect(migratedBook.progress, 0.5);
      expect(migratedState.recentSearches, ['legacy search']);
      expect(otherState.books.first.isSaved, isFalse);
      expect(otherState.recentSearches, isEmpty);
      expect(
        (await SharedPreferences.getInstance()).getStringList(
          BookProviderPersistence.keySavedBooks,
        ),
        isNull,
      );

      await BookProviderPersistence.migrateLegacyActivityToAccount('reader-b');
      final laterAccountState = await BookDataLoader.loadInitialState(
        userId: 'reader-b',
      );
      expect(laterAccountState.recentSearches, isEmpty);
      expect(laterAccountState.books.first.isSaved, isFalse);
    });

    test(
      'legacy activity stays quarantined from a different account',
      () async {
        final curated = BookRepository.getInitialBooks().first;
        final previousOwner = UserProfile.freshUser(
          name: 'Reader A',
          email: 'reader-a@example.com',
          userId: 'reader-a',
        );
        final newOwner = UserProfile.freshUser(
          name: 'Reader B',
          email: 'reader-b@example.com',
          userId: 'reader-b',
        );
        SharedPreferences.setMockInitialValues({
          BookProviderPersistence.keyUserProfile: jsonEncode(
            previousOwner.toJson(),
          ),
          BookProviderPersistence.keySavedBooks: [curated.id],
          BookProviderPersistence.keyRecentSearches: ['reader-a search'],
        });

        await BookProviderPersistence.migrateLegacyActivityToAccount(
          'reader-b',
        );
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList(BookProviderPersistence.keyRecentSearches), [
          'reader-a search',
        ]);
        await prefs.setString(
          BookProviderPersistence.keyUserProfile,
          jsonEncode(newOwner.toJson()),
        );
        await BookProviderPersistence.migrateLegacyActivityToAccount(
          'reader-b',
        );

        final laterAccountState = await BookDataLoader.loadInitialState(
          userId: 'reader-b',
        );
        expect(laterAccountState.recentSearches, isEmpty);
        expect(laterAccountState.books.first.isSaved, isFalse);

        await BookProviderPersistence.migrateLegacyActivityToAccount(
          'reader-a',
        );
        final originalOwnerState = await BookDataLoader.loadInitialState(
          userId: 'reader-a',
        );
        expect(originalOwnerState.recentSearches, ['reader-a search']);
        expect(
          originalOwnerState.books
              .firstWhere((book) => book.id == curated.id)
              .isSaved,
          isTrue,
        );
      },
    );

    test(
      'ambiguous guest activity remains quarantined after sign-in',
      () async {
        final guestProfile = UserProfile.freshUser(
          name: 'Зочин',
          email: '',
          username: '@guest',
        ).copyWith(isGuest: true);
        final newOwner = UserProfile.freshUser(
          name: 'Reader B',
          email: 'reader-b@example.com',
          userId: 'reader-b',
        );
        SharedPreferences.setMockInitialValues({
          BookProviderPersistence.keyUserProfile: jsonEncode(
            guestProfile.toJson(),
          ),
          BookProviderPersistence.keyRecentSearches: ['unowned search'],
        });

        await BookProviderPersistence.migrateLegacyActivityToAccount(
          'reader-b',
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          BookProviderPersistence.keyUserProfile,
          jsonEncode(newOwner.toJson()),
        );
        await BookProviderPersistence.migrateLegacyActivityToAccount(
          'reader-b',
        );

        final accountState = await BookDataLoader.loadInitialState(
          userId: 'reader-b',
        );
        expect(accountState.recentSearches, isEmpty);
        expect(prefs.getStringList(BookProviderPersistence.keyRecentSearches), [
          'unowned search',
        ]);
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
  final Map<String, Completer<List<Book>>> pendingResponses = {};

  @override
  Future<List<Book>> fetchBooks({
    String query = '',
    bool preferCentralBackend = true,
  }) async {
    if (shouldFailFetchBooks) throw StateError('catalog unavailable');
    final pendingResponse = pendingResponses[query];
    if (pendingResponse != null) return pendingResponse.future;
    return [];
  }
}
