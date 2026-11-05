import 'package:flutter/material.dart';
import 'package:readpack/features/onboarding/presentation/widgets/onboarding_constants.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class OnboardingGenreStep extends StatelessWidget {
  final Set<int> selectedIndices;
  final ValueChanged<int> onToggle;
  final bool isEn;

  const OnboardingGenreStep({
    super.key,
    required this.selectedIndices,
    required this.onToggle,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final genres = OnboardingConstants.genres(isEn);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${l10n?.t('onboarding.step') ?? 'Алхам'} 2/3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.t('onboarding.step2_title') ?? 'Дуртай номын төрлүүдээ сонгоно уу',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.t('onboarding.step2_desc') ??
                'Нэг болон түүнээс дээш төрлийг сонгоорой.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: genres.asMap().entries.map((entry) {
              final index = entry.key;
              final genre = entry.value;
              final isSelected = selectedIndices.contains(index);
              return AnimatedPressable(
                onTap: () => onToggle(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        genre,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.t('onboarding.genres_recommendation_hint', {
                          'count': '${selectedIndices.length}',
                        }) ??
                        'Таны сонгосон ${selectedIndices.length} төрөлд тулгуурлан нүүр хуудасны зөвлөмж автоматаар баяжина.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
