import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/library/widgets/library_quote_card.dart';
import 'package:readpack/features/library/widgets/library_reading_card.dart';
import 'package:readpack/features/library/widgets/library_saved_card.dart';
import 'package:readpack/features/library/widgets/library_shelves_view.dart';
import 'package:readpack/features/library/widgets/library_sort_bar.dart';
import 'package:readpack/features/quotes/presentation/phone_widget_sheet.dart';
import 'package:readpack/features/shared/common/refresh.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class SavedPage extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  final int initialSegment;

  const SavedPage({
    super.key,
    this.onNavigateTab,
    this.initialSegment = 0,
  });

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  // 0: Currently Reading, 1: Saved, 2: Shelves / Collections, 3: Quotes
  late int _selectedSegment;
  int _previousSegment = 0;
  int _quoteFilterIndex = 0; // 0: All, 1: Bookmarked, 2: Liked

  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.initialSegment;
    _previousSegment = widget.initialSegment;
  }

  void _selectSegment(int index) {
    if (_selectedSegment == index) return;
    setState(() {
      _previousSegment = _selectedSegment;
      _selectedSegment = index;
    });
  }

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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshWrapper(
          onRefresh: () => bookProvider.refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 16),
                      // 4-Segment Switcher with Sliding Pill Animation
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final tabWidth = constraints.maxWidth / 4;
                            return Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                  left: _selectedSegment * tabWidth,
                                  top: 0,
                                  bottom: 0,
                                  width: tabWidth,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary
                                              .withValues(alpha: 0.22),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildSegmentItem(
                                        0, readingSegment, colorScheme),
                                    _buildSegmentItem(
                                        1, savedSegment, colorScheme),
                                    _buildSegmentItem(
                                        2, shelvesSegment, colorScheme),
                                    _buildSegmentItem(
                                        3, quotesSegment, colorScheme),
                                  ],
                                ),
                              ],
                            );
                          },
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _selectSegment(index),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.72),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

    // 6. Segment 3: Quotes / Bookmarks (All, Saved, Liked)
    final allBookmarks = provider.bookmarks;
    List<Bookmark> displayedBookmarks;
    if (_quoteFilterIndex == 1) {
      displayedBookmarks = allBookmarks.where((b) => !b.isLiked).toList();
    } else if (_quoteFilterIndex == 2) {
      displayedBookmarks = allBookmarks.where((b) => b.isLiked).toList();
    } else {
      displayedBookmarks = allBookmarks;
    }

    final filterAllText = l10n?.t('library.filter_all') ?? 'Бүгд';
    final filterBookmarkedText =
        l10n?.t('library.filter_bookmarked') ?? 'Тэмдэглэсэн';
    final filterLikedText = l10n?.t('library.filter_liked') ?? 'Таалагдсан';

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Sub-Filter Bar & Phone Widget Button
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildQuoteFilterChip(
                          index: 0,
                          label: '$filterAllText (${allBookmarks.length})',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _buildQuoteFilterChip(
                          index: 1,
                          label:
                              '$filterBookmarkedText (${allBookmarks.where((b) => !b.isLiked).length})',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _buildQuoteFilterChip(
                          index: 2,
                          label:
                              '$filterLikedText ❤️ (${allBookmarks.where((b) => b.isLiked).length})',
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: l10n?.t('widget.title') ?? 'Утасны дэлгэцийн виджет',
                  child: AnimatedPressable(
                    onTap: () => PhoneWidgetSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(
                        Icons.widgets_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: Offset(_selectedSegment >= _previousSegment ? 0.06 : -0.06, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: displayedBookmarks.isEmpty
                ? Container(
                    key: ValueKey('empty_quotes_$_quoteFilterIndex'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _quoteFilterIndex == 2
                              ? Icons.favorite_border_rounded
                              : Icons.format_quote_rounded,
                          size: 40,
                          color: colorScheme.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _quoteFilterIndex == 2
                              ? (l10n?.t('library.empty_liked_quotes_title') ??
                                  'Таалагдсан ишлэл хараахан алга')
                              : (l10n?.t('library.empty_quotes_title') ??
                                  'Ишлэл олдсонгүй'),
                          style: const TextStyle(
                            fontFamily: 'Serif',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _quoteFilterIndex == 2
                              ? (l10n?.t('library.empty_liked_quotes_desc') ??
                                  'Ишлэлүүд дээрх зүрхэн дээр дарж таалагдсандаа нэмээрэй.')
                              : (l10n?.t('library.empty_quotes_desc') ??
                                  'Ном уншиж байхдаа онцлох эшлэлээ тэмдэглэн аваарай.'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    key: ValueKey(
                        'quotes_list_${_quoteFilterIndex}_${displayedBookmarks.length}'),
                    children: displayedBookmarks.map((bm) {
                      return LibraryQuoteCard(
                        bm: bm,
                        provider: provider,
                      );
                    }).toList(),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _buildQuoteFilterChip({
    required int index,
    required String label,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _quoteFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _quoteFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}
