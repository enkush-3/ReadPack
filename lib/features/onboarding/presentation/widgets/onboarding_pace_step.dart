import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class OnboardingPaceStep extends StatelessWidget {
  final int selectedDailyMinutes;
  final int selectedYearlyBooks;
  final ValueChanged<int> onDailyMinutesChanged;
  final ValueChanged<int> onYearlyBooksChanged;

  const OnboardingPaceStep({
    super.key,
    required this.selectedDailyMinutes,
    required this.selectedYearlyBooks,
    required this.onDailyMinutesChanged,
    required this.onYearlyBooksChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

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
              '${l10n?.t('onboarding.step') ?? 'Алхам'} 3/3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.t('onboarding.step3_title') ??
                'Өдөрт хэдэн минут унших зорилготой вэ?',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.t('onboarding.step3_desc') ??
                'Өдөр тутмын тогтмол уншлага нь мэдлэгийг батжуулна.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [15, 30, 45, 60].map((mins) {
              final isSelected = selectedDailyMinutes == mins;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedPressable(
                    onTap: () => onDailyMinutesChanged(mins),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$mins',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n?.t('onboarding.minutes_label') ?? 'минут',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                      .withValues(alpha: 0.8)
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            l10n?.t('onboarding.yearly_goal') ?? '2026 онд хэдэн ном унших вэ?',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [12, 24, 36, 52].map((books) {
              final isSelected = selectedYearlyBooks == books;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedPressable(
                    onTap: () => onYearlyBooksChanged(books),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.secondaryContainer
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.secondary
                              : colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$books',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n?.t('onboarding.books_per_year') ?? 'ном / жил',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
