import 'package:flutter/foundation.dart';
import 'package:readpack/core/providers/helpers/book_data_loader.dart';
import 'package:readpack/core/providers/helpers/book_filter_helper.dart';
import 'package:readpack/core/providers/helpers/book_gamification_manager.dart';
import 'package:readpack/core/providers/helpers/book_provider_persistence.dart';
import 'package:readpack/core/providers/helpers/book_state_mutator.dart';
import 'package:readpack/core/providers/helpers/default_provider_data.dart';
import 'package:readpack/core/providers/helpers/search_matching_engine.dart';
import 'package:readpack/core/providers/mixins/book_collection_mixin.dart';
import 'package:readpack/data/book_repository.dart';
import 'package:readpack/data/services/book_api_service.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:readpack/models/user_stats.dart';

class BookProvider extends ChangeNotifier with BookCollectionMixin {
  final BookApiService _apiService;

  List<Book> _books = BookRepository.getInitialBooks();
  List<String> _recentSearches = [
    'Atomic Habits', '1984', 'Clear Thinking', 'Sapiens',
  ];
  List<Bookmark> _bookmarks = DefaultProviderData.defaultBookmarks();
  List<NotificationItem> _notifications =
      DefaultProviderData.defaultNotifications();
  UserProfile _userProfile = const UserProfile();

  bool _isLoading = false;
  bool _isFetchingRemote = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _homeSelectedCategory = 'book.categories.all';
  List<String> _searchCategories = [];
  double _minRating = 0.0;
  String _sortBy = 'popular';
  String _librarySortBy = 'recent';
  String _selectedMood = 'all';

  @override
  List<Book> get books => _books;
  List<String> get recentSearches => _recentSearches;
  List<Bookmark> get bookmarks => _bookmarks;
  List<NotificationItem> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isFetchingRemote => _isFetchingRemote;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _homeSelectedCategory;
  List<String> get searchCategories => _searchCategories;
  double get minRating => _minRating;
  String get sortBy => _sortBy;
  String get librarySortBy => _librarySortBy;
  String get selectedMood => _selectedMood;

  BookProvider({BookApiService? apiService})
      : _apiService = apiService ?? BookApiService() {
    _initData();
  }

  List<Book> get featuredBooks => _books.take(4).toList();
  List<Book> get continueReadingBooks =>
      _books.where((b) => b.progress > 0.0 && b.progress < 1.0).toList();
  List<Book> get savedBooks => _books.where((b) => b.isSaved).toList();
  List<Book> get sortedSavedBooks =>
      BookFilterHelper.sortSavedBooks(_books, _librarySortBy);
  List<Book> get filteredBooks =>
      BookFilterHelper.filterCategory(_books, _homeSelectedCategory);
  String? get searchSuggestion =>
      SearchMatchingEngine.computeSearchSuggestion(_books, _searchQuery);
  List<Map<String, dynamic>> getChapterMatchesForBook(
          String bookId, String query) =>
      SearchMatchingEngine.findChapterMatches(_books, bookId, query);
  List<Book> get searchResults => SearchMatchingEngine.filterAndSortBooks(
        books: _books,
        query: _searchQuery,
        categories: _searchCategories,
        minRating: _minRating,
        selectedMood: _selectedMood,
        sortBy: _sortBy,
      );

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final state = await BookDataLoader.loadInitialState();
      _books = state.books;
      _bookmarks = state.bookmarks;
      _notifications = state.notifications;
      _recentSearches = state.recentSearches;
      _userProfile = state.userProfile;
      collections = state.collections;
      downloadedBookIds = state.downloadedBookIds;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => fetchRemoteBooks();

  Future<void> fetchRemoteBooks({String? query}) async {
    _isFetchingRemote = true;
    notifyListeners();
    try {
      final remoteBooks =
          await _apiService.fetchBooks(query: query ?? _searchQuery);
      if (remoteBooks.isNotEmpty) {
        final Map<String, Book> bookMap = {for (final b in _books) b.id: b};
        for (final r in remoteBooks) {
          if (bookMap.containsKey(r.id)) {
            final old = bookMap[r.id]!;
            bookMap[r.id] = r.copyWith(
              image: (old.image != null && old.image!.startsWith('assets/'))
                  ? old.image
                  : r.image,
              isSaved: old.isSaved,
              isFavorite: old.isFavorite,
              progress: old.progress,
              currentPage: old.currentPage,
            );
          } else {
            bookMap[r.id] = r;
          }
        }
        _books = bookMap.values.toList();
      }
    } catch (_) {
    } finally {
      _isFetchingRemote = false;
      notifyListeners();
    }
  }

