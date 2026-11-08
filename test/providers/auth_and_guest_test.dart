import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BookProvider Auth & Guest Mode', () {
    late BookProvider provider;

    setUp(() {
      provider = BookProvider();
    });

    test('loginAsGuest initializes guest profile correctly', () {
      provider.loginAsGuest();

      expect(provider.userProfile.isGuest, isTrue);
      expect(provider.userProfile.name, 'Зочин');
      expect(provider.userProfile.email, 'guest@readpack.app');
      expect(provider.userProfile.streakDays, greaterThanOrEqualTo(0));
    });

    test('loginWithEmail transitions from guest to registered user', () {
      provider.loginAsGuest();
      expect(provider.userProfile.isGuest, isTrue);

      provider.loginWithEmail('user@test.com', 'Bat-Erdene');

      expect(provider.userProfile.isGuest, isFalse);
      expect(provider.userProfile.name, 'Bat-Erdene');
      expect(provider.userProfile.email, 'user@test.com');
    });

    test('logout resets user session to guest state', () {
      provider.loginWithEmail('vip@user.com', 'VIP User');
      expect(provider.userProfile.isGuest, isFalse);

      provider.logout();

      expect(provider.userProfile.isGuest, isTrue);
      expect(provider.userProfile.name, 'Зочин');
    });

    test('updateUserProfile modifies user preferences and daily goal', () {
      provider.updateUserProfile(
        name: 'Saraa',
        dailyGoalMinutes: 45,
        notificationsEnabled: false,
        recommendationsEnabled: false,
        streakFreezeAvailable: false,
      );

      expect(provider.userProfile.name, 'Saraa');
      expect(provider.userProfile.dailyGoalMinutes, 45);
      expect(provider.userProfile.notificationsEnabled, isFalse);
      expect(provider.userProfile.recommendationsEnabled, isFalse);
      expect(provider.userProfile.streakFreezeAvailable, isFalse);
    });

    test('clearCache resets search history', () {
      provider.commitSearchQuery('Psychology');
      expect(provider.recentSearches, contains('Psychology'));

      provider.clearCache();

      expect(provider.recentSearches, isEmpty);
    });

    test('addReview adds review and recalculates book rating', () {
      final initialBook = provider.books.first;
      final initialReviewsCount = initialBook.reviewsCount;

      final review = BookReview(
        id: 'rev_test_1',
        userName: 'New Reviewer',
        rating: 5.0,
        comment: 'Great read!',
        createdAt: DateTime.now(),
      );

      provider.addReview(initialBook.id, review);

      final updatedBook = provider.books.firstWhere((b) => b.id == initialBook.id);
      expect(updatedBook.reviewsCount, initialReviewsCount + 1);
      expect(updatedBook.reviews.any((r) => r.id == 'rev_test_1'), isTrue);
    });
  });
}
