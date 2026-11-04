import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/data/book_repository.dart';

void main() {
  group('BookRepository Dataset Verification', () {
    test('contains at least 16 curated books', () {
      final books = BookRepository.getInitialBooks();
      expect(books.length, greaterThanOrEqualTo(16));
    });

    test('all books have valid required metadata', () {
      final books = BookRepository.getInitialBooks();
      for (final book in books) {
        expect(book.id, isNotEmpty);
        expect(book.title, isNotEmpty);
        expect(book.author, isNotEmpty);
        expect(book.description, isNotEmpty);
        expect(book.rating, inInclusiveRange(1.0, 5.0));
        expect(book.reviewsCount, greaterThan(0));
        expect(book.category, isNotEmpty);
        expect(book.pages, greaterThan(0));
        expect(book.readTimeMinutes, greaterThan(0));
      }
    });

    test('books have audio support metadata and duration', () {
      final books = BookRepository.getInitialBooks();
      final audioBooks = books.where((b) => b.hasAudio).toList();

      expect(audioBooks.isNotEmpty, isTrue);
      for (final book in audioBooks) {
        expect(book.audioDurationMinutes, greaterThan(0));
      }
    });

    test('all books include chapters with readable content', () {
      final books = BookRepository.getInitialBooks();
      for (final book in books) {
        expect(book.chapters, isNotEmpty);
        for (final chapter in book.chapters) {
          expect(chapter.id, isNotEmpty);
          expect(chapter.title, isNotEmpty);
          expect(chapter.content.trim(), isNotEmpty);
          expect(chapter.estimatedMinutes, greaterThan(0));
        }
      }
    });

    test('all books have key takeaways and sample reviews', () {
      final books = BookRepository.getInitialBooks();
      for (final book in books) {
        expect(book.keyTakeaways, isNotEmpty);
        expect(book.reviews, isNotEmpty);
        for (final review in book.reviews) {
          expect(review.id, isNotEmpty);
          expect(review.userName, isNotEmpty);
          expect(review.comment, isNotEmpty);
          expect(review.rating, inInclusiveRange(1.0, 5.0));
        }
      }
    });
  });
}
