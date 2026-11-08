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

  const BookDetailPage({
    super.key,
    required this.book,
  });

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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
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
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.08),
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
                      if (!currentBook.hasAudio) return;
                      Navigator.of(context).pushNamed(
                        Routes.reader,
                        arguments: {
                          'book': currentBook,
                          'initialChapterIndex': currentBook.currentChapterIndex,
                          'openAudioInitially': true,
                        },
                      );
                    },
                    l10n: l10n,
                  ),
                  _buildTabBar(colorScheme, l10n),
                  if (_selectedTabIndex == 0)
                    BookDetailOverviewTab(
                      currentBook: currentBook,
                      l10n: l10n,
                    ),
                  if (_selectedTabIndex == 1)
                    BookDetailChaptersTab(
                      currentBook: currentBook,
                      l10n: l10n,
                    ),
                  if (_selectedTabIndex == 2)
                    BookDetailReviewsTab(
                      currentBook: currentBook,
                      l10n: l10n,
                    ),
                  if (_selectedTabIndex == 3)
                    BookDetailSimilarTab(
                      currentBook: currentBook,
                      l10n: l10n,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
