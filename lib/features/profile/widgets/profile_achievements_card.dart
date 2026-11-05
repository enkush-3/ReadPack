import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/profile/widgets/read_books_sheet.dart';
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
              onTap: () => ReadBooksSheet.show(context, bookProvider),
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
              onTap: () => Navigator.of(context).pushNamed(Routes.streakDetail),
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
