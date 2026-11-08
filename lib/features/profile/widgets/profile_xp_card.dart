import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/helpers/book_gamification_manager.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ProfileXpCard extends StatelessWidget {
  final BookProvider bookProvider;

  const ProfileXpCard({
    super.key,
    required this.bookProvider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final xp = bookProvider.userProfile.xp;
    final levelTitle = BookGamificationManager.computeLocalizedLevelTitle(
      xp,
      (k) => l10n?.t(k),
    );

    int currentLevelBase = 0;
    int nextLevelTarget = 500;
    if (xp >= 500 && xp < 1500) {
      currentLevelBase = 500;
      nextLevelTarget = 1500;
    } else if (xp >= 1500 && xp < 3000) {
      currentLevelBase = 1500;
      nextLevelTarget = 3000;
    } else if (xp >= 3000 && xp < 5000) {
      currentLevelBase = 3000;
      nextLevelTarget = 5000;
    } else if (xp >= 5000) {
      currentLevelBase = 5000;
      nextLevelTarget = 10000;
    }

    final double levelProgress =
        ((xp - currentLevelBase) / (nextLevelTarget - currentLevelBase))
            .clamp(0.0, 1.0);

    return AnimatedPressable(
      onTap: () => Navigator.of(context).pushNamed(Routes.userLevelDetail),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.5),
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '🛡️',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        levelTitle,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        l10n?.t('profile.level_title') ?? 'Түвшин ба Цол',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '$xp XP',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearPercentIndicator(
              lineHeight: 8,
              percent: levelProgress,
              padding: EdgeInsets.zero,
              backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
              progressColor: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$xp XP / $nextLevelTarget XP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                (l10n?.t('profile.xp_needed_next') ??
                        'Дараагийн цолд {xp} XP дутуу')
                    .replaceAll(
                  '{xp}',
                  '${(nextLevelTarget - xp).clamp(0, 10000)}',
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
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

