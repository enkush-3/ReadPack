import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/helpers/book_gamification_manager.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/user_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Collections, Gamification & Search Intelligence Tests', () {
    late BookProvider provider;

    setUp(() async {
      provider = BookProvider();
      await provider.initialized;
    });

    test('does not invent weekly reading minutes for an empty history', () {
      final profile = UserProfile.freshUser(
        name: 'Reader',
        email: 'reader@example.com',
      ).copyWith(weeklyMinutes: const []);

      final updated = BookGamificationManager.addReadingMinutes(profile, 1);

      expect(updated.weeklyMinutes.reduce((a, b) => a + b), 1);
    });

    test('starts with no collections and grants XP on creation', () {
      expect(provider.collections, isEmpty);
      final initialCount = provider.collections.length;
      final initialXp = provider.userProfile.xp;

      provider.createCollection(
        'Миний шилдэг санхүүгийн номууд',
        'Хөрөнгө оруулалт болон хувьцааны тухай',
        icon: '💎',
      );

      expect(provider.collections.length, initialCount + 1);
      expect(provider.userProfile.xp, initialXp + 30);
    });

    test('Adding and removing books from collection updates book list', () {
      provider.createCollection('Reading list', 'Books to read next');
      final initialCollection = provider.collections.first;
      final book = provider.books.first;

      provider.addBookToCollection(initialCollection.id, book.id);
      final updatedColl = provider.collections.firstWhere(
        (c) => c.id == initialCollection.id,
      );
      expect(updatedColl.bookIds.contains(book.id), isTrue);

      provider.removeBookFromCollection(initialCollection.id, book.id);
      final removedColl = provider.collections.firstWhere(
        (c) => c.id == initialCollection.id,
      );
      expect(removedColl.bookIds.contains(book.id), isFalse);
    });

    test('deleting the last collection stays deleted after restart', () async {
      provider.createCollection(
        'Түр зуурын цуглуулга',
        'Удахгүй устгана',
        icon: '🗑️',
      );
      final created = provider.collections.firstWhere(
        (c) => c.name == 'Түр зуурын цуглуулга',
      );
      provider.deleteCollection(created.id);
      await Future<void>.delayed(Duration.zero);

      final restartedProvider = BookProvider();
      await restartedProvider.initialized;

      expect(provider.collections, isEmpty);
      expect(restartedProvider.collections, isEmpty);
    });

    test('Offline download toggle updates downloadedBookIds and awards XP', () {
      final book = provider.books.first;
      final initialXp = provider.userProfile.xp;

      expect(provider.isBookDownloaded(book.id), isFalse);

      provider.toggleDownloadBook(book.id);
      expect(provider.isBookDownloaded(book.id), isTrue);
      expect(provider.userProfile.xp, initialXp + 20);

      final sizeMb = provider.getDownloadedSizeMb(book.id);
      expect(sizeMb, greaterThan(8.0));

      provider.toggleDownloadBook(book.id);
      expect(provider.isBookDownloaded(book.id), isFalse);
    });

    test('Review helpful toggle increments and decrements helpful count', () {
      final book = provider.books.first;
      expect(book.reviews.isNotEmpty, isTrue);
      final review = book.reviews.first;
      final initialHelpful = review.helpfulCount;

      provider.toggleReviewHelpful(book.id, review.id);
      var updatedBook = provider.books.firstWhere((b) => b.id == book.id);
      var updatedReview = updatedBook.reviews.firstWhere(
        (r) => r.id == review.id,
      );
      expect(updatedReview.helpfulCount, initialHelpful + 1);
      expect(updatedReview.isHelpful, isTrue);

      provider.toggleReviewHelpful(book.id, review.id);
      updatedBook = provider.books.firstWhere((b) => b.id == book.id);
      updatedReview = updatedBook.reviews.firstWhere((r) => r.id == review.id);
      expect(updatedReview.helpfulCount, initialHelpful);
      expect(updatedReview.isHelpful, isFalse);
    });

    test('In-book chapter search finds matching chapter snippets', () {
      final bookWithChapters = provider.books.firstWhere(
        (b) => b.chapters.isNotEmpty,
      );
      final queryWord = bookWithChapters.chapters.first.title.split(' ').first;

      final matches = provider.getChapterMatchesForBook(
        bookWithChapters.id,
        queryWord,
      );
      expect(matches.isNotEmpty, isTrue);
      expect(matches.first['chapterTitle'], contains(queryWord));
    });

    test('User level titles scale correctly with XP', () {
      expect(provider.userLevelTitle, contains('Lv.'));

      provider.addXp(3500);
      expect(provider.userProfile.xp, greaterThanOrEqualTo(3000));
      expect(provider.userLevelTitle, contains('Lv. 4'));
    });

    test(
      'Fuzzy search matches misspelled titles and authors (Сапенс and Stve)',
      () {
        provider.setSearchQuery('Сапенс');
        final suggestion1 = provider.searchSuggestion;
        expect(suggestion1, isNotNull);
        expect(suggestion1, contains('Сапиенс'));

        final results1 = provider.searchResults;
        expect(
          results1.any(
            (b) => b.id == 'book_sapiens' || b.title.contains('Sapiens'),
          ),
          isTrue,
        );

        provider.setSearchQuery('Stve');
        final suggestion2 = provider.searchSuggestion;
        expect(suggestion2, isNotNull);
        expect(
          suggestion2!.toLowerCase(),
          anyOf(contains('steve'), contains('stephen')),
        );

        final results2 = provider.searchResults;
        expect(
          results2.any(
            (b) =>
                b.title.toLowerCase().contains('steve') ||
                b.author.toLowerCase().contains('stephen') ||
                b.author.toLowerCase().contains('steven'),
          ),
          isTrue,
        );
      },
    );

    test('addReadingMinutes grants XP and daily goal bonus', () {
      final initialXp = provider.userProfile.xp;
      final initialMinutes = provider.userProfile.minutesReadToday;

      // Add 2 minutes: 2 * 5 = 10 XP
      provider.addReadingMinutes(2);
      expect(provider.userProfile.xp, initialXp + 10);
      expect(provider.userProfile.minutesReadToday, initialMinutes + 2);

      // Now add minutes to reach past 30-min goal (crosses 30-min goal)
      final neededToCrossGoal =
          (provider.userProfile.dailyGoalMinutes -
              provider.userProfile.minutesReadToday) +
          1;
      provider.addReadingMinutes(neededToCrossGoal);
      expect(
        provider.userProfile.xp,
        initialXp + 10 + (neededToCrossGoal * 5) + 50,
      );
      expect(
        provider.userProfile.minutesReadToday,
        initialMinutes + 2 + neededToCrossGoal,
      );
    });

    test(
      'totalDownloadedStorageMb correctly calculates sum of downloaded book sizes',
      () {
        final initialStorage = provider.totalDownloadedStorageMb;

        final nonDownloadedBook = provider.books.firstWhere(
          (b) => !provider.isBookDownloaded(b.id),
        );

        provider.toggleDownloadBook(nonDownloadedBook.id);
        final addedSize = provider.getDownloadedSizeMb(nonDownloadedBook.id);
        expect(
          provider.totalDownloadedStorageMb,
          closeTo(initialStorage + addedSize, 0.01),
        );

        provider.toggleDownloadBook(nonDownloadedBook.id);
        expect(
          provider.totalDownloadedStorageMb,
          closeTo(initialStorage, 0.01),
        );
      },
    );

    test('UserLevelTitle reaches Lv. 5 Мэргэн уншигч at 5000+ XP', () {
      provider.addXp(5500);
      expect(provider.userLevel, 5);
      expect(provider.userLevelTitle, 'Мэргэн уншигч (Lv. 5)');
    });

    test('Custom bookmark highlight colors persist and preserve colorHex', () {
      final book = provider.books.first;
      final bookmark = Bookmark(
        id: 'bm_test_color',
        bookId: book.id,
        bookTitle: book.title,
        chapterTitle: 'Chapter 1',
        pageNumber: 1,
        quote: 'This is a highlighted wisdom quote.',
        note: 'Important reflection',
        colorHex: 0xFF4CAF50, // Green highlight
        createdAt: DateTime.now(),
      );
      provider.addBookmark(bookmark);

      expect(provider.bookmarks.isNotEmpty, isTrue);
      final bm = provider.bookmarks.firstWhere((b) => b.id == 'bm_test_color');
      expect(bm.colorHex, 0xFF4CAF50);
    });
  });
}
