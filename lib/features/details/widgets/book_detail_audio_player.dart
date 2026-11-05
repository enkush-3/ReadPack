import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';

class BookDetailAudioPlayer extends StatelessWidget {
  final Book currentBook;
  final bool isPlaying;
  final double currentSeconds;
  final double totalSeconds;
  final double speed;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onSeek;
  final VoidCallback onChangeSpeed;
  final VoidCallback onClose;
  final AppLocalizations? l10n;

  const BookDetailAudioPlayer({
    super.key,
    required this.currentBook,
    required this.isPlaying,
    required this.currentSeconds,
    required this.totalSeconds,
    required this.speed,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onChangeSpeed,
    required this.onClose,
    this.l10n,
  });

  String _formatTime(double totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs.toInt() % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chapterTitle = currentBook.chapters.isNotEmpty
        ? currentBook.chapters.first.title
        : currentBook.title;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.7),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.t('book.audio_narration') ?? 'Аудио хүүрнэл',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      chapterTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 40,
                  color: colorScheme.primary,
                ),
                onPressed: onTogglePlay,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: currentSeconds.clamp(0.0, totalSeconds),
                    max: totalSeconds > 0 ? totalSeconds : 1.0,
                    activeColor: colorScheme.primary,
                    inactiveColor:
                        colorScheme.outlineVariant.withValues(alpha: 0.4),
                    onChanged: onSeek,
                  ),
                ),
              ),
              Text(
                '${_formatTime(currentSeconds)} / ${_formatTime(totalSeconds)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onChangeSpeed,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${speed}x',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
