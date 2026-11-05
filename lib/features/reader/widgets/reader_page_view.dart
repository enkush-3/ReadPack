import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/reader/widgets/reader_theme_helpers.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';

class ReaderPageView extends StatefulWidget {
  final Book book;
  final BookChapter currentChapter;
  final int currentChapterIndex;
  final int currentPageInChapter;
  final List<BookChapter> chapters;
  final PageController pageController;
  final ThemeProvider themeProvider;
  final Color readerTextColor;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onGoToChapter;
  final VoidCallback onToggleControls;
  final ValueChanged<String> onShowHighlight;
  final AppLocalizations? l10n;

  const ReaderPageView({
    super.key,
    required this.book,
    required this.currentChapter,
    required this.currentChapterIndex,
    required this.currentPageInChapter,
    required this.chapters,
    required this.pageController,
    required this.themeProvider,
    required this.readerTextColor,
    required this.onPageChanged,
    required this.onGoToChapter,
    required this.onToggleControls,
    required this.onShowHighlight,
    this.l10n,
  });

  @override
  State<ReaderPageView> createState() => _ReaderPageViewState();
}

class _ReaderPageViewState extends State<ReaderPageView> {
  String? _selectedText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final pages =
        ReaderThemeHelpers.paginateChapter(widget.currentChapter.content);
    final pageCount = pages.length;
    final hasNextChapter = widget.chapters.isNotEmpty &&
        widget.currentChapterIndex < widget.chapters.length - 1;
    final totalPageCount = pageCount + (hasNextChapter ? 1 : 0);

    return PageView.builder(
      controller: widget.pageController,
      itemCount: totalPageCount,
      physics: const BouncingScrollPhysics(),
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, pIndex) {
        if (pIndex >= pageCount) {
          final nextChapter = widget.chapters[widget.currentChapterIndex + 1];
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.currentChapter.title} уншиж дууслаа!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.readerTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Дараагийн бүлэг: ${nextChapter.title}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.readerTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => widget.onGoToChapter(widget.currentChapterIndex + 1),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      widget.l10n?.t('reader.next_chapter') ?? 'Дараагийн бүлэг',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final pageText = pages[pIndex];
        final isLastPage = pIndex == pageCount - 1;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () => widget.onShowHighlight(pageText),
          onLongPress: () => widget.onShowHighlight(pageText),
          onTapUp: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            final dx = details.localPosition.dx;
            if (dx < screenWidth * 0.22) {
              if (widget.currentPageInChapter > 0) {
                widget.pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                );
              } else if (widget.currentChapterIndex > 0) {
                widget.onGoToChapter(widget.currentChapterIndex - 1);
              }
            } else if (dx > screenWidth * 0.78) {
              if (widget.currentPageInChapter < pageCount - 1) {
                widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                );
              } else if (widget.currentChapterIndex < widget.chapters.length - 1) {
                widget.onGoToChapter(widget.currentChapterIndex + 1);
              }
            } else {
              widget.onToggleControls();
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.themeProvider.horizontalMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 76),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.currentChapter.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: (18 * widget.themeProvider.fontSizeScale)
                              .clamp(14.0, 26.0),
                          fontWeight: FontWeight.bold,
                          color: widget.readerTextColor,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.l10n?.t('reader.chapter') ?? 'Бүлэг'} ${widget.currentChapterIndex + 1}/${widget.chapters.isEmpty ? 1 : widget.chapters.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.readerTextColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.book.author,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.readerTextColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SelectionArea(
                    onSelectionChanged: (content) {
                      _selectedText = content?.plainText;
                    },
                    contextMenuBuilder: (context, selectableRegionState) {
                      final defaultItems =
                          selectableRegionState.contextMenuButtonItems;
                      final items = [
                        ...defaultItems,
                        ContextMenuButtonItem(
                          label: '📌 Ишлэл хадгалах',
                          onPressed: () {
                            final text = _selectedText;
                            selectableRegionState.hideToolbar();
                            if (text != null && text.trim().isNotEmpty) {
                              widget.onShowHighlight(text.trim());
                            }
                          },
                        ),
                      ];
                      return AdaptiveTextSelectionToolbar.buttonItems(
                        anchors: selectableRegionState.contextMenuAnchors,
                        buttonItems: items,
                      );
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Builder(builder: (context) {
                        final pageParagraphs = pageText
                            .split('\n\n')
                            .where((p) => p.trim().isNotEmpty)
                            .toList();
                        final paragraphsToRender = pageParagraphs.isEmpty
                            ? [pageText]
                            : pageParagraphs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: paragraphsToRender.map((p) {
                            final matchingBm = bookProvider.bookmarks.where(
                              (b) =>
                                  b.bookId == widget.book.id &&
                                  p.contains(b.quote.substring(
                                      0,
                                      b.quote.length > 25
                                          ? 25
                                          : b.quote.length)),
                            ).firstOrNull;
                            final hasBm = matchingBm != null;
                            final highlightColor = matchingBm != null
                                ? Color(matchingBm.colorHex)
                                : Colors.amber;

                            return GestureDetector(
                              onLongPress: () => widget.onShowHighlight(p),
                              onDoubleTap: () => widget.onShowHighlight(p),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: hasBm
                                    ? const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6)
                                    : EdgeInsets.zero,
                                decoration: hasBm
                                    ? BoxDecoration(
                                        color: highlightColor
                                            .withValues(alpha: 0.16),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border(
                                          left: BorderSide(
                                            color: highlightColor,
                                            width: 3.5,
                                          ),
                                        ),
                                      )
                                    : null,
                                child: Text(
                                  p,
                                  style: ReaderThemeHelpers.getReaderTextStyle(
                                      widget.themeProvider,
                                      widget.readerTextColor),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  ),
                ),
                if (isLastPage &&
                    widget.chapters.isNotEmpty &&
                    widget.currentChapterIndex < widget.chapters.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                        onPressed: () =>
                            widget.onGoToChapter(widget.currentChapterIndex + 1),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(
                          widget.l10n?.t('reader.next_chapter') ??
                              'Дараагийн бүлэг рүү шилжих',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.l10n?.t('book.pages') ?? 'Хуудас'} ${pIndex + 1} / $pageCount',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.readerTextColor.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        '${((((widget.currentChapterIndex + (pIndex + 1) / pageCount) / (widget.chapters.isEmpty ? 1 : widget.chapters.length)).clamp(0.0, 1.0)) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: widget.readerTextColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }
}
