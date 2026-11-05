import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/home/widgets/streak_modal_sheet.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ProfileAchievementsCard extends StatelessWidget {
  final BookProvider bookProvider;

  const ProfileAchievementsCard({
    super.key,
    required this.bookProvider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final profile = bookProvider.userProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistics Section
        Text(
          l10n?.t('profile.stats_title') ?? 'Статистик үзүүлэлт',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              title: l10n?.t('profile.books_read') ?? 'Уншсан ном',
              value: '${profile.totalBooksRead}',
              icon: Icons.auto_stories_rounded,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: l10n?.t('profile.total_hours') ?? 'Нийт цаг',
              value:
                  '${profile.totalHoursRead}${l10n?.t('common.hours_short') ?? 'ц'}',
              icon: Icons.access_time_rounded,
              colorScheme: colorScheme,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              title: l10n?.t('profile.streak_days') ?? 'Цуврал өдөр',
              value: '${profile.streakDays}',
              icon: Icons.local_fire_department_rounded,
              colorScheme: colorScheme,
              onTap: () =>
                  showStreakModalSheet(context, profile, colorScheme, l10n),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: l10n?.t('profile.reading_speed') ?? 'Унших хурд',
              value:
                  '${profile.readingSpeedWpm} ${l10n?.t('profile.wpm') ?? 'үг/мин'}',
              icon: Icons.speed_rounded,
              colorScheme: colorScheme,
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Achievements List
        Text(
          l10n?.t('profile.achievements') ?? 'Уншлагын амжилтууд',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...profile.achievements.map((ach) {
          final achTitle =
              l10n?.t('profile.achievements_list.${ach.id}_title') ??
                  ach.title;
          final achDesc =
              l10n?.t('profile.achievements_list.${ach.id}_desc') ??
                  ach.description;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ach.isUnlocked
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ach.isUnlocked
                    ? colorScheme.primary.withValues(alpha: 0.25)
                    : colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ach.isUnlocked
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      ach.icon,
                      style: TextStyle(
                        fontSize: 22,
                        color: ach.isUnlocked ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ach.isUnlocked
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (ach.isUnlocked)
                  Icon(
                    Icons.check_circle_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  )
                else
                  Icon(
                    Icons.lock_outline_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 18,
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
  }) {
    final cardContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: onTap != null
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: colorScheme.primary, size: 22),
              if (onTap != null)
                Icon(
                  Icons.touch_app_rounded,
                  size: 14,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Expanded(
        child: AnimatedPressable(
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    return Expanded(child: cardContent);
  }
}
