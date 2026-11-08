import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/user_stats.dart';

void main() {
  group('Book & BookChapter Models', () {
    test('BookChapter serializes and deserializes correctly', () {
      const chapter = BookChapter(
        id: 'c1',
        title: 'Chapter 1: The Beginning',
        content: 'This is the chapter text content.',
        estimatedMinutes: 6,
      );

      final json = chapter.toJson();
      final fromJson = BookChapter.fromJson(json);

      expect(fromJson.id, 'c1');
      expect(fromJson.title, 'Chapter 1: The Beginning');
      expect(fromJson.content, 'This is the chapter text content.');
      expect(fromJson.estimatedMinutes, 6);
    });

    test('Book serializes and deserializes correctly', () {
      const book = Book(
        id: 'b1',
        title: 'Test Book',
        author: 'Author Name',
        description: 'Test description',
        rating: 4.8,
        reviewsCount: 150,
        category: 'book.categories.business',
        pages: 300,
        readTimeMinutes: 240,
        colorHex: 0xFF182350,
        progress: 0.5,
        currentPage: 150,
        isSaved: true,
        isFavorite: true,
      );

      final json = book.toJson();
      final fromJson = Book.fromJson(json);

      expect(fromJson.id, 'b1');
      expect(fromJson.title, 'Test Book');
      expect(fromJson.author, 'Author Name');
      expect(fromJson.rating, 4.8);
      expect(fromJson.isSaved, true);
      expect(fromJson.isFavorite, true);
      expect(fromJson.progress, 0.5);
    });

    test('Book copyWith updates targeted fields only', () {
      const book = Book(
        id: 'b1',
        title: 'Original',
        author: 'Author',
        description: 'Desc',
        rating: 4.0,
        category: 'Romance',
        pages: 100,
        readTimeMinutes: 60,
        progress: 0.1,
        isSaved: false,
      );

      final updated = book.copyWith(
        title: 'Updated Title',
        isSaved: true,
        progress: 0.8,
      );

      expect(updated.id, 'b1');
      expect(updated.title, 'Updated Title');
      expect(updated.isSaved, true);
      expect(updated.progress, 0.8);
      expect(updated.author, 'Author');
    });
    test('Book supports hasAudio and audioDurationMinutes serialization', () {
      const book = Book(
        id: 'b_audio',
        title: 'Audio Test',
        author: 'Narrator',
        description: 'Audiobook edition',
        rating: 4.9,
        category: 'Non-fiction',
        pages: 250,
        readTimeMinutes: 180,
        hasAudio: true,
        audioDurationMinutes: 18,
      );

      final json = book.toJson();
      final fromJson = Book.fromJson(json);

      expect(fromJson.hasAudio, isTrue);
      expect(fromJson.audioDurationMinutes, 18);

      final updated = book.copyWith(hasAudio: false, audioDurationMinutes: 0);
      expect(updated.hasAudio, isFalse);
      expect(updated.audioDurationMinutes, 0);
    });
  });

  group('Bookmark Model', () {
    test('Bookmark serializes and deserializes correctly', () {
      final now = DateTime.now();
      final bookmark = Bookmark(
        id: 'bm_1',
        bookId: 'b1',
        bookTitle: '1984',
        chapterTitle: 'Chapter 1',
        pageNumber: 12,
        quote: 'War is peace.',
        note: 'Paradox statement',
        colorHex: 0xFFFFD54F,
        createdAt: now,
      );

      final json = bookmark.toJson();
      final fromJson = Bookmark.fromJson(json);

      expect(fromJson.id, 'bm_1');
      expect(fromJson.bookTitle, '1984');
      expect(fromJson.quote, 'War is peace.');
      expect(fromJson.note, 'Paradox statement');
      expect(fromJson.colorHex, 0xFFFFD54F);
    });
  });

  group('UserProfile Model', () {
    test('UserProfile defaults and copyWith work properly', () {
      const profile = UserProfile();
      expect(profile.name, 'Enkush');
      expect(profile.streakDays, 0);
      expect(profile.dailyGoalMinutes, 30);
      expect(profile.isGuest, isFalse);
      expect(profile.streakFreezeAvailable, isTrue);
      expect(profile.notificationsEnabled, isTrue);
      expect(profile.recommendationsEnabled, isTrue);

      final updated = profile.copyWith(
        name: 'Guest User',
        isGuest: true,
        streakDays: 0,
        minutesReadToday: 25,
        notificationsEnabled: false,
        streakFreezeAvailable: false,
      );

      expect(updated.name, 'Guest User');
      expect(updated.isGuest, isTrue);
      expect(updated.streakDays, 0);
      expect(updated.minutesReadToday, 25);
      expect(updated.notificationsEnabled, isFalse);
      expect(updated.streakFreezeAvailable, isFalse);
    });

    test('UserProfile json serialization preserves guest and preference flags', () {
      const profile = UserProfile(
        name: 'Зочин',
        email: 'guest@readpack.app',
        isGuest: true,
        streakDays: 3,
        dailyGoalMinutes: 45,
        streakFreezeAvailable: false,
        notificationsEnabled: false,
        recommendationsEnabled: true,
      );

      final json = profile.toJson();
      final fromJson = UserProfile.fromJson(json);

      expect(fromJson.name, 'Зочин');
      expect(fromJson.email, 'guest@readpack.app');
      expect(fromJson.isGuest, isTrue);
      expect(fromJson.streakDays, 3);
      expect(fromJson.dailyGoalMinutes, 45);
      expect(fromJson.streakFreezeAvailable, isFalse);
      expect(fromJson.notificationsEnabled, isFalse);
      expect(fromJson.recommendationsEnabled, isTrue);
    });
  });
}
