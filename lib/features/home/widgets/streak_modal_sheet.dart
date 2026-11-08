import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/user_stats.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

void showStreakModalSheet(
  BuildContext context,
  UserProfile profile,
  ColorScheme colorScheme,
  AppLocalizations? l10n,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return _StreakModalContent(
        initialProfile: profile,
        colorScheme: colorScheme,
        l10n: l10n,
      );
    },
  );
}

class _StreakModalContent extends StatefulWidget {
  final UserProfile initialProfile;
  final ColorScheme colorScheme;
  final AppLocalizations? l10n;

  const _StreakModalContent({
    required this.initialProfile,
    required this.colorScheme,
    required this.l10n,
  });

  @override
  State<_StreakModalContent> createState() => _StreakModalContentState();
}

class _StreakModalContentState extends State<_StreakModalContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  late int _displayedStreak;
  bool _celebratedToday = false;

  @override
  void initState() {
    super.initState();
    _displayedStreak = widget.initialProfile.streakDays;
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Play entrance bounce
    _celebrationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _navigateToContinueReading(BookProvider bookProvider) {
    Navigator.of(context).pop();
    final targetBook = bookProvider.continueReadingBooks.isNotEmpty
        ? bookProvider.continueReadingBooks.first
        : (bookProvider.books.isNotEmpty ? bookProvider.books.first : null);
    if (targetBook != null) {
      Navigator.of(context).pushNamed(
        Routes.reader,
        arguments: {
          'book': targetBook,
          'initialChapterIndex': targetBook.currentChapterIndex,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final profile = bookProvider.userProfile;
    _displayedStreak = profile.streakDays;
    final colorScheme = widget.colorScheme;
    final l10n = widget.l10n;

    final goalPct =
        (profile.minutesReadToday / profile.dailyGoalMinutes).clamp(0.0, 1.0);
    final remainingMins = profile.dailyGoalMinutes - profile.minutesReadToday;

    final weekLabels = [
      l10n?.t('home.days.mon') ?? 'Да',
      l10n?.t('home.days.tue') ?? 'Мя',
      l10n?.t('home.days.wed') ?? 'Лх',
      l10n?.t('home.days.thu') ?? 'Пү',
      l10n?.t('home.days.fri') ?? 'Ба',
      l10n?.t('home.days.sat') ?? 'Бя',
      l10n?.t('home.days.sun') ?? 'Ня',
    ];

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 250) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
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
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            // Duolingo-style Animated Flame + Spark Particles
            GestureDetector(
              onTap: () => _triggerDuolingoStreakIncrement(bookProvider),
              child: AnimatedBuilder(
                animation: _celebrationController,
                builder: (context, child) {
                  final t = _celebrationController.value;
                  final bounce = 1.0 + math.sin(t * math.pi) * 0.24;
                  return SizedBox(
                    width: 120,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Spark particles around flame
                        ...List.generate(8, (i) {
                          final angle = (i * math.pi / 4) + (t * 0.6);
                          final radius = 32.0 + (t * 24.0);
                          final opacity = (1.0 - t).clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(
                              math.cos(angle) * radius,
                              math.sin(angle) * radius,
                            ),
                            child: Opacity(
                              opacity: opacity,
                              child: Container(
                                width: i.isEven ? 8 : 5,
                                height: i.isEven ? 8 : 5,
                                decoration: BoxDecoration(
                                  color: i.isEven
                                      ? const Color(0xFFFF9800)
                                      : const Color(0xFFFF5722),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                        Transform.scale(
                          scale: bounce,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF5722)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🔥', style: TextStyle(fontSize: 40)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Rolling Counter Animation (e.g. 4 -> 5)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  transitionBuilder: (child, animation) {
                    final offsetAnim = Tween<Offset>(
                      begin: const Offset(0, 0.6),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticOut,
                    ));
                    return SlideTransition(
                      position: offsetAnim,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    '$_displayedStreak',
                    key: ValueKey<int>(_displayedStreak),
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF6D00),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n?.t('home.streak_sheet_title') ??
                        'хоногийн уншлагын цуврал!',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                const SizedBox(width: 8),
                AnimatedPressable(
                  onTap: () => _navigateToContinueReading(bookProvider),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: profile.isStreakClaimedToday
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : const [Color(0xFFFF6D00), Color(0xFFFF9800)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.isStreakClaimedToday ? '✓' : '📖',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.isStreakClaimedToday
                              ? (l10n?.t('streak.already_claimed_badge') ??
                                  'Өнөөдөр биелсэн ✓')
                              : (l10n?.t('book.read') ?? 'Ном унших'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
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
                        '${profile.minutesReadToday} / ${profile.dailyGoalMinutes} ${l10n?.t('common.minutes_short') ?? 'мин'}',
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
                        ? (l10n?.t('home.streak_goal_done') ??
                            'Өнөөдрийн зорилго биелсэн! 🔥')
                        : (l10n?.t('home.streak_goal_remaining',
                                {'minutes': '$remainingMins'}) ??
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.t('home.streak_weekly') ?? '7 хоногийн амжилт',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(Routes.streakDetail);
                  },
                  child: Text(
                    l10n?.t('book.read_more') ?? 'Дэлгэрэнгүй →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (idx) {
                final isDone = idx < (_displayedStreak % 8).clamp(1, 7);
                return _buildDayItem(weekLabels[idx], isDone, colorScheme);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDayItem(String day, bool isDone, ColorScheme colorScheme) {
  return Column(
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
