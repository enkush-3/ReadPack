import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final userProfile = bookProvider.userProfile;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final competitors = [
      {'rank': 1, 'name': 'Номин-Эрдэнэ', 'xp': 4820, 'badge': '🥇', 'isUser': false},
      {'rank': 2, 'name': 'Тэмүүлэн Б.', 'xp': 4150, 'badge': '🥈', 'isUser': false},
      {'rank': 3, 'name': 'Билгүүн Т.', 'xp': 3890, 'badge': '🥉', 'isUser': false},
      {
        'rank': 4,
        'name': userProfile.name,
        'xp': userProfile.xp,
        'badge': '4',
        'isUser': true,
      },
      {'rank': 5, 'name': 'Анударь С.', 'xp': 3120, 'badge': '5', 'isUser': false},
      {'rank': 6, 'name': 'Энхжин М.', 'xp': 2890, 'badge': '6', 'isUser': false},
      {'rank': 7, 'name': 'Бат-Эрдэнэ О.', 'xp': 2450, 'badge': '7', 'isUser': false},
      {'rank': 8, 'name': 'Сарнай Х.', 'xp': 2100, 'badge': '8', 'isUser': false},
    ];

    // Sort by XP descending and re-assign ranks
    competitors.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
    for (int i = 0; i < competitors.length; i++) {
      competitors[i]['rank'] = i + 1;
      if (i == 0) {
        competitors[i]['badge'] = '🥇';
      } else if (i == 1) {
        competitors[i]['badge'] = '🥈';
      } else if (i == 2) {
        competitors[i]['badge'] = '🥉';
      } else {
        competitors[i]['badge'] = '${i + 1}';
      }
    }

    final leagueName = l10n?.t('profile.diamond_league') ?? 'Алмазан Лиг';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.t('profile.leaderboard') ?? 'Лидерборд',
          style: const TextStyle(
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // League Header Banner
          _buildLeagueHeader(
            leagueName: leagueName,
            colorScheme: colorScheme,
            l10n: l10n,
          ),
          const SizedBox(height: 16),

          // Podium preview for top 3
          if (competitors.length >= 3)
            _buildPodium(
              topThree: competitors.take(3).toList(),
              colorScheme: colorScheme,
            ),
          const SizedBox(height: 16),

          // Competitors list
          Text(
            l10n?.t('leaderboard.weekly_rankings') ?? '7 хоногийн чансаа',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          ...competitors.map((c) => _buildCompetitorTile(
                competitor: c,
                colorScheme: colorScheme,
                l10n: l10n,
              )),
          const SizedBox(height: 16),

          Center(
            child: Text(
              l10n?.t('profile.diamond_promotion') ??
                  '💎 Эхний 3 байр Алмазан Лиг рүү дэвшинэ',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLeagueHeader({
    required String leagueName,
    required ColorScheme colorScheme,
    required AppLocalizations? l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.4),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leagueName,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.t('leaderboard.weekly_reset_info') ??
                      'Долоо хоног бүрийн Ням гарагт 23:59 цагт шинэчлэгдэнэ',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
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
        ],
      ),
    );
  }

  Widget _buildPodium({
    required List<Map<String, dynamic>> topThree,
    required ColorScheme colorScheme,
  }) {
    // 2nd, 1st, 3rd display
    final first = topThree[0];
    final second = topThree[1];
    final third = topThree[2];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumColumn(second, 90, Colors.grey.shade400, colorScheme),
          _buildPodiumColumn(first, 120, Colors.amber.shade500, colorScheme),
          _buildPodiumColumn(third, 75, Colors.brown.shade300, colorScheme),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn(
    Map<String, dynamic> item,
    double height,
    Color medalColor,
    ColorScheme colorScheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item['badge'] as String,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            item['name'] as String,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          '${item['xp']} XP',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: medalColor.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(
              '#${item['rank']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: medalColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitorTile({
    required Map<String, dynamic> competitor,
    required ColorScheme colorScheme,
    required AppLocalizations? l10n,
  }) {
    final isUser = competitor['isUser'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUser
              ? colorScheme.primary.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              competitor['badge'] as String,
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
              '${competitor['name']}${isUser ? ' (${l10n?.t('profile.you') ?? 'Та'})' : ''}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isUser ? FontWeight.bold : FontWeight.w500,
                color: isUser ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            '${competitor['xp']} XP',
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
  }
}
