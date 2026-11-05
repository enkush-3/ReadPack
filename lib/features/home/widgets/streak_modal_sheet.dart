import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/user_stats.dart';

void showStreakModalSheet(
  BuildContext context,
  UserProfile profile,
  ColorScheme colorScheme,
  AppLocalizations? l10n,
) {
  final goalPct =
      (profile.minutesReadToday / profile.dailyGoalMinutes).clamp(0.0, 1.0);
  final remainingMins = profile.dailyGoalMinutes - profile.minutesReadToday;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🔥', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${profile.streakDays} ${l10n?.t('home.streak_sheet_title') ?? 'хоногийн уншлагын цуврал!'}',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00B0FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00B0FF).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('❄️', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    l10n?.t('home.streak_freeze') ?? 'Цуврал хамгаалагдсан',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0288D1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n?.t('profile.daily_goal') ?? 'Өдрийн зорилго',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${profile.minutesReadToday} / ${profile.dailyGoalMinutes} мин',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearPercentIndicator(
                    lineHeight: 8.0,
                    percent: goalPct,
                    backgroundColor: colorScheme.surface,
                    progressColor: const Color(0xFFFF9800),
                    barRadius: const Radius.circular(4),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    remainingMins <= 0
                        ? (l10n?.t('home.streak_goal_done') ?? 'Өнөөдрийн зорилго биелсэн! 🔥')
                        : (l10n?.t('home.streak_goal_remaining', {'minutes': '$remainingMins'}) ??
                            'Өнөөдөр дахин $remainingMins минут уншаад зорилгоо биелүүлээрэй.'),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n?.t('home.streak_weekly') ?? '7 хоногийн амжилт',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayItem('Да', true, colorScheme),
                _buildDayItem('Мя', true, colorScheme),
                _buildDayItem('Лх', true, colorScheme),
                _buildDayItem('Пү', true, colorScheme),
                _buildDayItem('Ба', true, colorScheme),
                _buildDayItem('Бя', false, colorScheme),
                _buildDayItem('Ня', false, colorScheme),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDayItem(String day, bool isDone, ColorScheme colorScheme) {
  return Column(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDone
              ? const Color(0xFFFF9800).withValues(alpha: 0.15)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: isDone
              ? Border.all(color: const Color(0xFFFF9800), width: 1.5)
              : null,
        ),
        child: Center(
          child: isDone
              ? const Text('🔥', style: TextStyle(fontSize: 15))
              : Text(
                  '•',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        day,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
          color: isDone
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    ],
  );
}
