import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/reader/widgets/reader_theme_helpers.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ReaderScrollView extends StatelessWidget {
  final Book book;
  final BookChapter currentChapter;
  final int currentChapterIndex;
  final List<String> paragraphs;
  final int activeAudioParagraph;
  final bool isAudioPlaying;
  final ScrollController scrollController;
  final ThemeProvider themeProvider;
  final Color readerTextColor;
  final VoidCallback onToggleControls;
  final ValueChanged<String> onShowHighlight;
  final ValueChanged<int> onGoToChapter;
  final AppLocalizations? l10n;

  const ReaderScrollView({
    super.key,
    required this.book,
    required this.currentChapter,
    required this.currentChapterIndex,
    required this.paragraphs,
    required this.activeAudioParagraph,
    required this.isAudioPlaying,
    required this.scrollController,
    required this.themeProvider,
    required this.readerTextColor,
    required this.onToggleControls,
    required this.onShowHighlight,
    required this.onGoToChapter,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final hasChapters = book.chapters.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggleControls,
      child: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 72)),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: themeProvider.horizontalMargin,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentChapter.title,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: (22 * themeProvider.fontSizeScale)
                          .clamp(16.0, 32.0),
                      fontWeight: FontWeight.bold,
                      color: readerTextColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: (13 * themeProvider.fontSizeScale)
                          .clamp(11.0, 18.0),
                      color: readerTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(paragraphs.length, (pIndex) {
                    final paragraph = paragraphs[pIndex];
                    final isAudioActive =
                        isAudioPlaying && pIndex == activeAudioParagraph;

                    final matchingBookmark = bookProvider.bookmarks.where(
                      (b) =>
                          b.bookId == book.id &&
                          paragraph.contains(b.quote.substring(
                              0,
                              b.quote.length > 25
                                  ? 25
                                  : b.quote.length)),
                    ).firstOrNull;
                    final hasBookmark = matchingBookmark != null;
                    final highlightColor = matchingBookmark != null
                        ? Color(matchingBookmark.colorHex)
                        : Colors.amber;

                    return GestureDetector(
                      onLongPress: () => onShowHighlight(paragraph),
                      onDoubleTap: () => onShowHighlight(paragraph),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: (isAudioActive || hasBookmark)
                            ? const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8)
                            : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: isAudioActive
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : (hasBookmark
                                  ? highlightColor.withValues(alpha: 0.16)
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(10),
                          border: isAudioActive
                              ? Border(
                                  left: BorderSide(
                                    color: colorScheme.primary,
                                    width: 3.5,
                                  ),
                                )
                              : (hasBookmark
                                  ? Border(
                                      left: BorderSide(
                                        color: highlightColor,
                                        width: 3.5,
                                      ),
                                    )
                                  : null),
                        ),
                        child: Text(
                          paragraph,
                          style: ReaderThemeHelpers.getReaderTextStyle(
                              themeProvider, readerTextColor),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  if (hasChapters)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentChapterIndex > 0)
                          AnimatedPressable(
                            onTap: () => onGoToChapter(currentChapterIndex - 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: readerTextColor
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back_ios_rounded,
                                      size: 14, color: readerTextColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n?.t('reader.prev_chapter') ??
                                        'Өмнөх бүлэг',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: readerTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (currentChapterIndex < book.chapters.length - 1)
                          AnimatedPressable(
                            onTap: () => onGoToChapter(currentChapterIndex + 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    l10n?.t('reader.next_chapter') ??
                                        'Дараагийн бүлэг',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: colorScheme.onPrimary),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
