import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:readpack/data/book_repository.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/collection.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:readpack/models/user_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookProvider extends ChangeNotifier {
  static const String _keySavedBooks = 'readpack_saved_books_ids';
  static const String _keyFavorites = 'readpack_favorites_ids';
  static const String _keyRecentSearches = 'readpack_recent_searches';
  static const String _keyBookmarks = 'readpack_bookmarks';
  static const String _keyReadingProgress = 'readpack_book_progress';
  static const String _keyUserProfile = 'readpack_user_profile';
  static const String _keyNotifications = 'readpack_notifications';
  static const String _keyCollections = 'readpack_book_collections';
  static const String _keyDownloadedBooks = 'readpack_downloaded_books';

  List<Book> _books = [];
  List<String> _recentSearches = [
    'Atomic Habits',
    '1984',
    'Clear Thinking',
    'Sapiens',
  ];
  List<Bookmark> _bookmarks = [];
  List<NotificationItem> _notifications = [];
  UserProfile _userProfile = const UserProfile();
  List<BookCollection> _collections = [];
  Set<String> _downloadedBookIds = {};

  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _homeSelectedCategory = 'book.categories.all';
  List<String> _searchCategories = [];
  double _minRating = 0.0;
  String _sortBy = 'popular'; // popular, rating, newest, title
  String _librarySortBy = 'recent'; // recent, title, author, progress, rating
  String _selectedMood = 'all'; // all, inspiring, philosophical, light_reading, deep_focus

  List<Book> get books => _books;
  List<String> get recentSearches => _recentSearches;
  List<Bookmark> get bookmarks => _bookmarks;
  List<NotificationItem> get notifications => _notifications;
  List<BookCollection> get collections => _collections;
  Set<String> get downloadedBookIds => _downloadedBookIds;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _homeSelectedCategory;
  List<String> get searchCategories => _searchCategories;
  double get minRating => _minRating;
  String get sortBy => _sortBy;
  String get librarySortBy => _librarySortBy;
  String get selectedMood => _selectedMood;

  BookProvider() {
    _initData();
  }

  List<Book> get featuredBooks {
    return _books.take(4).toList();
  }

  List<Book> get continueReadingBooks {
    return _books.where((b) => b.progress > 0.0 && b.progress < 1.0).toList();
  }

  List<Book> get savedBooks {
    return _books.where((b) => b.isSaved).toList();
  }

  List<Book> get sortedSavedBooks {
    final list = _books.where((b) => b.isSaved).toList();
    switch (_librarySortBy) {
      case 'title':
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'author':
        list.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
        break;
      case 'progress':
        list.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'recent':
      default:
        // maintain default list order
        break;
    }
    return list;
  }

  List<Book> get filteredBooks {
    return _books.where((book) {
      if (_homeSelectedCategory == 'book.categories.all') return true;
      return book.category == _homeSelectedCategory;
    }).toList();
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i <= t.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[t.length];
  }

  String _transliterateCyrillic(String input) {
    const map = {
      'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'yo',
      'ж': 'j', 'з': 'z', 'и': 'i', 'й': 'i', 'к': 'k', 'л': 'l', 'м': 'm',
      'н': 'n', 'о': 'o', 'ө': 'u', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't',
      'у': 'u', 'ү': 'u', 'ф': 'f', 'х': 'h', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh',
      'щ': 'sh', 'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
    };
    final sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i].toLowerCase();
      sb.write(map[char] ?? char);
    }
    return sb.toString();
  }

  bool _matchesMood(Book book, String mood) {
    if (mood == 'all') return true;
    final cat = book.category.toLowerCase();
    final title = book.title.toLowerCase();
    final tags = book.tags.map((t) => t.toLowerCase()).toList();

    switch (mood) {
      case 'inspiring':
        return cat.contains('business') ||
            tags.contains('productivity') ||
            tags.contains('habits') ||
            tags.contains('success') ||
            title.contains('atomic') ||
            title.contains('thinking');
      case 'philosophical':
        return cat.contains('fiction') ||
            cat.contains('general') ||
            tags.contains('philosophy') ||
            tags.contains('dystopian') ||
            title.contains('1984') ||
            title.contains('sapiens');
      case 'light_reading':
        return book.pages <= 250 || book.readTimeMinutes <= 150;
      case 'deep_focus':
        return book.pages > 250 || book.readTimeMinutes > 150;
      default:
        return true;
    }
  }

  String? get searchSuggestion {
    if (_searchQuery.trim().length < 3) return null;
    final q = _searchQuery.toLowerCase().trim();
    final qTrans = _transliterateCyrillic(q);
    final isCyrillic = RegExp(r'[а-яА-ЯёЁөӨүҮ]').hasMatch(q);

    final hasDirectMatch = _books.any((b) =>
        b.title.toLowerCase().contains(q) ||
        b.author.toLowerCase().contains(q) ||
        (qTrans != q && (b.title.toLowerCase().contains(qTrans) || b.author.toLowerCase().contains(qTrans))));
    if (hasDirectMatch) return null;

    for (final b in _books) {
      final title = b.title.toLowerCase();
      final titleWords = title
          .split(' ')
          .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁөӨүҮ]'), ''))
          .where((w) => w.isNotEmpty)
          .toList();

      final titleDistLimit = q.length <= 4 ? 1 : (q.length <= 6 ? 2 : 3);
      if (_levenshtein(q, title) <= titleDistLimit ||
          _levenshtein(qTrans, title) <= titleDistLimit) {
        if (isCyrillic && (b.id == 'book_sapiens' || title.contains('sapiens'))) {
          return 'Сапиенс (${b.title})';
        }
        return b.title;
      }
      for (final word in titleWords) {
        if (const {'the', 'and', 'for', 'with', 'from', 'this', 'that'}.contains(word)) {
          continue;
        }
        final maxDist = word.length <= 4 ? 1 : 2;
        if (word.length >= 3 &&
            (_levenshtein(q, word) <= maxDist || _levenshtein(qTrans, word) <= maxDist)) {
          if (isCyrillic && (word == 'sapiens' || b.id == 'book_sapiens')) {
            return 'Сапиенс (${b.title})';
          }
          return b.title;
        }
      }
      final author = b.author.toLowerCase();
      final authorWords = author
          .split(' ')
          .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁөӨүҮ]'), ''))
          .where((w) => w.isNotEmpty)
          .toList();

      if (_levenshtein(q, author) <= titleDistLimit ||
          _levenshtein(qTrans, author) <= titleDistLimit) {
        return b.author;
      }
      for (final word in authorWords) {
        if (const {'the', 'and', 'for', 'with', 'from', 'this', 'that'}.contains(word)) {
          continue;
        }
        final maxDist = word.length <= 4 ? 1 : 2;
        if (word.length >= 3 &&
            (_levenshtein(q, word) <= maxDist || _levenshtein(qTrans, word) <= maxDist)) {
          return b.author;
        }
      }
    }
    return null;
  }

  List<Map<String, dynamic>> getChapterMatchesForBook(String bookId, String query) {
    if (query.trim().isEmpty) return [];
    final book = _books.firstWhere((b) => b.id == bookId, orElse: () => _books.first);
    final List<Map<String, dynamic>> matches = [];
    final q = query.toLowerCase();

    for (int i = 0; i < book.chapters.length; i++) {
      final ch = book.chapters[i];
      final titleIndex = ch.title.toLowerCase().indexOf(q);
      final contentIndex = ch.content.toLowerCase().indexOf(q);

      if (titleIndex != -1 || contentIndex != -1) {
        String snippet = ch.title;
        if (contentIndex != -1) {
          final start = (contentIndex - 25).clamp(0, ch.content.length);
          final end = (contentIndex + q.length + 45).clamp(0, ch.content.length);
          snippet = '...${ch.content.substring(start, end).replaceAll('\n', ' ')}...';
        }
        matches.add({
          'chapterIndex': i,
          'chapterTitle': ch.title,
          'snippet': snippet,
        });
      }
    }
    return matches;
  }

  List<Book> get searchResults {
    final q = _searchQuery.trim().toLowerCase();
    final qTrans = _transliterateCyrillic(q);

    var result = _books.where((book) {
      final titleLower = book.title.toLowerCase();
      final authorLower = book.author.toLowerCase();
      final titleWords = titleLower
          .split(' ')
          .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁөӨүҮ]'), ''))
          .where((w) => w.isNotEmpty)
          .toList();
      final authorWords = authorLower
          .split(' ')
          .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁөӨүҮ]'), ''))
          .where((w) => w.isNotEmpty)
          .toList();

      final matchesQuery = q.isEmpty ||
          titleLower.contains(q) ||
          authorLower.contains(q) ||
          (qTrans != q && (titleLower.contains(qTrans) || authorLower.contains(qTrans))) ||
          book.tags.any((t) => t.toLowerCase().contains(q) || (qTrans != q && t.toLowerCase().contains(qTrans))) ||
          // Typo tolerant fuzzy match (Levenshtein distance <= 2 on title or author)
          (q.length >= 3 && (_levenshtein(q, titleLower) <= 2 || _levenshtein(qTrans, titleLower) <= 2)) ||
          (q.length >= 3 && titleWords.any((w) => w.length >= 3 && (_levenshtein(q, w) <= 1 || _levenshtein(qTrans, w) <= 1))) ||
          (q.length >= 3 && (_levenshtein(q, authorLower) <= 2 || _levenshtein(qTrans, authorLower) <= 2)) ||
          (q.length >= 3 && authorWords.any((w) => w.length >= 3 && (_levenshtein(q, w) <= 1 || _levenshtein(qTrans, w) <= 1))) ||
          // In-book chapter search
          book.chapters.any((c) =>
              c.title.toLowerCase().contains(q) ||
              c.content.toLowerCase().contains(q) ||
              (qTrans != q && (c.title.toLowerCase().contains(qTrans) || c.content.toLowerCase().contains(qTrans))));

      final matchesCategory = _searchCategories.isEmpty ||
          _searchCategories.contains(book.category);

      final matchesRating = book.rating >= _minRating;
      final matchesMoodFilter = _matchesMood(book, _selectedMood);

      return matchesQuery && matchesCategory && matchesRating && matchesMoodFilter;
    }).toList();

    if (_sortBy == 'rating') {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'title') {
      result.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'newest') {
      result.sort((a, b) => b.pages.compareTo(a.pages));
    } else {
      // popular
      result.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
    }

    return result;
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _books = BookRepository.getInitialBooks();
      _bookmarks = [
        Bookmark(
          id: 'bm_default_1',
          bookId: 'book_1',
          bookTitle: '1984',
          chapterTitle: 'Part 1: The Clock Strikes Thirteen',
          pageNumber: 2,
          quote:
              'War is peace. Freedom is slavery. Ignorance is strength.',
          note: 'The party’s primary paradox slogan.',
          colorHex: 0xFFFFD54F,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Bookmark(
          id: 'bm_default_2',
          bookId: 'book_2',
          bookTitle: 'Clear Thinking',
          chapterTitle: 'Chapter 1: The Enemies of Clear Thinking',
          pageNumber: 15,
          quote:
              'Between stimulus and response lies a space. In that space is our power to choose our response.',
          note: 'Fundamental to pausing default emotional reactions.',
          colorHex: 0xFF81C784,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      _notifications = [
        NotificationItem(
          id: 'notif_1',
          title: 'Шинэ ном нэмэгдлээ',
          message: '"Atomic Habits" ном таны сан руу нэмэгдлээ. Одоо уншиж эхлээрэй!',
          time: '5 мин',
          isRead: false,
          type: 'new_book',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        NotificationItem(
          id: 'notif_2',
          title: 'Өдрийн зөвлөмж',
          message: 'Таны уншдаг төрөлд тохирох 3 шинэ ном санал болгож байна.',
          time: '1 цаг',
          isRead: false,
          type: 'recommendation',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        NotificationItem(
          id: 'notif_3',
          title: 'Амжилт!',
          message: 'Та 7 өдөр дараалан уншсаны төлөө "Номын хорхойтон" badge авлаа.',
          time: 'Өчигдөр',
          isRead: true,
          type: 'achievement',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        NotificationItem(
          id: 'notif_4',
          title: 'Аппликейшн шинэчлэгдсэн',
          message: 'Шинэ функц: Одоо та номоо аудио хэлбэрээр сонсож, эшлэлээ тэмдэглэх боломжтой боллоо.',
          time: '2 өдөр',
          isRead: true,
          type: 'system',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        NotificationItem(
          id: 'notif_5',
          title: 'Дуртай зохиолч',
          message: 'Paulo Coelho-ийн шинэ ном гарлаа. Шалгаад үзээрэй!',
          time: '3 өдөр',
          isRead: true,
          type: 'author',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList(_keySavedBooks) ?? [];
      final favIds = prefs.getStringList(_keyFavorites) ?? [];
      final searches = prefs.getStringList(_keyRecentSearches);
      if (searches != null && searches.isNotEmpty) {
        _recentSearches = searches;
      }

      final progressJson = prefs.getString(_keyReadingProgress);
      Map<String, dynamic> progressMap = {};
      if (progressJson != null) {
        progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
      }

      // Rehydrate books with saved preferences
      _books = _books.map((b) {
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

      final bookmarksJson = prefs.getStringList(_keyBookmarks);
      if (bookmarksJson != null && bookmarksJson.isNotEmpty) {
        _bookmarks = bookmarksJson
            .map((b) => Bookmark.fromJson(jsonDecode(b) as Map<String, dynamic>))
            .toList();
      }

      final profileJson = prefs.getString(_keyUserProfile);
      if (profileJson != null) {
        _userProfile = UserProfile.fromJson(
            jsonDecode(profileJson) as Map<String, dynamic>);
      }

      final notifsJson = prefs.getStringList(_keyNotifications);
      if (notifsJson != null && notifsJson.isNotEmpty) {
        _notifications = notifsJson
            .map((n) => NotificationItem.fromJson(jsonDecode(n) as Map<String, dynamic>))
            .toList();
      }

      final collectionsJson = prefs.getStringList(_keyCollections);
      if (collectionsJson != null && collectionsJson.isNotEmpty) {
        _collections = collectionsJson
            .map((c) => BookCollection.fromJson(jsonDecode(c) as Map<String, dynamic>))
            .toList();
      } else {
        _collections = [
          BookCollection(
            id: 'c_2026',
            name: '2026 онд унших зорилт',
            description: 'Энэ онд заавал дуусгах шилдэг номууд',
            icon: 'emoji_events',
            bookIds: ['book_1', 'book_3'],
            createdAt: DateTime.now().subtract(const Duration(days: 14)),
          ),
          BookCollection(
            id: 'c_growth',
            name: 'Хувь хүний хөгжил ба Зуршил',
            description: 'Дадал зуршил, сэтгэлгээний чадварууд',
            icon: 'lightbulb',
            bookIds: ['book_2', 'book_4'],
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          BookCollection(
            id: 'c_favorites',
            name: 'Шилдэг сонгодог бүтээлүүд',
            description: 'Дахин дахин эргэцүүлэн унших бүтээлүүд',
            icon: 'bookmark',
            bookIds: ['book_1', 'book_5'],
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ];
      }

      final downloadedList = prefs.getStringList(_keyDownloadedBooks);
      if (downloadedList != null) {
        _downloadedBookIds = downloadedList.toSet();
      } else {
        _downloadedBookIds = {'book_1'};
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _initData();
  }

  void toggleSaveBook(String bookId) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final updated =
          _books[index].copyWith(isSaved: !_books[index].isSaved);
      _books[index] = updated;
      notifyListeners();
      _persistSavedBooks();
    }
  }

  void toggleFavoriteBook(String bookId) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final updated =
          _books[index].copyWith(isFavorite: !_books[index].isFavorite);
      _books[index] = updated;
      notifyListeners();
      _persistFavorites();
    }
  }

  // Smooth position tracking without inflating daily reading minutes
  void updateReadingPosition(
    String bookId, {
    required int currentPage,
    required double progress,
    int? currentChapterIndex,
  }) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final updated = _books[index].copyWith(
        currentPage: currentPage,
        progress: progress.clamp(0.0, 1.0),
        currentChapterIndex: currentChapterIndex ?? _books[index].currentChapterIndex,
      );
      _books[index] = updated;
      notifyListeners();
      _persistReadingProgress();
    }
  }

  // Backwards-compatible method that also updates stats when called directly
  void updateReadingProgress(
      String bookId, int currentPage, double progress, [int? currentChapterIndex]) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final updated = _books[index].copyWith(
        currentPage: currentPage,
        progress: progress.clamp(0.0, 1.0),
        currentChapterIndex: currentChapterIndex ?? _books[index].currentChapterIndex,
      );
      _books[index] = updated;

      _userProfile = _userProfile.copyWith(
        minutesReadToday: _userProfile.minutesReadToday + 1,
      );

      notifyListeners();
      _persistReadingProgress();
      _persistUserProfile();
    }
  }

  // Dedicated active reading time tracker
  void addReadingMinutes(int minutes) {
    if (minutes <= 0) return;
    final oldMinutes = _userProfile.minutesReadToday;
    final newMinutes = oldMinutes + minutes;
    int earnedXp = minutes * 5;
    if (oldMinutes < _userProfile.dailyGoalMinutes &&
        newMinutes >= _userProfile.dailyGoalMinutes) {
      earnedXp += 50; // Daily goal achieved bonus
    }

    _userProfile = _userProfile.copyWith(
      minutesReadToday: newMinutes,
      xp: _userProfile.xp + earnedXp,
    );

    // Check achievement unlock
    if (newMinutes >= _userProfile.dailyGoalMinutes) {
      final updatedAchievements = _userProfile.achievements.map((a) {
        if (a.id == 'daily_goal') {
          return a.copyWith(isUnlocked: true);
        }
        return a;
      }).toList();
      _userProfile = _userProfile.copyWith(achievements: updatedAchievements);
    }

    notifyListeners();
    _persistUserProfile();
  }

  void loginAsGuest() {
    _userProfile = _userProfile.copyWith(
      name: 'Зочин',
      email: 'guest@readpack.app',
      isGuest: true,
      streakDays: 1,
    );
    notifyListeners();
    _persistUserProfile();
  }

  void loginWithEmail(String email, String name) {
    _userProfile = _userProfile.copyWith(
      name: name.isNotEmpty ? name : 'Уншигч',
      email: email,
      isGuest: false,
    );
    notifyListeners();
    _persistUserProfile();
  }

  void logout() {
    _userProfile = const UserProfile(
      name: 'Зочин',
      email: 'guest@readpack.app',
      isGuest: true,
      streakDays: 0,
      minutesReadToday: 0,
    );
    notifyListeners();
    _persistUserProfile();
  }

  void updateUserProfile({
    String? name,
    String? email,
    int? dailyGoalMinutes,
    bool? notificationsEnabled,
    bool? recommendationsEnabled,
    bool? streakFreezeAvailable,
  }) {
    _userProfile = _userProfile.copyWith(
      name: name,
      email: email,
      dailyGoalMinutes: dailyGoalMinutes,
      notificationsEnabled: notificationsEnabled,
      recommendationsEnabled: recommendationsEnabled,
      streakFreezeAvailable: streakFreezeAvailable,
    );
    notifyListeners();
    _persistUserProfile();
  }

  void clearCache() {
    _recentSearches.clear();
    _persistRecentSearches();
    notifyListeners();
  }

  void addBookmark(Bookmark bookmark) {
    _bookmarks.insert(0, bookmark);
    notifyListeners();
    _persistBookmarks();
  }

  void removeBookmark(String bookmarkId) {
    _bookmarks.removeWhere((b) => b.id == bookmarkId);
    notifyListeners();
    _persistBookmarks();
  }

  void addReview(String bookId, BookReview review) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final currentBook = _books[index];
      final updatedReviews = [review, ...currentBook.reviews];
      final newCount = currentBook.reviewsCount + 1;
      final newRating = double.parse(
        (((currentBook.rating * currentBook.reviewsCount) + review.rating) / newCount)
            .toStringAsFixed(1),
      );

      _books[index] = currentBook.copyWith(
        reviews: updatedReviews,
        reviewsCount: newCount,
        rating: newRating,
      );
      notifyListeners();
    }
  }

  // Live filter; commits to history if not typing
  void setSearchQuery(String query, {bool isTyping = false}) {
    _searchQuery = query;
    if (!isTyping && query.trim().isNotEmpty) {
      commitSearchQuery(query);
    } else {
      notifyListeners();
    }
  }

  // Commit on enter or item click to save to search history
  void commitSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.length >= 2) {
      _recentSearches.remove(trimmed);
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
      _persistRecentSearches();
      notifyListeners();
    }
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
    _persistRecentSearches();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
    _persistRecentSearches();
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

  // Notifications API
  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      _persistNotifications();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    _persistNotifications();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    _persistNotifications();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
    _persistNotifications();
  }

  Future<void> _persistNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_keyNotifications, list);
  }

  Future<void> _persistSavedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds =
        _books.where((b) => b.isSaved).map((b) => b.id).toList();
    await prefs.setStringList(_keySavedBooks, savedIds);
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds =
        _books.where((b) => b.isFavorite).map((b) => b.id).toList();
    await prefs.setStringList(_keyFavorites, favIds);
  }

  Future<void> _persistRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRecentSearches, _recentSearches);
  }

  Future<void> _persistBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _bookmarks.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(_keyBookmarks, jsonList);
  }

  Future<void> _persistReadingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> map = {};
    for (final b in _books) {
      if (b.progress > 0) {
        map[b.id] = {
          'progress': b.progress,
          'currentPage': b.currentPage,
          'chapterIndex': b.currentChapterIndex,
        };
      }
    }
    await prefs.setString(_keyReadingProgress, jsonEncode(map));
  }

  void toggleReviewHelpful(String bookId, String reviewId) {
    final bookIndex = _books.indexWhere((b) => b.id == bookId);
    if (bookIndex != -1) {
      final book = _books[bookIndex];
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
        _books[bookIndex] = book.copyWith(reviews: updatedReviews);
        if (isNowHelpful) {
          addXp(10);
        }
        notifyListeners();
      }
    }
  }

  void setLibrarySortBy(String sortBy) {
    _librarySortBy = sortBy;
    notifyListeners();
  }

  void setSelectedMood(String mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void createCollection(String name, String description, {String icon = 'bookmark'}) {
    final newCollection = BookCollection(
      id: 'coll_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isNotEmpty ? name.trim() : 'Шинэ цуглуулга',
      description: description.trim(),
      icon: icon,
      createdAt: DateTime.now(),
      bookIds: [],
    );
    _collections.insert(0, newCollection);
    addXp(30);
    notifyListeners();
    _persistCollections();
  }

  void deleteCollection(String id) {
    _collections.removeWhere((c) => c.id == id);
    notifyListeners();
    _persistCollections();
  }

  void addBookToCollection(String collectionId, String bookId) {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      if (!_collections[index].bookIds.contains(bookId)) {
        final updatedIds = [..._collections[index].bookIds, bookId];
        _collections[index] = _collections[index].copyWith(bookIds: updatedIds);
        addXp(15);
        notifyListeners();
        _persistCollections();
      }
    }
  }

  void removeBookFromCollection(String collectionId, String bookId) {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      final updatedIds =
          _collections[index].bookIds.where((id) => id != bookId).toList();
      _collections[index] = _collections[index].copyWith(bookIds: updatedIds);
      notifyListeners();
      _persistCollections();
    }
  }

  void toggleDownloadBook(String bookId) {
    if (_downloadedBookIds.contains(bookId)) {
      _downloadedBookIds.remove(bookId);
    } else {
      _downloadedBookIds.add(bookId);
      addXp(20);
    }
    notifyListeners();
    _persistDownloadedBooks();
  }

  bool isBookDownloaded(String bookId) => _downloadedBookIds.contains(bookId);

  double getDownloadedSizeMb(String bookId) {
    final book = _books.firstWhere((b) => b.id == bookId, orElse: () => _books.first);
    return double.parse((8.5 + (book.pages * 0.04)).toStringAsFixed(1));
  }

  double get totalDownloadedStorageMb {
    return double.parse(_downloadedBookIds
        .fold<double>(0.0, (acc, id) => acc + getDownloadedSizeMb(id))
        .toStringAsFixed(1));
  }

  void addXp(int amount) {
    if (amount <= 0) return;
    _userProfile = _userProfile.copyWith(xp: _userProfile.xp + amount);
    notifyListeners();
    _persistUserProfile();
  }

  int get userLevel {
    final xp = _userProfile.xp;
    if (xp < 500) return 1;
    if (xp < 1500) return 2;
    if (xp < 3000) return 3;
    if (xp < 5000) return 4;
    return 5;
  }

  String get userLevelTitle {
    final xp = _userProfile.xp;
    if (xp < 500) return 'Эхлэн уншигч (Lv. 1)';
    if (xp < 1500) return 'Идэвхтэй уншигч (Lv. 2)';
    if (xp < 3000) return 'Номын хорхойтон (Lv. 3)';
    if (xp < 5000) return 'Мэргэшсэн уншигч (Lv. 4)';
    return 'Мэргэн уншигч (Lv. 5)';
  }

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
    _persistUserProfile();
  }

  Future<void> _persistCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _collections.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_keyCollections, list);
  }

  Future<void> _persistDownloadedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyDownloadedBooks, _downloadedBookIds.toList());
  }

  Future<void> _persistUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, jsonEncode(_userProfile.toJson()));
  }
}
