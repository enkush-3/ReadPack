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
    final finishedBooksCount = bookProvider.books
        .where((b) =>
            b.progress >= 1.0 ||
            (b.pages > 0 && b.currentPage >= b.pages))
        .length;

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
              value: '$finishedBooksCount',
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
        const SizedBox(height: 24),
        // Badges & Milestones Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.t('badges.title') ?? 'Цол ба Тэмдгүүд',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'XP: ${profile.xp}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 118,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildBadgeItem(
                context,
                title: '7 хоногийн мастер',
                desc: '7 өдөр тасралтгүй уншсан',
                icon: '🔥',
                isUnlocked: profile.streakDays >= 7,
                progress: '${profile.streakDays}/7 өдөр',
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 10),
              _buildBadgeItem(
                context,
                title: 'Өглөөний шувуу',
                desc: '5+ цагийн идэвхтэй уншлага',
                icon: '🌅',
                isUnlocked: profile.totalHoursRead >= 5,
                progress: '${profile.totalHoursRead}/5ц',
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 10),
              _buildBadgeItem(
                context,
                title: 'Бизнесийн шинжээч',
                desc: '1+ ном бүрэн уншиж дуусгасан',
                icon: '💼',
                isUnlocked: finishedBooksCount >= 1,
                progress: '$finishedBooksCount/1 ном',
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 10),
              _buildBadgeItem(
                context,
                title: 'Номын мастер',
                desc: '3-р түвшинд хүрсэн',
                icon: '👑',
                isUnlocked: profile.userLevel >= 3,
                progress: 'Lvl ${profile.userLevel}/3',
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(
    BuildContext context, {
    required String title,
    required String desc,
    required String icon,
    required bool isUnlocked,
    required String progress,
    required ColorScheme colorScheme,
  }) {
    return AnimatedPressable(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                  desc,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Colors.green.withValues(alpha: 0.12)
                        : colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUnlocked
                            ? Icons.check_circle_rounded
                            : Icons.lock_outline_rounded,
                        size: 16,
                        color: isUnlocked ? Colors.green : colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isUnlocked ? 'Амжилттай нээгдсэн ✓' : 'Явц: $progress',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              isUnlocked ? Colors.green : colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Ойлголоо'),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? colorScheme.primary.withValues(alpha: 0.4)
                : colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(icon, style: const TextStyle(fontSize: 22)),
                Icon(
                  isUnlocked
                      ? Icons.check_circle_rounded
                      : Icons.lock_clock_rounded,
                  size: 14,
                  color: isUnlocked
                      ? Colors.green
                      : colorScheme.outline.withValues(alpha: 0.6),
                ),
              ],
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              isUnlocked ? 'Нээгдсэн ✓' : progress,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? Colors.green : colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
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
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: colorScheme.primary.withValues(alpha: 0.7),
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
