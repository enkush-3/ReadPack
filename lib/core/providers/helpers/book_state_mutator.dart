import 'package:readpack/models/book.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:readpack/models/user_stats.dart';

class BookStateMutator {
  static bool toggleSave(List<Book> books, String bookId) {
    final index = books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      books[index] = books[index].copyWith(isSaved: !books[index].isSaved);
      return true;
    }
    return false;
  }

  static bool toggleFavorite(List<Book> books, String bookId) {
    final index = books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      books[index] =
          books[index].copyWith(isFavorite: !books[index].isFavorite);
      return true;
    }
    return false;
  }

  static bool updatePosition(
    List<Book> books,
    String bookId, {
    required int currentPage,
    required double progress,
    int? currentChapterIndex,
  }) {
    final index = books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      books[index] = books[index].copyWith(
        currentPage: currentPage,
        progress: progress.clamp(0.0, 1.0),
        currentChapterIndex:
            currentChapterIndex ?? books[index].currentChapterIndex,
      );
      return true;
    }
    return false;
  }

  static UserProfile updateProgressAndStats(
    List<Book> books,
    UserProfile userProfile,
    String bookId,
    int currentPage,
    double progress, [
    int? currentChapterIndex,
  ]) {
    updatePosition(
      books,
      bookId,
      currentPage: currentPage,
      progress: progress,
      currentChapterIndex: currentChapterIndex,
    );
    return userProfile.copyWith(
      minutesReadToday: userProfile.minutesReadToday + 1,
    );
  }

  static void addReview(List<Book> books, String bookId, BookReview review) {
    final index = books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final currentBook = books[index];
      final updatedReviews = [review, ...currentBook.reviews];
      final newCount = currentBook.reviewsCount + 1;
      final newRating = double.parse(
        (((currentBook.rating * currentBook.reviewsCount) + review.rating) /
                newCount)
            .toStringAsFixed(1),
      );

      books[index] = currentBook.copyWith(
        reviews: updatedReviews,
        reviewsCount: newCount,
        rating: newRating,
      );
    }
  }

  static void updateReview(
      List<Book> books, String bookId, BookReview updatedReview) {
    final index = books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final currentBook = books[index];
      final revIndex =
          currentBook.reviews.indexWhere((r) => r.id == updatedReview.id);
      if (revIndex != -1) {
        final updatedReviews = List<BookReview>.from(currentBook.reviews);
        updatedReviews[revIndex] = updatedReview;
        final totalStars =
            updatedReviews.fold<double>(0.0, (sum, r) => sum + r.rating);
        final newRating = double.parse(
            (totalStars / updatedReviews.length).toStringAsFixed(1));
        books[index] = currentBook.copyWith(
          reviews: updatedReviews,
          rating: newRating,
        );
      }
    }
  }

  static void deleteReview(
      List<Book> books, String bookId, String reviewId) {
    final index = books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final currentBook = books[index];
      final updatedReviews =
          currentBook.reviews.where((r) => r.id != reviewId).toList();
      final newCount = updatedReviews.length;
      final newRating = newCount > 0
          ? double.parse((updatedReviews.fold<double>(
                      0.0, (s, r) => s + r.rating) /
                  newCount)
              .toStringAsFixed(1))
          : 0.0;
      books[index] = currentBook.copyWith(
        reviews: updatedReviews,
        reviewsCount: newCount,
        rating: newRating,
      );
    }
  }

  static bool toggleReviewHelpful(
      List<Book> books, String bookId, String reviewId) {
    final bookIndex = books.indexWhere((b) => b.id == bookId);
    if (bookIndex != -1) {
      final book = books[bookIndex];
      final reviewIndex = book.reviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex != -1) {
        final review = book.reviews[reviewIndex];
        final isNowHelpful = !review.isHelpful;
        final newCount = isNowHelpful
            ? review.helpfulCount + 1
            : (review.helpfulCount - 1).clamp(0, 99999);
        final updatedReview = review.copyWith(
          isHelpful: isNowHelpful,
          helpfulCount: newCount,
        );
        final updatedReviews = List<BookReview>.from(book.reviews);
        updatedReviews[reviewIndex] = updatedReview;
        books[bookIndex] = book.copyWith(reviews: updatedReviews);
        return isNowHelpful;
      }
    }
    return false;
  }

  static bool markNotificationRead(
      List<NotificationItem> notifications, String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      return true;
    }
    return false;
  }

  static List<NotificationItem> markAllNotificationsRead(
      List<NotificationItem> notifications) {
    return notifications.map((n) => n.copyWith(isRead: true)).toList();
  }

  static void deleteNotification(
      List<NotificationItem> notifications, String id) {
    notifications.removeWhere((n) => n.id == id);
  }
}
