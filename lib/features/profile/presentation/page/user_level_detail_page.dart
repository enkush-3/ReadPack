import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/helpers/book_gamification_manager.dart';
import 'package:readpack/helper/translation.dart';

class UserLevelDetailPage extends StatelessWidget {
  const UserLevelDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final profile = bookProvider.userProfile;
    final l10n = AppLocalizations.of(context);

    final currentLevel = profile.userLevel;
    final currentTitle = BookGamificationManager.computeLocalizedLevelTitle(
      profile.xp,
      (k) => l10n?.t(k),
    );
    final currentXp = profile.xp;
    final xpInLevel = profile.xpInCurrentLevel;
    final xpNeeded = profile.xpNeededForNextLevel;
    final levelProgress = profile.levelProgress;

    final tiers = [
      {'level': 1, 'title': 'Анхлан уншигч', 'xp': 0, 'perk': 'Үндсэн цахим номын сан ба хадгалах боломж'},
      {'level': 2, 'title': 'Сониуч уншигч', 'xp': 500, 'perk': 'Тэмдэглэгээний өнгө солих боломж нээгдэнэ'},
      {'level': 3, 'title': 'Номын хорхойтон', 'xp': 1200, 'perk': 'Долоо хоногийн лигт оролцож XP үржүүлэгч идэвхжинэ'},
      {'level': 4, 'title': 'Номын анд', 'xp': 2500, 'perk': 'Аудио номын өндөр хурдны горим нээгдэнэ'},
      {'level': 5, 'title': 'Мэргэн уншигч', 'xp': 5000, 'perk': 'Мэргэн уншигчийн тусгай алтан сүлд тэмдэг'},
      {'level': 6, 'title': 'Мастер уншигч', 'xp': 10000, 'perk': 'Шөнийн OLED Deep Black ба Sepia дэвшилтэт горимууд'},
      {'level': 7, 'title': 'Эрдэмт уншигч', 'xp': 20000, 'perk': 'Тэргүүлэгчдийн самбарын онцлох хүрээ'},
      {'level': 8, 'title': 'Гүн ухаантан', 'xp': 35000, 'perk': 'Хязгааргүй аудио хураангуй ба тусгай тайлан'},
      {'level': 9, 'title': 'Домогт уншигч', 'xp': 55000, 'perk': 'Домогт алтан титэм хүрээ бүхий профайл'},
      {'level': 10, 'title': 'Мөнхийн суут уншигч', 'xp': 80000, 'perk': 'ReadPack-ийн дээд хүндэт гишүүнчлэл'},
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.t('profile.level_title') ?? 'Түвшин & Цол',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Current Level Hero Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.8),
                    colorScheme.primary.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$currentLevel',
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Түвшин $currentLevel: $currentTitle',
                              style: TextStyle(
                                fontFamily: 'Serif',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Нийт $currentXp XP цуглуулсан',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Дараагийн түвшин рүү',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '$xpInLevel / $xpNeeded XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      minHeight: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. XP Earning Guide
            Text(
              'XP хэрхэн цуглуулах вэ?',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  _buildXpMethod('5 минут ном унших бүрд', '+5 XP', Icons.timer_outlined, colorScheme),
                  const Divider(height: 16),
                  _buildXpMethod('Бүлэг дуусгахад', '+20 XP', Icons.bookmark_added_outlined, colorScheme),
                  const Divider(height: 16),
                  _buildXpMethod('Бүтэн ном уншиж дуусгахад', '+50 XP', Icons.auto_stories_outlined, colorScheme),
                  const Divider(height: 16),
                  _buildXpMethod('Өдрийн зорилго биелүүлэхэд', '+25 XP', Icons.check_circle_outline, colorScheme),
                  const Divider(height: 16),
                  _buildXpMethod('7 өдөр дараалан уншихад (Streak)', '+50 XP', Icons.local_fire_department_outlined, colorScheme),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. All 10 Tiers Roadmap
            Text(
              'Бүх цол, түвшний шатлал',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...tiers.map((t) {
              final lvl = t['level'] as int;
              final tTitle = t['title'] as String;
              final xpReq = t['xp'] as int;
              final perk = t['perk'] as String;
              final isCurrent = lvl == currentLevel;
              final isAchieved = lvl <= currentLevel;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? colorScheme.primary.withValues(alpha: 0.08)
                      : (isAchieved
                          ? colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.25)
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isCurrent
                        ? colorScheme.primary
                        : (isAchieved
                            ? colorScheme.primary.withValues(alpha: 0.2)
                            : colorScheme.outlineVariant.withValues(alpha: 0.2)),
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isAchieved
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$lvl',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isAchieved
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tTitle,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ОДООГИЙН',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '$xpReq XP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            perk,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.65),
                              height: 1.35,
                            ),
                          ),
                        ],
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

  Widget _buildXpMethod(String title, String reward, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            reward,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

