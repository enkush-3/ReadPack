import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class ProfileLeagueCard extends StatelessWidget {
  final BookProvider bookProvider;

  const ProfileLeagueCard({super.key, required this.bookProvider});

  int _daysRemainingInMonth() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final remaining = lastDayOfMonth - now.day;
    return remaining > 0 ? remaining : 1;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final profile = bookProvider.userProfile;
    final leaderboardTitle =
        l10n?.t('leaderboard.monthly_title') ?? 'Сарын Лидерборд';
    final daysLeft = _daysRemainingInMonth();
    final daysRemainingLabel =
        (l10n?.t('gamification.days_remaining_month') ??
                '$daysLeft өдөр үлдсэн')
            .replaceAll('{days}', '$daysLeft');

    final competitors = bookProvider.leaderboardEntries.take(5).toList();

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).pushNamed(Routes.leaderboard);
      },
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
                Flexible(
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          leaderboardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        daysRemainingLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (bookProvider.isLeaderboardLoading && competitors.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    SkeletonLoader(width: double.infinity, height: 18),
                    SizedBox(height: 10),
                    SkeletonLoader(width: double.infinity, height: 18),
                    SizedBox(height: 10),
                    SkeletonLoader(width: double.infinity, height: 18),
                  ],
                ),
              )
            else if (bookProvider.leaderboardError != null &&
                competitors.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n?.t('leaderboard.load_error') ??
                            'Лидерборд ачаалж чадсангүй.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          bookProvider.refreshLeaderboard(period: 'monthly'),
                      child: Text(l10n?.t('common.retry') ?? 'Дахин оролдох'),
                    ),
                  ],
                ),
              )
            else if (competitors.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n?.t('leaderboard.empty_title') ??
                      'Одоогоор байр эзэлсэн уншигч алга',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ...competitors.map((c) {
              final isUser = c.isUser;
              final displayName = isUser && profile.isGuest
                  ? (l10n?.t('profile.guest_user') ?? c.name)
                  : c.name;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isUser
                      ? Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        c.badge,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isUser
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$displayName${isUser ? ' (${l10n?.t('profile.you') ?? 'Та'})' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isUser
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isUser
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${c.xp} XP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isUser
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
