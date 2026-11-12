import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:readpack/core/providers/helpers/book_data_loader.dart';
import 'package:readpack/core/providers/helpers/book_filter_helper.dart';
import 'package:readpack/core/providers/helpers/book_gamification_manager.dart';
import 'package:readpack/core/providers/helpers/book_provider_persistence.dart';
import 'package:readpack/core/providers/helpers/book_state_mutator.dart';
import 'package:readpack/core/providers/helpers/search_matching_engine.dart';
import 'package:readpack/core/providers/mixins/book_collection_mixin.dart';
import 'package:readpack/data/book_repository.dart';
import 'package:readpack/data/services/auth_api_service.dart';
import 'package:readpack/data/services/book_api_service.dart';
import 'package:readpack/data/services/notification_service.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:readpack/models/user_stats.dart';

class BookProvider extends ChangeNotifier with BookCollectionMixin {
  final BookApiService _apiService;
  final NotificationService _notificationService = NotificationService();
  late final AuthApiService _authApi;

  List<Book> _books = BookRepository.getInitialBooks();
  List<String> _recentSearches = [];
  List<Bookmark> _bookmarks = [];
  List<NotificationItem> _notifications = [];
  List<LeaderboardCompetitor> _leaderboardEntries = const [];
  UserProfile _userProfile = const UserProfile();

  bool _isLoading = false;
  bool _isFetchingRemote = false;
  bool _isLeaderboardLoading = false;
  String? _errorMessage;
  String? _remoteBooksErrorMessage;
  String? _leaderboardError;

  String _searchQuery = '';
  String _homeSelectedCategory = 'book.categories.all';
  List<String> _searchCategories = [];
  double _minRating = 0.0;
  String _sortBy = 'popular';
  String _librarySortBy = 'recent';
  String _selectedMood = 'all';
  bool _isDisposed = false;
  late Future<void> _initialization;

  @override
  List<Book> get books => _books;
  List<String> get recentSearches => _recentSearches;
  List<Bookmark> get bookmarks => _bookmarks;
  List<NotificationItem> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  Future<void> get initialized => _initialization;
  String? get remoteBooksErrorMessage => _remoteBooksErrorMessage;
  bool get isFetchingRemote => _isFetchingRemote;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _homeSelectedCategory;
  List<String> get searchCategories => _searchCategories;
  double get minRating => _minRating;
  String get sortBy => _sortBy;
  String get librarySortBy => _librarySortBy;
  String get selectedMood => _selectedMood;
  List<LeaderboardCompetitor> get leaderboardEntries => _leaderboardEntries;
  bool get isLeaderboardLoading => _isLeaderboardLoading;
  String? get leaderboardError => _leaderboardError;

  BookProvider({BookApiService? apiService})
    : _apiService = apiService ?? BookApiService() {
    _authApi = _apiService.authService;
    _initialization = _initData();
  }

  Book? _bookById(String bookId) {
    for (final book in _books) {
      if (book.id == bookId) return book;
    }
    return null;
  }

  bool _crossesReadingBoundary(double previousProgress, double progress) =>
      (previousProgress <= 0 && progress > 0) ||
      (previousProgress > 0 && progress <= 0);

  Future<void> _persistRemoteBooksIfReadingStateChanged(
    double? previousProgress,
    double progress,
  ) {
    if (previousProgress != null &&
        _crossesReadingBoundary(previousProgress, progress)) {
      return _persistRemoteUserBooks();
    }
    return Future<void>.value();
  }

  Future<void> _persistRemoteUserBooks() =>
      BookProviderPersistence.persistRemoteUserBooks(_books);

