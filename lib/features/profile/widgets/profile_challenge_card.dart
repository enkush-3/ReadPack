import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';

class ProfileChallengeCard extends StatelessWidget {
  final BookProvider bookProvider;

  const ProfileChallengeCard({
    super.key,
    required this.bookProvider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final profile = bookProvider.userProfile;
    final goalProgress =
        (profile.minutesReadToday / profile.dailyGoalMinutes).clamp(0.0, 1.0);

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
                      '${profile.minutesReadToday} / ${profile.dailyGoalMinutes} ${l10n?.t('profile.minutes_today') ?? 'минут өнөөдөр'}',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.dailyGoalMinutes} ${l10n?.t('profile.daily_goal_sub') ?? 'минутын зорилго'}',
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
            Text(
              l10n?.t('profile.reading_challenge') ??
                  '2026 оны уншлагын челленж',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '2026',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profile.totalBooksRead} / 25 ${l10n?.t('home.books_count') ?? 'ном'}',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (l10n?.t('profile.reading_challenge_sub') ??
                                  '{current} of {goal} books read ({percent}%)')
                              .replaceAll(
                                  '{current}', '${profile.totalBooksRead}')
                              .replaceAll('{goal}', '25')
                              .replaceAll('{percent}',
                                  '${((profile.totalBooksRead / 25).clamp(0.0, 1.0) * 100).toInt()}'),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.65),
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
                  percent: (profile.totalBooksRead / 25).clamp(0.0, 1.0),
                  padding: EdgeInsets.zero,
                  backgroundColor:
                      colorScheme.outlineVariant.withValues(alpha: 0.3),
                  progressColor: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
