import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/library/widgets/library_quote_card.dart';
import 'package:readpack/features/library/widgets/library_reading_card.dart';
import 'package:readpack/features/library/widgets/library_saved_card.dart';
import 'package:readpack/features/library/widgets/library_shelves_view.dart';
import 'package:readpack/features/library/widgets/library_sort_bar.dart';
import 'package:readpack/features/shared/common/refresh.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class SavedPage extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const SavedPage({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  // 0: Currently Reading, 1: Saved, 2: Shelves / Collections, 3: Quotes
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);

    final libraryTitle = l10n?.t('library.title') ?? 'Миний Сан';
    final readingSegment =
        l10n?.t('library.currently_reading') ?? 'Уншиж буй';
    final savedSegment = l10n?.t('library.saved') ?? 'Хадгалсан';
    final shelvesSegment = l10n?.t('library.shelves') ?? 'Цуглуулгууд';
    final quotesSegment = l10n?.t('library.quotes') ?? 'Ишлэлүүд';
    final booksCountText = l10n?.t('home.books_count') ?? 'ном';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshWrapper(
          onRefresh: () => bookProvider.refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            libraryTitle,
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${bookProvider.savedBooks.length + bookProvider.continueReadingBooks.length} $booksCountText',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 4-Segment Switcher
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _buildSegmentItem(0, readingSegment, colorScheme),
                            _buildSegmentItem(1, savedSegment, colorScheme),
                            _buildSegmentItem(2, shelvesSegment, colorScheme),
                            _buildSegmentItem(3, quotesSegment, colorScheme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sort Bar for Reading and Saved segments
              if (_selectedSegment == 0 || _selectedSegment == 1)
                SliverToBoxAdapter(
                  child: LibrarySortBar(provider: bookProvider),
                ),

              _buildContent(bookProvider, colorScheme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentItem(
    int index,
    String label,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedSegment == index;

    return Expanded(
      child: AnimatedPressable(
        onTap: () => setState(() => _selectedSegment = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BookProvider provider,
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
    // 1. Loading State
    if (provider.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: SkeletonLoader(
                width: double.infinity,
                height: 100,
                borderRadius: 16,
              ),
            ),
            childCount: 4,
          ),
        ),
      );
    }

    // 2. Error State
    if (provider.errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateView(
          errorMessage: provider.errorMessage!,
          onRetry: () => provider.refresh(),
        ),
      );
    }

    // 3. Segment 0: Currently Reading
    if (_selectedSegment == 0) {
      final readingBooks = provider.continueReadingBooks;
      if (readingBooks.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            icon: Icons.menu_book_rounded,
            title: l10n?.t('library.empty_reading_title') ??
                'Одоогоор уншиж буй ном алга',
            message: l10n?.t('library.empty_reading_desc') ??
                'Нүүр хуудаснаас сонирхсон номоо сонгоод уншиж эхлээрэй.',
            actionLabel: l10n?.t('library.explore_books') ?? 'Ном хайх',
            onAction: () => widget.onNavigateTab?.call(0),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final book = readingBooks[index];
              return LibraryReadingCard(
                book: book,
                provider: provider,
              );
            },
            childCount: readingBooks.length,
          ),
        ),
      );
    }

    // 4. Segment 1: Saved Books
    if (_selectedSegment == 1) {
      final savedBooks = provider.sortedSavedBooks;
      if (savedBooks.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            icon: Icons.bookmark_border_rounded,
            title: l10n?.t('library.empty_saved_title') ??
                'Хадгалсан ном байхгүй байна',
            message: l10n?.t('library.empty_saved_desc') ??
                'Дараа уншихаар хадгалсан номнууд тань энд харагдана.',
            actionLabel: l10n?.t('library.explore_books') ?? 'Номууд үзэх',
            onAction: () => widget.onNavigateTab?.call(0),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.60,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final book = savedBooks[index];
              return LibrarySavedCard(
                book: book,
                provider: provider,
              );
            },
            childCount: savedBooks.length,
          ),
        ),
      );
    }

    // 5. Segment 2: Custom Shelves / Collections
    if (_selectedSegment == 2) {
      return LibraryShelvesView(provider: provider);
    }

    // 6. Segment 3: Quotes / Bookmarks
    final bookmarks = provider.bookmarks;
    if (bookmarks.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateView(
          icon: Icons.format_quote_rounded,
          title: l10n?.t('library.empty_quotes_title') ??
              'Тэмдэглэсэн ишлэл одоогоор алга',
          message: l10n?.t('library.empty_quotes_desc') ??
              'Ном уншиж байхдаа онцлох эшлэлээ тэмдэглэн авч, эндээс хараарай.',
          actionLabel: l10n?.t('library.explore_books') ?? 'Ном унших',
          onAction: () => widget.onNavigateTab?.call(0),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final bm = bookmarks[index];
            return LibraryQuoteCard(
              bm: bm,
              provider: provider,
            );
          },
          childCount: bookmarks.length,
        ),
      ),
    );
  }
}
