import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readpack/helper/translation.dart';

class ProfileHabitsCard extends StatelessWidget {
  const ProfileHabitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
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
            0.35,
            colorScheme,
            Colors.amber,
          ),
          const SizedBox(height: 8),
          _buildTimeBar(
            l10n?.t('profile.afternoon') ?? 'Өдөр (12:00 - 18:00)',
            0.25,
            colorScheme,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildTimeBar(
            l10n?.t('profile.night') ?? 'Орой (18:00 - 00:00)',
            0.40,
            colorScheme,
            Colors.indigoAccent,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              {'day': l10n?.t('home.days.mon') ?? 'Да', 'm': 30},
              {'day': l10n?.t('home.days.tue') ?? 'Мя', 'm': 25},
              {'day': l10n?.t('home.days.wed') ?? 'Лх', 'm': 40},
              {'day': l10n?.t('home.days.thu') ?? 'Пү', 'm': 20},
              {'day': l10n?.t('home.days.fri') ?? 'Ба', 'm': 35},
              {'day': l10n?.t('home.days.sat') ?? 'Бя', 'm': 45},
              {'day': l10n?.t('home.days.sun') ?? 'Ня', 'm': 30},
            ].map((d) {
              return Column(
                children: [
                  Container(
                    width: 28,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(
                        alpha: ((d['m'] as int) / 50).clamp(0.15, 0.9),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${d['m']}',
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
                    d['day'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
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