  void toggleSaveBook(String bookId) {
    if (BookStateMutator.toggleSave(_books, bookId)) {
      notifyListeners();
      BookProviderPersistence.persistSavedBooks(_books);
      BookProviderPersistence.syncBookReadingNode(
          _apiService, _userProfile, _books, bookId,
          shelfId: 'saved', status: 'saved');
    }
  }

  void toggleFavoriteBook(String bookId) {
    if (BookStateMutator.toggleFavorite(_books, bookId)) {
      notifyListeners();
      BookProviderPersistence.persistFavorites(_books);
    }
  }

  void updateReadingPosition(String bookId,
      {required int currentPage,
      required double progress,
      int? currentChapterIndex}) {
    if (BookStateMutator.updatePosition(_books, bookId,
        currentPage: currentPage,
        progress: progress,
        currentChapterIndex: currentChapterIndex)) {
      notifyListeners();
      BookProviderPersistence.persistReadingProgress(_books);
      BookProviderPersistence.syncBookReadingNode(
          _apiService, _userProfile, _books, bookId);
    }
  }

  void updateReadingProgress(
      String bookId, int currentPage, double progress,
      [int? currentChapterIndex]) {
    _userProfile = BookStateMutator.updateProgressAndStats(_books, _userProfile,
        bookId, currentPage, progress, currentChapterIndex);
    notifyListeners();
    BookProviderPersistence.persistReadingProgress(_books);
    BookProviderPersistence.persistUserProfile(_userProfile);
    BookProviderPersistence.syncBookReadingNode(
        _apiService, _userProfile, _books, bookId,
        status: progress >= 1.0 ? 'completed' : 'reading');
  }

  void addReadingMinutes(int minutes) {
    _userProfile =
        BookGamificationManager.addReadingMinutes(_userProfile, minutes);
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
  }

  void loginAsGuest() {
    _userProfile = BookGamificationManager.loginAsGuest(_userProfile);
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
  }

  void loginWithEmail(String email, String name) {
    _userProfile =
        BookGamificationManager.loginWithEmail(_userProfile, email, name);
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
    BookProviderPersistence.syncAuthTree(_apiService, _userProfile);
  }

  void logout() {
    _userProfile = BookGamificationManager.logout();
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
  }

  void updateUserProfile(
      {String? name,
      String? email,
      String? avatarUrl,
      int? streakDays,
      int? dailyGoalMinutes,
      bool? notificationsEnabled,
      bool? recommendationsEnabled,
      bool? streakFreezeAvailable,
      List<String>? favoriteGenres,
      int? yearlyGoalBooks,
      int? reminderHour,
      bool? remindersEnabled}) {
    _userProfile = _userProfile.copyWith(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      streakDays: streakDays,
      dailyGoalMinutes: dailyGoalMinutes,
      notificationsEnabled: notificationsEnabled,
      recommendationsEnabled: recommendationsEnabled,
      streakFreezeAvailable: streakFreezeAvailable,
      favoriteGenres: favoriteGenres,
      yearlyGoalBooks: yearlyGoalBooks,
      reminderHour: reminderHour,
      remindersEnabled: remindersEnabled,
    );
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
    BookProviderPersistence.syncProfilePreferences(_apiService, _userProfile);
  }

  void updateReadingReminder({int? hour, bool? enabled}) {
    updateUserProfile(
      reminderHour: hour,
      remindersEnabled: enabled,
    );
  }

  void updateYearlyGoalBooks(int goal) {
    updateUserProfile(yearlyGoalBooks: goal);
  }

  void clearCache() {
    _recentSearches.clear();
    BookProviderPersistence.persistRecentSearches(_recentSearches);
    notifyListeners();
  }

  void addBookmark(Bookmark bookmark) {
    _bookmarks.insert(0, bookmark);
    notifyListeners();
    BookProviderPersistence.persistBookmarks(_bookmarks);
    BookProviderPersistence.syncBookReadingNode(
        _apiService, _userProfile, _books, bookmark.bookId,
        highlight: {'text': bookmark.quote, 'chapterIndex': 0});
  }

  void removeBookmark(String bookmarkId) {
    _bookmarks.removeWhere((b) => b.id == bookmarkId);
    notifyListeners();
    BookProviderPersistence.persistBookmarks(_bookmarks);
  }

  void toggleLikeBookmark(String bookmarkId) {
    final index = _bookmarks.indexWhere((b) => b.id == bookmarkId);
    if (index != -1) {
      _bookmarks[index] = _bookmarks[index].copyWith(
        isLiked: !_bookmarks[index].isLiked,
      );
      notifyListeners();
      BookProviderPersistence.persistBookmarks(_bookmarks);
    }
  }

