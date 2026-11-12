import 'dart:convert';

import 'package:readpack/core/providers/helpers/book_provider_persistence.dart';
import 'package:readpack/data/book_repository.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/collection.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:readpack/models/user_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookProviderInitialState {
  final List<Book> books;
  final List<Bookmark> bookmarks;
  final List<NotificationItem> notifications;
  final List<String> recentSearches;
  final UserProfile userProfile;
  final List<BookCollection> collections;
  final Set<String> downloadedBookIds;

  BookProviderInitialState({
    required this.books,
    required this.bookmarks,
    required this.notifications,
    required this.recentSearches,
    required this.userProfile,
    required this.collections,
    required this.downloadedBookIds,
  });
}

class BookDataLoader {
  static Future<BookProviderInitialState> loadInitialState({
    String userId = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final profile = _loadProfile(prefs);
    return BookProviderInitialState(
      books: _loadBooks(prefs, userId),
      bookmarks: _loadBookmarks(prefs, userId),
      notifications: _loadNotifications(prefs, userId),
      recentSearches: _loadStrings(
        prefs,
        BookProviderPersistence.keyRecentSearches,
        userId,
      ),
      userProfile: profile,
      collections: _loadCollections(prefs, userId),
      downloadedBookIds: _loadStrings(
        prefs,
        BookProviderPersistence.keyDownloadedBooks,
        userId,
      ).toSet(),
    );
  }

  static UserProfile _loadProfile(SharedPreferences prefs) {
    final profileJson = prefs.getString(BookProviderPersistence.keyUserProfile);
    if (profileJson == null) {
      return UserProfile.freshUser(
        name: 'Зочин',
        email: '',
        username: '@guest',
      ).copyWith(isGuest: true);
    }
    return UserProfile.fromJson(
      jsonDecode(profileJson) as Map<String, dynamic>,
    );
  }

  static List<Book> _loadBooks(SharedPreferences prefs, String userId) {
    final initialBooks = BookRepository.getInitialBooks();
    initialBooks.addAll(_loadRemoteBooks(prefs, userId));
    return BookProviderPersistence.rehydrateBooks(
      initialBooks: initialBooks,
      savedIds: _loadStrings(
        prefs,
        BookProviderPersistence.keySavedBooks,
        userId,
      ),
      favIds: _loadStrings(prefs, BookProviderPersistence.keyFavorites, userId),
      progressMap: _loadProgress(prefs, userId),
    );
  }

  static List<Book> _loadRemoteBooks(SharedPreferences prefs, String userId) {
    return _loadStrings(
          prefs,
          BookProviderPersistence.keyRemoteUserBooks,
          userId,
        )
        .map(
          (serializedBook) =>
              Book.fromJson(jsonDecode(serializedBook) as Map<String, dynamic>),
        )
        .toList();
  }

  static Map<String, dynamic> _loadProgress(
    SharedPreferences prefs,
    String userId,
  ) {
    final progressJson = _readUserString(
      prefs,
      BookProviderPersistence.keyReadingProgress,
      userId,
    );
    return progressJson == null
        ? {}
        : jsonDecode(progressJson) as Map<String, dynamic>;
  }

  static List<Bookmark> _loadBookmarks(
    SharedPreferences prefs,
    String userId,
  ) => _loadRecords(
    prefs,
    BookProviderPersistence.keyBookmarks,
    userId,
    Bookmark.fromJson,
  );

  static List<NotificationItem> _loadNotifications(
    SharedPreferences prefs,
    String userId,
  ) => _loadRecords(
    prefs,
    BookProviderPersistence.keyNotifications,
    userId,
    NotificationItem.fromJson,
  );

  static List<BookCollection> _loadCollections(
    SharedPreferences prefs,
    String userId,
  ) => _loadRecords(
    prefs,
    BookProviderPersistence.keyCollections,
    userId,
    BookCollection.fromJson,
  );

  static List<T> _loadRecords<T>(
    SharedPreferences prefs,
    String storageKey,
    String userId,
    T Function(Map<String, dynamic>) decode,
  ) {
    return _loadStrings(prefs, storageKey, userId)
        .map(
          (serialized) =>
              decode(jsonDecode(serialized) as Map<String, dynamic>),
        )
        .toList();
  }

  static List<String> _loadStrings(
    SharedPreferences prefs,
    String storageKey,
    String userId,
  ) {
    return prefs.getStringList(
          BookProviderPersistence.storageKey(storageKey, userId: userId),
        ) ??
        [];
  }

  static String? _readUserString(
    SharedPreferences prefs,
    String storageKey,
    String userId,
  ) => prefs.getString(
    BookProviderPersistence.storageKey(storageKey, userId: userId),
  );
}
