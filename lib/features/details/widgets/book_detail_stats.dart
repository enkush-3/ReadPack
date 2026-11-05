import 'package:flutter/material.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class BookDetailStats extends StatelessWidget {
  final Book book;
  final AppLocalizations? l10n;

  const BookDetailStats({
    super.key,
    required this.book,
    this.l10n,
  });

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.star_rounded,
            iconColor: Colors.amber,
            value: book.rating.toStringAsFixed(1),
            label:
                '${book.reviewsCount} ${l10n?.t('reviews.ratings_count') ?? 'үнэлгээ'}',
            colorScheme: colorScheme,
          ),
          Container(
            height: 30,
            width: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          _buildStatItem(
            icon: Icons.auto_stories_rounded,
            iconColor: colorScheme.primary,
            value: '${book.pages}',
            label: l10n?.t('book.pages') ?? 'Хуудас',
            colorScheme: colorScheme,
          ),
          if (book.hasAudio) ...[
            Container(
              height: 30,
              width: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            _buildStatItem(
              icon: Icons.access_time_rounded,
              iconColor: colorScheme.secondary,
              value:
                  '${book.audioDurationMinutes > 0 ? book.audioDurationMinutes : book.readTimeMinutes} ${l10n?.t('common.minutes_short') ?? 'м'}',
              label: l10n?.t('book.duration') ?? 'Хугацаа',
              colorScheme: colorScheme,
            ),
          ],
        ],
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

    final readButtonLabel = isStarted
        ? '${l10n?.t('book.continue_reading') ?? 'Үргэлжлүүлэх'} ($progressPct%)'
        : (l10n?.t('book.start_reading') ?? 'Уншиж эхлэх');

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AnimatedPressable(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.reader,
                arguments: {
                  'book': book,
                  'initialChapterIndex': book.currentChapterIndex,
                },
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
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
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    readButtonLabel,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (book.hasAudio) ...[
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
                      : colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
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
