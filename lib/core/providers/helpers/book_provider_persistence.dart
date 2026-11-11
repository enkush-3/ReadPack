import 'dart:convert';
import 'package:readpack/data/services/book_api_service.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/collection.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:readpack/models/user_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookProviderPersistence {
  static const String keySavedBooks = 'readpack_saved_books_ids';
  static const String keyFavorites = 'readpack_favorites_ids';
  static const String keyRecentSearches = 'readpack_recent_searches';
  static const String keyBookmarks = 'readpack_bookmarks';
  static const String keyReadingProgress = 'readpack_book_progress';
  static const String keyUserProfile = 'readpack_user_profile';
  static const String keyNotifications = 'readpack_notifications';
  static const String keyCollections = 'readpack_book_collections';
  static const String keyDownloadedBooks = 'readpack_downloaded_books';

  static Future<void> persistNotifications(
    List<NotificationItem> notifications,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final list = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(keyNotifications, list);
  }

  static Future<void> persistSavedBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = books.where((b) => b.isSaved).map((b) => b.id).toList();
    await prefs.setStringList(keySavedBooks, savedIds);
  }

  static Future<void> persistFavorites(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = books.where((b) => b.isFavorite).map((b) => b.id).toList();
    await prefs.setStringList(keyFavorites, favIds);
  }

  static Future<void> persistRecentSearches(List<String> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyRecentSearches, searches);
  }

  static Future<void> persistBookmarks(List<Bookmark> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = bookmarks.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(keyBookmarks, jsonList);
  }

  static Future<void> persistReadingProgress(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> map = {};
    for (final b in books) {
      if (b.progress > 0) {
        map[b.id] = {
          'progress': b.progress,
          'currentPage': b.currentPage,
          'chapterIndex': b.currentChapterIndex,
        };
      }
    }
    await prefs.setString(keyReadingProgress, jsonEncode(map));
  }

  static Future<void> persistCollections(
    List<BookCollection> collections,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final list = collections.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(keyCollections, list);
  }

  static Future<void> persistDownloadedBooks(Set<String> downloadedIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyDownloadedBooks, downloadedIds.toList());
  }

  static Future<void> persistUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserProfile, jsonEncode(profile.toJson()));
  }

  static Future<void> syncBookReadingNode(
    BookApiService api,
    UserProfile profile,
    List<Book> books,
    String bookId, {
    String shelfId = 'currently_reading',
    String status = 'reading',
    int minutesRead = 0,
    Map<String, dynamic>? highlight,
  }) async {
    final idx = books.indexWhere((b) => b.id == bookId);
    if (idx < 0) return;
    final book = books[idx];
    if (profile.isGuest || profile.userId.isEmpty) return;
    await api.syncUserReadingToTree(
      userIdOrEmail: profile.userId,
      book: book,
      shelfId: shelfId,
      status: status,
      minutesRead: minutesRead,
      highlight: highlight,
    );
  }

  static Future<void> syncProfilePreferences(
    BookApiService api,
    UserProfile profile,
  ) async {
    if (profile.isGuest || profile.userId.isEmpty) return;
    await api.updateUserPreferencesTree(
      userIdOrEmail: profile.userId,
      payload: {
        'displayName': profile.name,
        'dailyGoalMinutes': profile.dailyGoalMinutes,
        'yearlyBookGoal': profile.yearlyGoalBooks,
        'favoriteGenres': profile.favoriteGenres,
        'notificationsEnabled': profile.notificationsEnabled,
        'recommendationsEnabled': profile.recommendationsEnabled,
      },
    );
  }

  static List<Book> rehydrateBooks({
    required List<Book> initialBooks,
    required List<String> savedIds,
    required List<String> favIds,
    required Map<String, dynamic> progressMap,
  }) {
    return initialBooks.map((b) {
      final isSaved = savedIds.contains(b.id) || b.isSaved;
      final isFav = favIds.contains(b.id) || b.isFavorite;
      double progress = b.progress;
      int currentPage = b.currentPage;
      int chapterIdx = b.currentChapterIndex;

      if (progressMap.containsKey(b.id)) {
        final p = progressMap[b.id] as Map<String, dynamic>;
        progress = (p['progress'] as num).toDouble();
        currentPage = (p['currentPage'] as num).toInt();
        if (p['chapterIndex'] != null) {
          chapterIdx = (p['chapterIndex'] as num).toInt();
        }
      }

      return b.copyWith(
        isSaved: isSaved,
        isFavorite: isFav,
        progress: progress,
        currentPage: currentPage,
        currentChapterIndex: chapterIdx,
      );
    }).toList();
  }
}