  Future<void> retryInitialization() {
    if (_isLoading) return _initialization;
    _initialization = _initData();
    return _initialization;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  List<Book> get featuredBooks => _books.take(4).toList();
  List<Book> get continueReadingBooks =>
      _books.where((b) => b.progress > 0.0 && b.progress < 1.0).toList();
  Book? get currentlyReadingBook => continueReadingBooks.isNotEmpty
      ? continueReadingBooks.first
      : (_books.isNotEmpty ? _books.first : null);
  String get cacheSizeMb =>
      '${(downloadedBookIds.length * 1.4).toStringAsFixed(1)} MB';
  List<Book> get savedBooks => _books.where((b) => b.isSaved).toList();
  List<Book> get sortedSavedBooks =>
      BookFilterHelper.sortSavedBooks(_books, _librarySortBy);
  List<Book> get filteredBooks =>
      BookFilterHelper.filterCategory(_books, _homeSelectedCategory);
  String? get searchSuggestion =>
      SearchMatchingEngine.computeSearchSuggestion(_books, _searchQuery);
  List<Map<String, dynamic>> getChapterMatchesForBook(
    String bookId,
    String query,
  ) => SearchMatchingEngine.findChapterMatches(_books, bookId, query);
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
    _errorMessage = null;
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
      var hasSession = false;
      try {
        hasSession = await _authApi.hasStoredSession();
      } catch (_) {
        await _authApi.clearSession().catchError((Object _) {});
      }
      if (!hasSession) {
        _userProfile = BookGamificationManager.logout();
      } else if (_userProfile.isGuest || _userProfile.userId.isEmpty) {
        await _authApi.clearSession();
        _userProfile = BookGamificationManager.logout();
      } else {
        try {
          await _authApi.refreshSession();
          final tree = await _authApi.getUserTree(_userProfile.userId);
          _userProfile = _profileFromApiResponse(tree);
        } on AuthApiException {
          await _authApi.clearSession();
          _userProfile = BookGamificationManager.logout();
        }
      }
      if (!_userProfile.isGuest && _userProfile.notificationsEnabled) {
        unawaited(_syncNotificationSettings());
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => fetchRemoteBooks();

  Future<void> refreshLeaderboard({String period = 'monthly'}) async {
    _isLeaderboardLoading = true;
    _leaderboardError = null;
    notifyListeners();
    try {
      final response = await _apiService.fetchLeaderboard(period: period);
      final rawEntries = response['entries'] as List<dynamic>? ?? const [];
      _leaderboardEntries = rawEntries
          .whereType<Map<String, dynamic>>()
          .map(
            (entry) => LeaderboardCompetitor.fromJson(
              entry,
              isCurrentUser:
                  entry['userId'] == _userProfile.userId &&
                  _userProfile.userId.isNotEmpty,
            ),
          )
          .toList();
    } catch (error) {
      _leaderboardError = error.toString();
    } finally {
      _isLeaderboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRemoteBooks({String? query}) async {
    _isFetchingRemote = true;
    _remoteBooksErrorMessage = null;
    notifyListeners();
    try {
      final remoteBooks = await _apiService.fetchBooks(
        query: query ?? _searchQuery,
      );
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
    } catch (error) {
      _remoteBooksErrorMessage = error.toString();
    } finally {
      _isFetchingRemote = false;
      notifyListeners();
    }
  }

  Future<void> toggleSaveBook(String bookId) {
    if (BookStateMutator.toggleSave(_books, bookId)) {
      notifyListeners();
      BookProviderPersistence.persistSavedBooks(_books);
      BookProviderPersistence.syncBookReadingNode(
        _apiService,
        _userProfile,
        _books,
        bookId,
        shelfId: 'saved',
        status: 'saved',
      );
      return _persistRemoteUserBooks();
    }
    return Future<void>.value();
  }

  Future<void> toggleFavoriteBook(String bookId) {
    if (BookStateMutator.toggleFavorite(_books, bookId)) {
      notifyListeners();
      BookProviderPersistence.persistFavorites(_books);
      return _persistRemoteUserBooks();
    }
    return Future<void>.value();
  }

  Future<void> updateReadingPosition(
    String bookId, {
    required int currentPage,
    required double progress,
    int? currentChapterIndex,
  }) async {
    final previousProgress = _bookById(bookId)?.progress;
    if (BookStateMutator.updatePosition(
      _books,
      bookId,
      currentPage: currentPage,
      progress: progress,
      currentChapterIndex: currentChapterIndex,
    )) {
      notifyListeners();
      final persistenceWrites = <Future<void>>[
        BookProviderPersistence.persistReadingProgress(_books),
        _persistRemoteBooksIfReadingStateChanged(previousProgress, progress),
      ];
      BookProviderPersistence.syncBookReadingNode(
        _apiService,
        _userProfile,
        _books,
        bookId,
      );
      await Future.wait(persistenceWrites);
    }
  }

  Future<void> updateReadingProgress(
    String bookId,
    int currentPage,
    double progress, [
    int? currentChapterIndex,
  ]) async {
    final previousProgress = _bookById(bookId)?.progress;
    _userProfile = BookStateMutator.updateProgressAndStats(
      _books,
      _userProfile,
      bookId,
      currentPage,
      progress,
      currentChapterIndex,
    );
    notifyListeners();
    final persistenceWrites = <Future<void>>[
      BookProviderPersistence.persistReadingProgress(_books),
      _persistRemoteBooksIfReadingStateChanged(previousProgress, progress),
    ];
    BookProviderPersistence.persistUserProfile(_userProfile);
    BookProviderPersistence.syncBookReadingNode(
      _apiService,
      _userProfile,
      _books,
      bookId,
      status: progress >= 1.0 ? 'completed' : 'reading',
    );
    await Future.wait(persistenceWrites);
  }

  void addReadingMinutes(int minutes, {String? bookId}) {
    if (minutes <= 0) return;
    _userProfile = BookGamificationManager.addReadingMinutes(
      _userProfile,
      minutes,
    );
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
    if (_userProfile.isGuest || _userProfile.userId.isEmpty) return;

    final userId = _userProfile.userId;
    Book? readingBook;
    for (final candidate in _books) {
      if (candidate.id == bookId) {
        readingBook = candidate;
        break;
      }
    }
    final eventId =
        '${userId}_${DateTime.now().toUtc().microsecondsSinceEpoch}_$minutes';
    _apiService
        .recordReadingEvent(
          userId: userId,
          eventId: eventId,
          minutesRead: minutes,
          book: readingBook,
          bookId: bookId,
        )
        .then((response) {
          if (_isDisposed || response == null) return;
          final tree = response['userAccountTree'];
          if (tree is Map<String, dynamic>) {
            _userProfile = _profileFromApiResponse(response);
            notifyListeners();
            BookProviderPersistence.persistUserProfile(_userProfile);
          }
        });
  }

  Future<AuthChallenge> beginSignUp({
    required String name,
    required String contact,
    required String contactType,
    required String password,
  }) => _authApi.signUp(
    name: name,
    contact: contact,
    contactType: contactType,
    password: password,
  );

  Future<AuthChallenge> resendVerificationCode(String challengeId) =>
      _authApi.resendOtp(challengeId);

  Future<void> verifySignUp({
    required String challengeId,
    required String code,
  }) async {
    final result = await _authApi.verifyOtp(
      challengeId: challengeId,
      code: code,
    );
    _setAuthenticatedProfile(result.userAccountTree);
  }

  Future<void> signInWithPassword({
    required String contact,
    required String contactType,
    required String password,
  }) async {
    final result = await _authApi.signIn(
      contact: contact,
      contactType: contactType,
      password: password,
    );
    _setAuthenticatedProfile(result.userAccountTree);
  }

  Future<void> signInWithProvider({
    required String provider,
    required String token,
  }) async {
    final result = await _authApi.signInWithProvider(
      provider: provider,
      token: token,
    );
    _setAuthenticatedProfile(result.userAccountTree);
  }

  Future<AuthChallenge> requestPasswordReset({
    required String contact,
    required String contactType,
  }) =>
      _authApi.requestPasswordReset(contact: contact, contactType: contactType);

  Future<void> resetPassword({
    required String challengeId,
    required String code,
    required String newPassword,
  }) => _authApi.resetPassword(
    challengeId: challengeId,
    code: code,
    newPassword: newPassword,
  );

  void _setAuthenticatedProfile(Map<String, dynamic> response) {
    _userProfile = _profileFromApiResponse(response);
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
    if (_userProfile.notificationsEnabled) {
      unawaited(_syncNotificationSettings());
    }
  }

  UserProfile _profileFromApiResponse(Map<String, dynamic> response) {
    final tree =
        response['userAccountTree'] as Map<String, dynamic>? ?? response;
    final profile = _profileFromAccountTree(tree);
    final readingStats = response['readingStats'] as Map<String, dynamic>?;
    if (readingStats == null) return profile;
    final weeklyMinutes = (readingStats['weeklyMinutes'] as List<dynamic>?)
        ?.map((value) => (value as num).toInt())
        .toList();
    return profile.copyWith(
      xp: (readingStats['totalXp'] as num?)?.toInt(),
      streakDays: (readingStats['currentStreak'] as num?)?.toInt(),
      minutesReadToday: (readingStats['minutesReadToday'] as num?)?.toInt(),
      lastStreakDate: readingStats['lastActiveDate'] as String?,
      weeklyMinutes: weeklyMinutes?.length == 7 ? weeklyMinutes : null,
    );
  }

  Future<void> _syncNotificationSettings() async {
    final profile = _userProfile;
    if (!profile.notificationsEnabled) {
      await _notificationService.cancelDailyReminder();
      if (!profile.isGuest && profile.userId.isNotEmpty) {
        await _notificationService.unregisterPushDevice(
          authApi: _authApi,
          userId: profile.userId,
        );
      }
      return;
    }

    await _notificationService.initialize();

    if (profile.remindersEnabled) {
      await _notificationService.scheduleDailyReminder(
        hour: profile.reminderHour,
        enabled: true,
      );
    } else {
      await _notificationService.cancelDailyReminder();
    }

    if (!profile.isGuest && profile.userId.isNotEmpty) {
      await _notificationService.registerPushDevice(
        authApi: _authApi,
        userId: profile.userId,
        isAuthenticated: true,
      );
    }
  }

  UserProfile _profileFromAccountTree(Map<String, dynamic> tree) {
    final account = tree['user'] as Map<String, dynamic>? ?? tree;
    final profileNode = account['profileNode'] as Map<String, dynamic>? ?? {};
    final preferences =
        profileNode['preferencesNode'] as Map<String, dynamic>? ?? {};
    final gamification =
        account['gamificationTree'] as Map<String, dynamic>? ?? {};
    final xpNode = gamification['xpNode'] as Map<String, dynamic>? ?? {};
    final streakNode =
        gamification['streakNode'] as Map<String, dynamic>? ?? {};
    final email = account['email'] as String? ?? '';
    final phone = profileNode['phoneNumber'] as String? ?? '';
    final userId =
        account['userId'] as String? ?? account['_id'] as String? ?? '';
    final name = profileNode['displayName'] as String? ?? 'Уншигч';

    return UserProfile.freshUser(
      name: name,
      email: email,
      userId: userId,
      phoneNumber: phone,
      username: email.isNotEmpty
          ? '@${email.split('@').first.toLowerCase()}'
          : '@${userId.isEmpty ? 'reader' : userId}',
    ).copyWith(
      avatarUrl: profileNode['avatarUrl'] as String? ?? '',
      dailyGoalMinutes: (preferences['dailyGoalMinutes'] as num?)?.toInt(),
      yearlyGoalBooks: (preferences['yearlyBookGoal'] as num?)?.toInt(),
      favoriteGenres: (preferences['favoriteGenres'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(),
      notificationsEnabled: preferences['notificationsEnabled'] as bool?,
      recommendationsEnabled: preferences['recommendationsEnabled'] as bool?,
      xp: (xpNode['totalXp'] as num?)?.toInt(),
      weeklyLeague: xpNode['weeklyLeague'] as String?,
      streakDays: (streakNode['currentStreak'] as num?)?.toInt(),
      minutesReadToday: (streakNode['minutesReadToday'] as num?)?.toInt(),
      streakFreezeAvailable: streakNode['streakFreezeAvailable'] as bool?,
      lastStreakDate: streakNode['lastActiveDate'] as String?,
      isGuest: false,
    );
  }

  void loginAsGuest() {
    _userProfile = BookGamificationManager.loginAsGuest(_userProfile);
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
  }

  void loginWithEmail(
    String email,
    String name, {
    String? username,
    String? phoneNumber,
  }) {
    _userProfile = BookGamificationManager.loginWithEmail(
      _userProfile,
      email,
      name,
      username: username,
      phoneNumber: phoneNumber,
    );
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
  }

  void registerNewUser({
    required String name,
    required String email,
    String? username,
    String? phoneNumber,
  }) {
    _userProfile = BookGamificationManager.registerNewUser(
      name: name,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
    );
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
  }

  void logout() {
    final previousProfile = _userProfile;
    _userProfile = BookGamificationManager.logout();
    notifyListeners();
    BookProviderPersistence.persistUserProfile(_userProfile);
    final unregister =
        !previousProfile.isGuest && previousProfile.userId.isNotEmpty
        ? _notificationService.unregisterPushDevice(
            authApi: _authApi,
            userId: previousProfile.userId,
          )
        : Future<NotificationServiceResult>.value(
            const NotificationServiceResult(
              NotificationServiceStatus.unauthenticated,
            ),
          );
    unawaited(
      unregister.then((_) => _authApi.logout()).catchError((Object _) {}),
    );
  }

  void updateUserProfile({
    String? name,
    String? email,
    String? username,
    String? phoneNumber,
    String? avatarUrl,
    int? streakDays,
    int? dailyGoalMinutes,
    bool? notificationsEnabled,
    bool? recommendationsEnabled,
    bool? streakFreezeAvailable,
    List<String>? favoriteGenres,
    int? yearlyGoalBooks,
    int? reminderHour,
    bool? remindersEnabled,
  }) {
    _userProfile = _userProfile.copyWith(
      name: name,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
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
    if (notificationsEnabled != null ||
        remindersEnabled != null ||
        reminderHour != null) {
      unawaited(_syncNotificationSettings());
    }
  }

  void updateReadingReminder({
    int? hour,
    int? reminderHour,
    bool? enabled,
    bool? remindersEnabled,
  }) {
    updateUserProfile(
      reminderHour: reminderHour ?? hour,
      remindersEnabled: remindersEnabled ?? enabled,
    );
  }

  void updateYearlyGoalBooks(int goal) {
    updateUserProfile(yearlyGoalBooks: goal);
  }

  void clearCache() {
    _recentSearches.clear();
    downloadedBookIds.clear();
    BookProviderPersistence.persistRecentSearches(_recentSearches);
    BookProviderPersistence.persistDownloadedBooks(downloadedBookIds);
    notifyListeners();
  }

  void addBookmark(Bookmark bookmark) {
    _bookmarks.insert(0, bookmark);
    notifyListeners();
    BookProviderPersistence.persistBookmarks(_bookmarks);
    BookProviderPersistence.syncBookReadingNode(
      _apiService,
      _userProfile,
      _books,
      bookmark.bookId,
      highlight: {'text': bookmark.quote, 'chapterIndex': 0},
    );
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
    if (query.trim().length >= 3 &&
        searchResults.isEmpty &&
        !_isFetchingRemote) {
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

  void applyFilters({
    List<String>? categories,
    double? minRating,
    String? sortBy,
  }) {
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
    _notifications = BookStateMutator.markAllNotificationsRead(_notifications);
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
  void createCollection(
    String name,
    String description, {
    String icon = 'bookmark',
  }) {
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
