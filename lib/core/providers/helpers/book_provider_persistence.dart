import 'dart:async';
import 'dart:convert';
import 'package:readpack/data/book_repository.dart';
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
  static const String keyRemoteUserBooks = 'readpack_remote_user_books';
  static const String _legacyActivityOwnerKey =
      'readpack_legacy_activity_owner';
  static const String _unknownLegacyActivityOwner = '__unknown_owner__';
  static Future<void>? _remoteUserBooksWrite;

  static String storageKey(String key, {String userId = ''}) {
    final owner = userId.trim().toLowerCase();
    final encodedOwner = owner.isEmpty
        ? 'guest'
        : base64Url.encode(utf8.encode(owner)).replaceAll('=', '');
    return '${key}_$encodedOwner';
  }

  static Future<void> migrateLegacyActivityToAccount(String userId) async {
    final normalizedUserId = userId.trim().toLowerCase();
    if (normalizedUserId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    var migrationOwner = prefs.getString(_legacyActivityOwnerKey);
    if (migrationOwner == null) {
      migrationOwner =
          _readLegacyActivityOwner(prefs) ?? _unknownLegacyActivityOwner;
      await prefs.setString(_legacyActivityOwnerKey, migrationOwner);
    }
    if (migrationOwner != normalizedUserId) return;

    await _copyLegacyActivity(prefs, normalizedUserId);
    await _removeLegacyActivity(prefs);
  }

  static String? _readLegacyActivityOwner(SharedPreferences prefs) {
    try {
      final profileJson = prefs.getString(keyUserProfile);
      if (profileJson == null) return null;
      final profile = UserProfile.fromJson(
        jsonDecode(profileJson) as Map<String, dynamic>,
      );
      final userId = profile.userId.trim();
      if (profile.isGuest || userId.isEmpty) return null;
      return userId.toLowerCase();
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static const List<String> _legacyActivityKeys = [
    keySavedBooks,
    keyFavorites,
    keyRecentSearches,
    keyBookmarks,
    keyReadingProgress,
    keyNotifications,
    keyCollections,
    keyDownloadedBooks,
    keyRemoteUserBooks,
  ];

  static Future<void> _copyLegacyActivity(
    SharedPreferences prefs,
    String userId,
  ) async {
    for (final key in _legacyActivityKeys) {
      await _copyLegacyPreference(prefs, key, userId);
    }
  }

  static Future<void> _copyLegacyPreference(
    SharedPreferences prefs,
    String key,
    String userId,
  ) async {
    final accountKey = storageKey(key, userId: userId);
    if (prefs.containsKey(accountKey)) return;
    if (key == keyReadingProgress) {
      await _copyLegacyString(prefs, key, accountKey);
      return;
    }
    await _copyLegacyStringList(prefs, key, accountKey);
  }

  static Future<void> _copyLegacyString(
    SharedPreferences prefs,
    String legacyKey,
    String accountKey,
  ) async {
    final value = prefs.getString(legacyKey);
    if (value == null) return;
    if (!await prefs.setString(accountKey, value)) {
      throw StateError('Could not migrate legacy activity: $legacyKey');
    }
  }

  static Future<void> _copyLegacyStringList(
    SharedPreferences prefs,
    String legacyKey,
    String accountKey,
  ) async {
    final values = prefs.getStringList(legacyKey);
    if (values == null) return;
    if (!await prefs.setStringList(accountKey, values)) {
      throw StateError('Could not migrate legacy activity: $legacyKey');
    }
  }

  static Future<void> _removeLegacyActivity(SharedPreferences prefs) async {
    for (final key in _legacyActivityKeys) {
      await prefs.remove(key);
    }
  }

  static Future<void> persistNotifications(
    List<NotificationItem> notifications, {
    String userId = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(
      storageKey(keyNotifications, userId: userId),
      list,
    );
  }

  static Future<void> persistSavedBooks(
    List<Book> books, {
    String userId = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = books.where((b) => b.isSaved).map((b) => b.id).toList();
    await prefs.setStringList(
      storageKey(keySavedBooks, userId: userId),
      savedIds,
    );
  }

  static Future<void> persistFavorites(
    List<Book> books, {
    String userId = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = books.where((b) => b.isFavorite).map((b) => b.id).toList();
    await prefs.setStringList(storageKey(keyFavorites, userId: userId), favIds);
  }

  static Future<void> persistRecentSearches(
    List<String> searches, {
    String userId = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      storageKey(keyRecentSearches, userId: userId),
      searches,
    );
  }

  static Future<void> persistBookmarks(
    List<Bookmark> bookmarks, {
    String userId = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = bookmarks.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(
      storageKey(keyBookmarks, userId: userId),
      jsonList,
    );
  }

  static Future<void> persistReadingProgress(
    List<Book> books, {
    String userId = '',
  }) async {
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
    await prefs.setString(
      storageKey(keyReadingProgress, userId: userId),
      jsonEncode(map),
    );
  }

  static Future<void> persistRemoteUserBooks(
    List<Book> books, {
    String userId = '',
  }) {
    final curatedBookIds = BookRepository.getInitialBooks()
        .map((book) => book.id)
        .toSet();
    final remoteUserBooks = books
        .where(
          (book) =>
              !curatedBookIds.contains(book.id) && _hasPersonalBookState(book),
        )
        .map((book) => jsonEncode(book.toJson()))
        .toList();
    final previousWrite = _remoteUserBooksWrite;
    final currentWrite = Completer<void>();
    _remoteUserBooksWrite = currentWrite.future;
    return _writeRemoteUserBooks(
      remoteUserBooks,
      userId,
      previousWrite,
      currentWrite,
    );
  }

  static Future<void> _writeRemoteUserBooks(
    List<String> remoteUserBooks,
    String userId,
    Future<void>? previousWrite,
    Completer<void> currentWrite,
  ) async {
    try {
      if (previousWrite != null) await previousWrite;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        storageKey(keyRemoteUserBooks, userId: userId),
        remoteUserBooks,
      );
    } finally {
      currentWrite.complete();
    }
  }

  static Future<void> persistCollections(
    List<BookCollection> collections, {
    String userId = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = collections.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(storageKey(keyCollections, userId: userId), list);
  }

  static Future<void> persistDownloadedBooks(
    Set<String> downloadedIds, {
    String userId = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      storageKey(keyDownloadedBooks, userId: userId),
      downloadedIds.toList(),
    );
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

  static bool _hasPersonalBookState(Book book) =>
      book.isSaved || book.isFavorite || book.progress > 0;

  static List<Book> rehydrateBooks({
    required List<Book> initialBooks,
    required List<String> savedIds,
    required List<String> favIds,
    required Map<String, dynamic> progressMap,
  }) {
    return initialBooks.map((b) {
      final isSaved = savedIds.contains(b.id);
      final isFav = favIds.contains(b.id);
      var progress = 0.0;
      var currentPage = 0;
      var chapterIdx = 0;

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
