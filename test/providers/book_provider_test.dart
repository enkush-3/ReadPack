import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BookProvider', () {
    test('Initializes with books and default bookmarks', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.books.isNotEmpty, true);
      expect(provider.featuredBooks.length, lessThanOrEqualTo(4));
      expect(provider.bookmarks.isNotEmpty, true);
      expect(provider.recentSearches.isNotEmpty, true);
    });

    test('toggleSaveBook toggles saved state and updates savedBooks', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final firstBook = provider.books.first;
      final initialSaved = firstBook.isSaved;

      provider.toggleSaveBook(firstBook.id);
      final updatedBook = provider.books.firstWhere((b) => b.id == firstBook.id);
      expect(updatedBook.isSaved, !initialSaved);

      if (!initialSaved) {
        expect(provider.savedBooks.any((b) => b.id == firstBook.id), true);
      }
    });

    test('toggleFavoriteBook toggles favorite state', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final book = provider.books.first;
      final initialFav = book.isFavorite;

      provider.toggleFavoriteBook(book.id);
      final updated = provider.books.firstWhere((b) => b.id == book.id);
      expect(updated.isFavorite, !initialFav);
    });

    test('updateReadingProgress updates progress and user stats', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final book = provider.books.first;
      final initialMinutes = provider.userProfile.minutesReadToday;

      provider.updateReadingProgress(book.id, 50, 0.45);
      final updated = provider.books.firstWhere((b) => b.id == book.id);

      expect(updated.currentPage, 50);
      expect(updated.progress, 0.45);
      expect(provider.userProfile.minutesReadToday, initialMinutes + 1);
    });

    test('addBookmark and removeBookmark manage quotes list', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

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
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setSearchQuery('Orwell');
      expect(provider.searchResults.any((b) => b.title.contains('1984')), true);

      provider.setSearchQuery('non_existent_book_query_xyz');
      expect(provider.searchResults.isEmpty, true);

      provider.setSearchQuery('');
      expect(provider.searchResults.length, provider.books.length);
    });

    test('Sorting by rating and title works', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setSearchQuery('');
      provider.applyFilters(sortBy: 'rating');
      final ratingSorted = provider.searchResults;
      for (int i = 0; i < ratingSorted.length - 1; i++) {
        expect(ratingSorted[i].rating >= ratingSorted[i + 1].rating, true);
      }

      provider.applyFilters(sortBy: 'title');
      final titleSorted = provider.searchResults;
      for (int i = 0; i < titleSorted.length - 1; i++) {
        expect(titleSorted[i].title.compareTo(titleSorted[i + 1].title) <= 0, true);
      }
    });

    test('Recent searches can be added, deduplicated, and cleared', () async {
      final provider = BookProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setSearchQuery('Dostoevsky');
      expect(provider.recentSearches.first, 'Dostoevsky');

      provider.removeRecentSearch('Dostoevsky');
      expect(provider.recentSearches.contains('Dostoevsky'), false);

      provider.clearRecentSearches();
      expect(provider.recentSearches.isEmpty, true);
    });
  });
}
