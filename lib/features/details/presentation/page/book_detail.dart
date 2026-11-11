import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/details/widgets/book_detail_app_bar.dart';
import 'package:readpack/features/details/widgets/book_detail_chapters_tab.dart';
import 'package:readpack/features/details/widgets/book_detail_overview_tab.dart';
import 'package:readpack/features/details/widgets/book_detail_reviews_tab.dart';
import 'package:readpack/features/details/widgets/book_detail_similar_tab.dart';
import 'package:readpack/features/details/widgets/book_detail_stats.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  int _selectedTabIndex = 0;

  Widget _buildTabBar(ColorScheme colorScheme, AppLocalizations? l10n) {
    final tabs = [
      l10n?.t('book.tabs.overview') ?? 'Тойм',
      l10n?.t('book.tabs.chapters') ?? 'Бүлгүүд',
      l10n?.t('book.tabs.reviews') ?? 'Сэтгэгдэл',
      l10n?.t('book.tabs.similar') ?? 'Ижил төстэй',
    ];

    return SizedBox(
      height: 80,
      child: Container(
        color: colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = _selectedTabIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(tabs[index], maxLines: 1),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  side: BorderSide(color: colorScheme.outlineVariant),
                  onSelected: (_) => setState(() => _selectedTabIndex = index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);

    // Get reactive updated book instance if present
    final currentBook = bookProvider.books.firstWhere(
      (b) => b.id == widget.book.id,
      orElse: () => widget.book,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          BookDetailAppBar(
            currentBook: currentBook,
            bookProvider: bookProvider,
            l10n: l10n,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      currentBook.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      currentBook.author,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  if (currentBook.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: currentBook.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  BookDetailStats(book: currentBook, l10n: l10n),
                  const SizedBox(height: 20),
                  BookDetailActionButtons(
                    book: currentBook,
                    showAudioPlayer: false,
                    onToggleAudio: () {
                      if (!currentBook.chapters.any(
                        (chapter) => chapter.content.trim().isNotEmpty,
                      )) {
                        return;
                      }
                      Navigator.of(context).pushNamed(
                        Routes.reader,
                        arguments: {
                          'book': currentBook,
                          'initialChapterIndex':
                              currentBook.currentChapterIndex,
                          'openAudioInitially': true,
                        },
                      );
                    },
                    l10n: l10n,
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedDetailTabsDelegate(
              child: _buildTabBar(colorScheme, l10n),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: switch (_selectedTabIndex) {
                1 => BookDetailChaptersTab(
                  currentBook: currentBook,
                  l10n: l10n,
                ),
                2 => BookDetailReviewsTab(currentBook: currentBook, l10n: l10n),
                3 => BookDetailSimilarTab(currentBook: currentBook, l10n: l10n),
                _ => BookDetailOverviewTab(
                  currentBook: currentBook,
                  l10n: l10n,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedDetailTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _PinnedDetailTabsDelegate({required this.child});

  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(covariant _PinnedDetailTabsDelegate oldDelegate) =>
      child != oldDelegate.child;
}
