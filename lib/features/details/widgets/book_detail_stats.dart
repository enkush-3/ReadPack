import 'package:flutter/material.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class BookDetailStats extends StatelessWidget {
  final Book book;
  final AppLocalizations? l10n;

  const BookDetailStats({super.key, required this.book, this.l10n});

  String get _ratingValue =>
      book.rating > 0 ? book.rating.toStringAsFixed(1) : '—';

  String get _ratingLabel => book.reviewsCount > 0
      ? '${book.reviewsCount} ${l10n?.t('reviews.ratings_count') ?? 'үнэлгээ'}'
      : (l10n?.t('reviews.ratings_count') ?? 'Үнэлгээ');

  String get _pageCount => book.pages > 0 ? '${book.pages}' : '—';

  String get _durationValue {
    final minutes = book.audioDurationMinutes > 0
        ? book.audioDurationMinutes
        : book.readTimeMinutes;
    return minutes > 0
        ? '$minutes ${l10n?.t('common.minutes_short') ?? 'м'}'
        : '—';
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required ColorScheme colorScheme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final stats = <Widget>[
      _buildStatItem(
        icon: Icons.star_rounded,
        iconColor: Colors.amber,
        value: _ratingValue,
        label: _ratingLabel,
        colorScheme: colorScheme,
      ),
      _buildStatItem(
        icon: Icons.auto_stories_rounded,
        iconColor: colorScheme.primary,
        value: _pageCount,
        label: l10n?.t('book.pages') ?? 'Хуудас',
        colorScheme: colorScheme,
      ),
      if (book.hasAudio)
        _buildStatItem(
          icon: Icons.access_time_rounded,
          iconColor: colorScheme.secondary,
          value: _durationValue,
          label: l10n?.t('book.duration') ?? 'Хугацаа',
          colorScheme: colorScheme,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 12) / 2;
          return Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 12,
            runSpacing: 12,
            children: stats
                .map((stat) => SizedBox(width: itemWidth, child: stat))
                .toList(),
          );
        },
      ),
    );
  }
}

class BookDetailActionButtons extends StatelessWidget {
  final Book book;
  final bool showAudioPlayer;
  final VoidCallback onToggleAudio;
  final AppLocalizations? l10n;

  const BookDetailActionButtons({
    super.key,
    required this.book,
    required this.showAudioPlayer,
    required this.onToggleAudio,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isStarted = book.progress > 0;
    final progressPct = (book.progress * 100).toInt();
    final hasReadableContent = book.chapters.any(
      (chapter) => chapter.content.trim().isNotEmpty,
    );
    final selectedChapterIndex = book.chapters.isEmpty
        ? 0
        : book.currentChapterIndex.clamp(0, book.chapters.length - 1);
    final selectedChapterIsReadable = book.chapters.isNotEmpty &&
        book.chapters[selectedChapterIndex].content.trim().isNotEmpty;
    final initialChapterIndex = selectedChapterIsReadable
        ? selectedChapterIndex
        : book.chapters.indexWhere(
            (chapter) => chapter.content.trim().isNotEmpty,
          );

    final readButtonLabel = !hasReadableContent
        ? (l10n?.t('reader.no_chapters') ?? 'Унших агуулга алга')
        : isStarted
        ? '${l10n?.t('book.continue_reading') ?? 'Үргэлжлүүлэх'} ($progressPct%)'
        : (l10n?.t('book.start_reading') ?? 'Уншиж эхлэх');

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AnimatedPressable(
            onTap: hasReadableContent
                ? () {
                    Navigator.of(context).pushNamed(
                      Routes.reader,
                      arguments: {
                        'book': book,
                        'initialChapterIndex': initialChapterIndex,
                      },
                    );
                  }
                : null,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: hasReadableContent
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: hasReadableContent
                        ? colorScheme.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                    blurRadius: hasReadableContent ? 12 : 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isStarted
                        ? Icons.play_arrow_rounded
                        : Icons.auto_stories_rounded,
                    color: hasReadableContent
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      readButtonLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: hasReadableContent
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (book.hasAudio && hasReadableContent) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: AnimatedPressable(
              onTap: onToggleAudio,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: showAudioPlayer
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.35,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: showAudioPlayer
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.headphones_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
