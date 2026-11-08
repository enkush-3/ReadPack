import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ProfileHabitsCard extends StatelessWidget {
  const ProfileHabitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final profile = context.watch<BookProvider>().userProfile;
    final morningPct = profile.morningPercentage;
    final afternoonPct = profile.afternoonPercentage;
    final eveningPct =
        (profile.eveningPercentage + profile.nightPercentage).clamp(0.0, 1.0);
    final weeklyMins = profile.weeklyMinutes;
    final dayLabels = [
      l10n?.t('home.days.mon') ?? 'Да',
      l10n?.t('home.days.tue') ?? 'Мя',
      l10n?.t('home.days.wed') ?? 'Лх',
      l10n?.t('home.days.thu') ?? 'Пү',
      l10n?.t('home.days.fri') ?? 'Ба',
      l10n?.t('home.days.sat') ?? 'Бя',
      l10n?.t('home.days.sun') ?? 'Ня',
    ];

    return AnimatedPressable(
      onTap: () => Navigator.of(context).pushNamed(Routes.readingSchedule),
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.t('profile.time_of_day_insights') ??
                          'Уншлагын цагийн хуваарь',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n?.t('profile.peak_reading_time') ??
                  'Таны хамгийн бүтээмжтэй уншдаг цаг: Орой 20:00 - 22:30 🌙',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeBar(
              l10n?.t('profile.morning') ?? 'Өглөө (06:00 - 12:00)',
              morningPct,
              colorScheme,
              const Color(0xFF38BDF8),
            ),
            const SizedBox(height: 8),
            _buildTimeBar(
              l10n?.t('profile.afternoon') ?? 'Өдөр (12:00 - 18:00)',
              afternoonPct,
              colorScheme,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildTimeBar(
              l10n?.t('profile.night') ?? 'Орой (18:00 - 00:00)',
              eveningPct,
              colorScheme,
              Colors.indigoAccent,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (idx) {
                final m = idx < weeklyMins.length ? weeklyMins[idx] : 30;
                return Column(
                  children: [
                    Container(
                      width: 28,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(
                          alpha: (m / 60).clamp(0.18, 0.9),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$m',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayLabels[idx],
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBar(
    String label,
    double percent,
    ColorScheme colorScheme,
    Color barColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearPercentIndicator(
            lineHeight: 6,
            percent: percent,
            padding: EdgeInsets.zero,
            backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.25),
            progressColor: barColor,
          ),
        ),
      ],
    );
  }
}
