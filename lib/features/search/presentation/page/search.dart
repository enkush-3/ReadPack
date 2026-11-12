import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/search/widgets/filtershell.dart';
import 'package:readpack/features/search/widgets/header.dart';
import 'package:readpack/features/search/widgets/searchhistory.dart';
import 'package:readpack/features/search/widgets/searchresult.dart';
import 'package:readpack/features/shared/common/refresh.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/inputfield.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class SearchPage extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const SearchPage({super.key, this.onNavigateTab});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshWrapper(
          onRefresh: () => bookProvider.refresh(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: SearchHeader(
                  userName: bookProvider.userProfile.isGuest
                      ? (AppLocalizations.of(
                              context,
                            )?.t('profile.guest_user') ??
                            bookProvider.userProfile.name)
                      : bookProvider.userProfile.name,
                  onAvatarTap: () => widget.onNavigateTab?.call(3),
                  currentFilters: FilterData(
                    categories: List.from(bookProvider.searchCategories),
                    minRating: bookProvider.minRating,
                    sortBy: bookProvider.sortBy,
                    priceRange: 'all',
                  ),
                  onFilterApplied: (filterData) {
                    bookProvider.applyFilters(
                      categories: filterData.categories,
                      minRating: filterData.minRating,
                      sortBy: filterData.sortBy,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Focus(
                        onFocusChange: (focused) {
                          if (_isSearchFocused != focused) {
                            setState(() => _isSearchFocused = focused);
                          }
                        },
                        child: InputField(
                          controller: _searchController,
                          hint:
                              AppLocalizations.of(context)?.t('hint.search') ??
                              'Ном, зохиолч хайх...',
                          icon: Icons.search_rounded,
                          borderRadius: 26,
                          textInputAction: TextInputAction.search,
                          onChanged: (val) {
                            setState(() {});
                            bookProvider.setSearchQueryWhileTyping(val);
                          },
                          onSubmitted: (val) {
                            bookProvider.setSearchQuery(val);
                          },
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          bookProvider.setSearchQuery('');
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // Did-you-mean Suggestion Banner
              if (bookProvider.searchSuggestion != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_fix_high_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text:
                                  '${l10n?.t('search.did_you_mean') ?? 'Та үүнийг хайсан уу'}: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface,
                              ),
                              children: [
                                TextSpan(
                                  text: bookProvider.searchSuggestion!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _searchController.text =
                                bookProvider.searchSuggestion!;
                            bookProvider.setSearchQuery(
                              bookProvider.searchSuggestion!,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n?.t('search.search_action') ?? 'Хайх',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Category filters keep a single row while mood is grouped into
              // one accessible control below.
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildQuickPill(
                      'all',
                      l10n?.t('common.all') ?? 'Бүгд',
                      bookProvider,
                      colorScheme,
                    ),
                    _buildQuickPill(
                      'book.categories.history',
                      l10n?.t('book.categories.history') ?? 'Түүх',
                      bookProvider,
                      colorScheme,
                    ),
                    _buildQuickPill(
                      'book.categories.business',
                      l10n?.t('book.categories.business') ?? 'Бизнес',
                      bookProvider,
                      colorScheme,
                    ),
                    _buildQuickPill(
                      'book.categories.science',
                      l10n?.t('book.categories.science') ?? 'Шинжлэх ухаан',
                      bookProvider,
                      colorScheme,
                    ),
                    _buildQuickPill(
                      'book.categories.romance',
                      l10n?.t('book.categories.romance') ?? 'Роман',
                      bookProvider,
                      colorScheme,
                    ),
                    _buildQuickPill(
                      'book.categories.adventure',
                      l10n?.t('book.categories.adventure') ?? 'Адал явдал',
                      bookProvider,
                      colorScheme,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildMoodFilterButton(bookProvider, colorScheme),
                ),
              ),
              // Search History (shown only when search input is focused and empty)
              if (_isSearchFocused &&
                  _searchController.text.isEmpty &&
                  bookProvider.recentSearches.isNotEmpty)
                SearchHistory(
                  recentSearches: bookProvider.recentSearches,
                  onSelect: (query) {
                    _searchController.text = query;
                    FocusScope.of(context).unfocus();
                    bookProvider.setSearchQuery(query);
                    bookProvider.commitSearchQuery(query);
                  },
                  onClearAll: () {
                    bookProvider.clearRecentSearches();
                  },
                  onRemove: (query) {
                    bookProvider.removeRecentSearch(query);
                  },
                ),
              // Main content area
              Expanded(child: _buildSearchContent(bookProvider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent(BookProvider provider) {
    if (provider.isLoading ||
        (provider.isFetchingRemote && provider.searchResults.isEmpty)) {
      return _buildSearchSkeleton();
    }
    if (provider.errorMessage != null && provider.books.isEmpty) {
      return _buildInitializationError(provider);
    }
    return _buildSearchResults(provider);
  }

  Widget _buildInitializationError(BookProvider provider) =>
      SingleChildScrollView(
        child: ErrorStateView(
          errorMessage: provider.errorMessage!,
          onRetry: provider.retryInitialization,
        ),
      );

  Widget _buildSearchResults(BookProvider provider) {
    final searchResults = provider.searchResults;
    final remoteError = provider.remoteBooksErrorMessage;
    if (remoteError != null && searchResults.isEmpty) {
      return ErrorStateView(
        errorMessage: remoteError,
        onRetry: () => provider.fetchRemoteBooks(query: provider.searchQuery),
      );
    }
    return _buildSearchResultsBody(provider, searchResults, remoteError);
  }

  Widget _buildSearchResultsBody(
    BookProvider provider,
    List<Book> searchResults,
    String? remoteError,
  ) => Column(
    children: [
      if (provider.isFetchingRemote)
        const LinearProgressIndicator(minHeight: 2),
      if (remoteError != null) _buildRemoteSearchError(provider, remoteError),
      _buildSearchResultList(provider, searchResults),
    ],
  );

  Widget _buildSearchResultList(
    BookProvider provider,
    List<Book> searchResults,
  ) => Expanded(
    child: SearchResult(
      books: searchResults,
      onResetFilter: () {
        _searchController.clear();
        provider.resetFilters();
      },
    ),
  );

  Widget _buildSearchSkeleton() => GridView.builder(
    padding: const EdgeInsets.all(24),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.54,
    ),
    itemCount: 6,
    itemBuilder: (_, __) => const BookCardSkeleton(),
  );

  Widget _buildRemoteSearchError(BookProvider provider, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildRemoteErrorIcon(colorScheme),
            Expanded(child: _buildRemoteErrorMessage(message, colorScheme)),
            _buildRemoteRetryButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteErrorIcon(ColorScheme colorScheme) => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Icon(Icons.cloud_off_rounded, color: colorScheme.onErrorContainer),
  );

  Widget _buildRemoteErrorMessage(String message, ColorScheme colorScheme) =>
      Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colorScheme.onErrorContainer),
      );

  Widget _buildRemoteRetryButton(BookProvider provider) => TextButton.icon(
    onPressed: () => provider.fetchRemoteBooks(query: provider.searchQuery),
    icon: const Icon(Icons.refresh_rounded, size: 18),
    label: Text(
      AppLocalizations.of(context)?.t('common.retry') ?? 'Дахин оролдох',
    ),
  );

  Widget _buildQuickPill(
    String key,
    String defaultLabel,
    BookProvider bookProvider,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    final displayLabel = key == 'all'
        ? (l10n?.t('filter.all') ?? defaultLabel)
        : (l10n?.t(key) ?? defaultLabel);

    final isSelected = key == 'all'
        ? bookProvider.searchCategories.isEmpty
        : bookProvider.searchCategories.contains(key);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        showCheckmark: false,
        visualDensity: VisualDensity.standard,
        label: Text(displayLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        selected: isSelected,
        onSelected: (_) {
          if (key == 'all') {
            bookProvider.applyFilters(categories: []);
          } else {
            bookProvider.applyFilters(categories: [key]);
          }
        },
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(
          color: isSelected
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    );
  }

  Widget _buildMoodFilterButton(
    BookProvider provider,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    final moodLabels = <String, String>{
      'all': l10n?.t('search.mood_all') ?? 'Бүх хэмнэл',
      'inspiring': l10n?.t('search.mood_inspiring') ?? 'Урам зориг',
      'philosophical': l10n?.t('search.mood_philosophical') ?? 'Гүн ухаан',
      'light_reading': l10n?.t('search.mood_light') ?? 'Хөнгөн уншлага',
      'deep_focus': l10n?.t('search.mood_focus') ?? 'Гүн төвлөрөл',
    };
    final currentLabel =
        moodLabels[provider.selectedMood] ?? moodLabels['all']!;
    final hasSelectedMood = provider.selectedMood != 'all';

    return OutlinedButton.icon(
      onPressed: () => _showMoodPicker(provider, moodLabels),
      icon: const Icon(Icons.tune_rounded),
      label: Text(
        '${l10n?.t('search.mood_filter') ?? 'Унших хэмнэл'}: $currentLabel',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: hasSelectedMood
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
        side: BorderSide(
          color: hasSelectedMood
              ? colorScheme.primary
              : colorScheme.outlineVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showMoodPicker(
    BookProvider provider,
    Map<String, String> moodLabels,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.t('search.mood_filter') ?? 'Унших хэмнэл',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: moodLabels.entries.map((entry) {
                  final isSelected = provider.selectedMood == entry.key;
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (_) {
                      provider.setSelectedMood(entry.key);
                      Navigator.of(sheetContext).pop();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
