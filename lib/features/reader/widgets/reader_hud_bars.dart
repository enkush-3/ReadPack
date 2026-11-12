import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ReaderTopHud extends StatelessWidget {
  final bool showControls;
  final Color readerBg;
  final Color readerTextColor;
  final Book book;
  final bool isAudioPlaying;
  final bool canReadCurrentChapter;
  final VoidCallback onBack;
  final VoidCallback onOpenToc;
  final VoidCallback onOpenAppearance;
  final VoidCallback onToggleAudio;
  final VoidCallback onAddBookmark;
  final VoidCallback? onOpenSearch;

  const ReaderTopHud({
    super.key,
    required this.showControls,
    required this.readerBg,
    required this.readerTextColor,
    required this.book,
    required this.isAudioPlaying,
    required this.canReadCurrentChapter,
    required this.onBack,
    required this.onOpenToc,
    required this.onOpenAppearance,
    required this.onToggleAudio,
    required this.onAddBookmark,
    this.onOpenSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      top: showControls ? 0 : -80,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: readerBg.withValues(alpha: 0.95),
          border: Border(
            bottom: BorderSide(color: readerTextColor.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedPressable(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: readerTextColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: readerTextColor,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  book.title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: readerTextColor,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                if (onOpenSearch != null)
                  AnimatedPressable(
                    onTap: onOpenSearch,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: readerTextColor,
                      ),
                    ),
                  ),
                AnimatedPressable(
                  onTap: onOpenToc,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 20,
                      color: readerTextColor,
                    ),
                  ),
                ),
                AnimatedPressable(
                  onTap: onOpenAppearance,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.text_format_rounded,
                      size: 22,
                      color: readerTextColor,
                    ),
                  ),
                ),
                if (canReadCurrentChapter)
                  AnimatedPressable(
                    onTap: onToggleAudio,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isAudioPlaying
                            ? Icons.headphones_rounded
                            : Icons.headphones_outlined,
                        size: 20,
                        color: isAudioPlaying
                            ? Theme.of(context).colorScheme.primary
                            : readerTextColor,
                      ),
                    ),
                  ),
                if (canReadCurrentChapter)
                  AnimatedPressable(
                    onTap: onAddBookmark,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.bookmark_add_rounded,
                        size: 20,
                        color: readerTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReaderBottomHud extends StatelessWidget {
  final bool showControls;
  final Color readerBg;
  final Color readerTextColor;
  final bool isPaginated;
  final double scrollProgress;
  final int currentChapterIndex;
  final int currentPageInChapter;
  final BookChapter currentChapter;
  final List<BookChapter> chapters;
  final AppLocalizations? l10n;

  const ReaderBottomHud({
    super.key,
    required this.showControls,
    required this.readerBg,
    required this.readerTextColor,
    required this.isPaginated,
    required this.scrollProgress,
    required this.currentChapterIndex,
    required this.currentPageInChapter,
    required this.currentChapter,
    required this.chapters,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgress = scrollProgress.clamp(0.0, 1.0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      bottom: showControls ? 0 : -80,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: readerBg.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(color: readerTextColor.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          children: [
            Text(
              '${(effectiveProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: readerTextColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: effectiveProgress,
                  backgroundColor: readerTextColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${l10n?.t('reader.chapter') ?? 'Бүлэг'} ${currentChapterIndex + 1} / ${chapters.isEmpty ? 1 : chapters.length}',
              style: TextStyle(
                fontSize: 12,
                color: readerTextColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
