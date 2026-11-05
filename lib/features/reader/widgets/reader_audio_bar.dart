import 'package:flutter/material.dart';
import 'package:readpack/features/reader/widgets/reader_theme_helpers.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ReaderAudioBar extends StatelessWidget {
  final BookChapter currentChapter;
  final bool isAudioPlaying;
  final double audioCurrentSeconds;
  final double audioTotalSeconds;
  final double audioSpeed;
  final bool showControls;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onSkip;
  final VoidCallback onChangeSpeed;
  final VoidCallback onClose;
  final AppLocalizations? l10n;

  const ReaderAudioBar({
    super.key,
    required this.currentChapter,
    required this.isAudioPlaying,
    required this.audioCurrentSeconds,
    required this.audioTotalSeconds,
    required this.audioSpeed,
    required this.showControls,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onSkip,
    required this.onChangeSpeed,
    required this.onClose,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: showControls ? 74 : 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Waveform Animation / Sound Indicator
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAudioPlaying
                        ? Icons.volume_up_rounded
                        : Icons.volume_mute_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${l10n?.t('reader.audio_mode') ?? 'Сонсох горим'}: ${currentChapter.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ReaderThemeHelpers.formatTime(audioCurrentSeconds)} / ${ReaderThemeHelpers.formatTime(audioTotalSeconds)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Speed selector
                AnimatedPressable(
                  onTap: onChangeSpeed,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${audioSpeed}x',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedPressable(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Scrubber Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: audioCurrentSeconds.clamp(0.0, audioTotalSeconds),
                max: audioTotalSeconds > 0 ? audioTotalSeconds : 1.0,
                onChanged: onSeek,
              ),
            ),
            // Audio Controls: Skip -10s, Play/Pause, Skip +10s
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () => onSkip(-10),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onTogglePlay,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAudioPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.forward_10_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () => onSkip(10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