  void updateBookmarkNote(String bookmarkId, String note) {
    final index = _bookmarks.indexWhere((b) => b.id == bookmarkId);
    if (index != -1) {
      _bookmarks[index] = _bookmarks[index].copyWith(note: note.trim());
      notifyListeners();
      BookProviderPersistence.persistBookmarks(_bookmarks);
    }
  }

  void addReview(String bookId, BookReview review) {
    BookStateMutator.addReview(_books, bookId, review);
    notifyListeners();
  }

  void updateReview(String bookId, BookReview updatedReview) {
    BookStateMutator.updateReview(_books, bookId, updatedReview);
    notifyListeners();
  }

  void deleteReview(String bookId, String reviewId) {
    BookStateMutator.deleteReview(_books, bookId, reviewId);
    notifyListeners();
  }

  void setSearchQuery(String query, {bool isTyping = false}) {
    _searchQuery = query;
    if (!isTyping && query.trim().isNotEmpty) {
      commitSearchQuery(query);
    } else {
      notifyListeners();
    }
    if (query.trim().length >= 3 && searchResults.isEmpty && !_isFetchingRemote) {
      fetchRemoteBooks(query: query.trim());
    }
  }

  void commitSearchQuery(String query) {
    BookFilterHelper.commitQuery(_recentSearches, query);
    BookProviderPersistence.persistRecentSearches(_recentSearches);
    notifyListeners();
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
    BookProviderPersistence.persistRecentSearches(_recentSearches);
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
    BookProviderPersistence.persistRecentSearches(_recentSearches);
  }

  void setSelectedCategory(String category) {
    _homeSelectedCategory = category;
    notifyListeners();
  }

  void applyFilters(
      {List<String>? categories, double? minRating, String? sortBy}) {
    if (categories != null) _searchCategories = List.from(categories);
    if (minRating != null) _minRating = minRating;
    if (sortBy != null) _sortBy = sortBy;
    notifyListeners();
  }

  void resetFilters() {
    _searchCategories = [];
    _minRating = 0.0;
    _sortBy = 'popular';
    _searchQuery = '';
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    if (BookStateMutator.markNotificationRead(_notifications, id)) {
      notifyListeners();
      BookProviderPersistence.persistNotifications(_notifications);
    }
  }

  void markAllNotificationsAsRead() {
    _notifications =
        BookStateMutator.markAllNotificationsRead(_notifications);
    notifyListeners();
    BookProviderPersistence.persistNotifications(_notifications);
  }

  void deleteNotification(String id) {
    BookStateMutator.deleteNotification(_notifications, id);
    notifyListeners();
    BookProviderPersistence.persistNotifications(_notifications);
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
    BookProviderPersistence.persistNotifications(_notifications);
  }

  void toggleReviewHelpful(String bookId, String reviewId) {
    if (BookStateMutator.toggleReviewHelpful(_books, bookId, reviewId)) {
      addXp(10);
    }
    notifyListeners();
  }

  void setLibrarySortBy(String sortBy) {
    _librarySortBy = sortBy;
    notifyListeners();
  }

  void setSelectedMood(String mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  @override
  void createCollection(String name, String description,
      {String icon = 'bookmark'}) {
    super.createCollection(name, description, icon: icon);
    addXp(30);
  }

  @override
  bool addBookToCollection(String collectionId, String bookId) {
    final added = super.addBookToCollection(collectionId, bookId);
    if (added) addXp(15);
    return added;
  }

  void toggleDownloadBook(String bookId) {
    toggleDownload(bookId, () => addXp(20));
  }

  void addXp(int amount) {
    if (amount <= 0) return;
    _userProfile = _userProfile.copyWith(xp: _userProfile.xp + amount);
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
  }

  int get userLevel =>
      BookGamificationManager.computeUserLevel(_userProfile.xp);
  String get userLevelTitle =>
      BookGamificationManager.computeUserLevelTitle(_userProfile.xp);

  void completeOnboarding({
    required List<String> favoriteGenres,
    required int dailyGoalMinutes,
    required int yearlyGoalBooks,
  }) {
    _userProfile = _userProfile.copyWith(
      favoriteGenres: favoriteGenres,
      dailyGoalMinutes: dailyGoalMinutes,
      yearlyGoalBooks: yearlyGoalBooks,
      onboardingCompleted: true,
      xp: _userProfile.xp + 100,
    );
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
    BookProviderPersistence.syncProfilePreferences(_apiService, _userProfile);
  }
}
