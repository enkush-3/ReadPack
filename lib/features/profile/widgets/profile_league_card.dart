import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';

class ProfileLeagueCard extends StatelessWidget {
  final BookProvider bookProvider;

  const ProfileLeagueCard({
    super.key,
    required this.bookProvider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final profile = bookProvider.userProfile;
    final leagueName = profile.weeklyLeague.isNotEmpty
        ? profile.weeklyLeague
        : (l10n?.t('profile.diamond_league') ?? 'Алмазан Лиг');

    final competitors = [
      {'rank': '1', 'name': 'Төмөрөө', 'xp': 1820, 'badge': '🥇', 'isUser': false},
      {'rank': '2', 'name': 'Ану-Үжин', 'xp': 1610, 'badge': '🥈', 'isUser': false},
      {
        'rank': '3',
        'name': profile.isGuest
            ? (l10n?.t('profile.guest_user') ?? profile.name)
            : profile.name,
        'xp': profile.xp,
        'badge': '🥉',
        'isUser': true,
      },
      {'rank': '4', 'name': 'Бат-Эрдэнэ', 'xp': 1290, 'badge': '4', 'isUser': false},
      {'rank': '5', 'name': 'Хулан', 'xp': 1150, 'badge': '5', 'isUser': false},
    ];

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
                Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '$leagueName • ${l10n?.t('profile.leaderboard') ?? 'Лидерборд'}',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
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
                        l10n?.t('profile.days_remaining') ?? '2 өдөр үлдсэн',
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
            ...competitors.map((c) {
              final isUser = c['isUser'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        c['badge'] as String,
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
                        '${c['name']}${isUser ? ' (${l10n?.t('profile.you') ?? 'Та'})' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isUser ? FontWeight.bold : FontWeight.w500,
                          color: isUser
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${c['xp']} XP',
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
            const SizedBox(height: 8),
            Center(
              child: Text(
                l10n?.t('profile.diamond_promotion') ??
                    '💎 Эхний 3 байр Алмазан Лиг рүү дэвшинэ',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
