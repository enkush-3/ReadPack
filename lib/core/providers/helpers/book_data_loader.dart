import 'dart:convert';
import 'package:readpack/core/providers/helpers/book_provider_persistence.dart';
import 'package:readpack/core/providers/helpers/default_provider_data.dart';
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
  static Future<BookProviderInitialState> loadInitialState() async {
    var books = BookRepository.getInitialBooks();
    var bookmarks = DefaultProviderData.defaultBookmarks();
    var notifications = DefaultProviderData.defaultNotifications();
    var recentSearches = ['Atomic Habits', '1984', 'Clear Thinking', 'Sapiens'];
    var userProfile = UserProfile.freshUser(
      name: 'Зочин',
      email: '',
      username: '@guest',
    ).copyWith(isGuest: true);
    var collections = <BookCollection>[];
    var downloadedBookIds = <String>{};

    final prefs = await SharedPreferences.getInstance();
    final savedIds =
        prefs.getStringList(BookProviderPersistence.keySavedBooks) ?? [];
    final favIds =
        prefs.getStringList(BookProviderPersistence.keyFavorites) ?? [];
    final searches = prefs.getStringList(
      BookProviderPersistence.keyRecentSearches,
    );
    if (searches != null && searches.isNotEmpty) {
      recentSearches = searches;
    }

    final progressJson = prefs.getString(
      BookProviderPersistence.keyReadingProgress,
    );
    Map<String, dynamic> progressMap = {};
    if (progressJson != null) {
      progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
    }

    books = BookProviderPersistence.rehydrateBooks(
      initialBooks: books,
      savedIds: savedIds,
      favIds: favIds,
      progressMap: progressMap,
    );

    final bookmarksJson = prefs.getStringList(
      BookProviderPersistence.keyBookmarks,
    );
    if (bookmarksJson != null && bookmarksJson.isNotEmpty) {
      bookmarks = bookmarksJson
          .map((b) => Bookmark.fromJson(jsonDecode(b) as Map<String, dynamic>))
          .toList();
    }

    final profileJson = prefs.getString(BookProviderPersistence.keyUserProfile);
    if (profileJson != null) {
      userProfile = UserProfile.fromJson(
        jsonDecode(profileJson) as Map<String, dynamic>,
      );
    }

    final notifsJson = prefs.getStringList(
      BookProviderPersistence.keyNotifications,
    );
    if (notifsJson != null && notifsJson.isNotEmpty) {
      notifications = notifsJson
          .map(
            (n) => NotificationItem.fromJson(
              jsonDecode(n) as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    final collectionsJson = prefs.getStringList(
      BookProviderPersistence.keyCollections,
    );
    if (collectionsJson != null && collectionsJson.isNotEmpty) {
      collections = collectionsJson
          .map(
            (c) =>
                BookCollection.fromJson(jsonDecode(c) as Map<String, dynamic>),
          )
          .toList();
    } else {
      collections = DefaultProviderData.defaultCollections();
    }

    final downloadedList = prefs.getStringList(
      BookProviderPersistence.keyDownloadedBooks,
    );
    if (downloadedList != null) {
      downloadedBookIds = downloadedList.toSet();
    }

    return BookProviderInitialState(
      books: books,
      bookmarks: bookmarks,
      notifications: notifications,
      recentSearches: recentSearches,
      userProfile: userProfile,
      collections: collections,
      downloadedBookIds: downloadedBookIds,
    );
  }
}
