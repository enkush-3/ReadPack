import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ProfileChallengeCard extends StatelessWidget {
  final BookProvider bookProvider;

  const ProfileChallengeCard({
    super.key,
    required this.bookProvider,
  });

  void _showEditChallengeDialog(
      BuildContext context, BookProvider provider, int currentGoal) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFF52B788) : const Color(0xFF3B6E5C);
    final l10n = AppLocalizations.of(context);
    int selectedGoal = currentGoal;
    final textController = TextEditingController(text: '$currentGoal');
    final booksWord = l10n?.t('home.books_count') ?? 'ном';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n?.t('profile.challenge_dialog_title') ??
                          '2026 оны зорилго',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.t('profile.challenge_dialog_desc') ??
                        '2026 онд хэдэн ном уншиж дуусгах зорилготой вэ?',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [12, 20, 24, 30, 40, 50].map((g) {
                      final isSel = selectedGoal == g;
                      return AnimatedPressable(
                        onTap: () {
                          setState(() {
                            selectedGoal = g;
                            textController.text = '$g';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? (isDark
                                    ? accentColor
                                    : accentColor.withValues(alpha: 0.16))
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel
                                  ? accentColor
                                  : colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '$g $booksWord',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSel
                                  ? (isDark ? Colors.white : accentColor)
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n?.t('profile.custom_number') ??
                          'Өөр тоо оруулах',
                      suffixText: booksWord,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        setState(() => selectedGoal = parsed);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(
                    l10n?.t('common.cancel') ?? 'Болих',
                    style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    provider.updateYearlyGoalBooks(selectedGoal);
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.t('profile.challenge_updated_toast',
                                  {'goal': '$selectedGoal'}) ??
                              '2026 оны зорилго $selectedGoal ном болж шинэчлэгдлээ! 🎯',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(l10n?.t('common.save') ?? 'Хадгалах'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final challengeAccent =
        isDark ? const Color(0xFF52B788) : const Color(0xFF3B6E5C);
    final l10n = AppLocalizations.of(context);
    final profile = bookProvider.userProfile;
    final dailyGoal =
        profile.dailyGoalMinutes > 0 ? profile.dailyGoalMinutes : 30;
    final goalProgress = (profile.minutesReadToday / dailyGoal).clamp(0.0, 1.0);
    final yearlyGoal =
        profile.yearlyGoalBooks > 0 ? profile.yearlyGoalBooks : 24;
    final yearlyProgress =
        (profile.totalBooksRead / yearlyGoal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Reading Goal Section
        Text(
          l10n?.t('profile.daily_goal') ?? 'Өдрийн зорилго',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 36,
                lineWidth: 7,
                percent: goalProgress,
                progressColor: colorScheme.primary,
                backgroundColor:
                    colorScheme.outlineVariant.withValues(alpha: 0.3),
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '${(goalProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.minutesReadToday} / $dailyGoal ${l10n?.t('profile.minutes_today') ?? 'минут өнөөдөр'}',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dailyGoal ${l10n?.t('profile.daily_goal_sub') ?? 'минутын зорилго'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2026 Reading Challenge Section
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n?.t('profile.reading_challenge') ??
                    '2026 оны уншлагын челленж',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            AnimatedPressable(
              onTap: () =>
                  _showEditChallengeDialog(context, bookProvider, yearlyGoal),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: challengeAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: challengeAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '2026',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: challengeAccent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_outlined,
                      size: 13,
                      color: challengeAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedPressable(
          onTap: () =>
              _showEditChallengeDialog(context, bookProvider, yearlyGoal),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: challengeAccent.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: challengeAccent,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${profile.totalBooksRead} / $yearlyGoal ${l10n?.t('home.books_count') ?? 'ном'}',
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (l10n?.t('profile.reading_challenge_sub') ??
                                    '{current} of {goal} books read ({percent}%)')
                                .replaceAll(
                                    '{current}', '${profile.totalBooksRead}')
                                .replaceAll('{goal}', '$yearlyGoal')
                                .replaceAll('{percent}',
                                    '${(yearlyProgress * 100).toInt()}'),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.65),
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
                    percent: yearlyProgress,
                    padding: EdgeInsets.zero,
                    backgroundColor:
                        colorScheme.outlineVariant.withValues(alpha: 0.3),
                    progressColor: challengeAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
