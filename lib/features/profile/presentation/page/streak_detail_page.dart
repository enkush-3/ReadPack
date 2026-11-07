import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class StreakDetailPage extends StatefulWidget {
  const StreakDetailPage({super.key});

  @override
  State<StreakDetailPage> createState() => _StreakDetailPageState();
}

class _StreakDetailPageState extends State<StreakDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _triggerStreakCelebration(BookProvider bookProvider) {
    final success = bookProvider.incrementStreak();
    if (success) {
      _celebrationController.forward(from: 0.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.t('streak.already_claimed') ??
                'Та өнөөдрийн цувралаа аль хэдийн авсан байна! 🔥',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final profile = bookProvider.userProfile;
    final l10n = AppLocalizations.of(context);

    final currentStreak = profile.streakDays;
    final bestStreak = profile.bestStreakDays;
    final hasFreeze = profile.streakFreezeAvailable;

    final milestones = [
      {
        'days': 3,
        'title': l10n?.t('streak.m_3') ?? '3 өдрийн эхлэл',
        'xp': 20,
        'unlocked': currentStreak >= 3
      },
      {
        'days': 7,
        'title': l10n?.t('streak.m_7') ?? '7 өдрийн дадал',
        'xp': 50,
        'unlocked': currentStreak >= 7
      },
      {
        'days': 14,
        'title': l10n?.t('streak.m_14') ?? '2 долоо хоног',
        'xp': 100,
        'unlocked': currentStreak >= 14
      },
      {
        'days': 30,
        'title': l10n?.t('streak.m_30') ?? '1 сарын цуврал',
        'xp': 250,
        'unlocked': currentStreak >= 30
      },
      {
        'days': 50,
        'title': l10n?.t('streak.m_50') ?? '50 өдрийн мастер',
        'xp': 500,
        'unlocked': currentStreak >= 50
      },
      {
        'days': 100,
        'title': l10n?.t('streak.m_100') ?? '100 өдрийн домог',
        'xp': 1000,
        'unlocked': currentStreak >= 100
      },
    ];

    final weekDays = [
      l10n?.t('home.days.mon') ?? 'Да',
      l10n?.t('home.days.tue') ?? 'Мя',
      l10n?.t('home.days.wed') ?? 'Лх',
      l10n?.t('home.days.thu') ?? 'Пү',
      l10n?.t('home.days.fri') ?? 'Ба',
      l10n?.t('home.days.sat') ?? 'Бя',
      l10n?.t('home.days.sun') ?? 'Ня',
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          color: colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.t('profile.streak_days') ?? 'Цуврал уншлага',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: NotificationListener<OverscrollNotification>(
        onNotification: (overscroll) {
          if (overscroll.overscroll < -45) {
            Navigator.of(context).pop();
            return true;
          }
          return false;
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Swipe-down indicator pill
              GestureDetector(
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) > 200) {
                    Navigator.of(context).pop();
                  }
                },
                child: Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),

              // 1. Duolingo-Style Hero Streak Flame Banner
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6F00),
                      Color(0xFFFF8F00),
                      Color(0xFFFFA000),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6F00).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _triggerStreakCelebration(bookProvider),
                          child: AnimatedBuilder(
                            animation: _celebrationController,
                            builder: (context, _) {
                              final t = _celebrationController.value;
                              final scale =
                                  1.0 + math.sin(t * math.pi) * 0.22;
                              return SizedBox(
                                width: 84,
                                height: 84,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ...List.generate(6, (i) {
                                      final angle =
                                          (i * math.pi / 3) + (t * 0.5);
                                      final dist = 26.0 + (t * 18.0);
                                      return Transform.translate(
                                        offset: Offset(
                                          math.cos(angle) * dist,
                                          math.sin(angle) * dist,
                                        ),
                                        child: Opacity(
                                          opacity:
                                              (1.0 - t).clamp(0.0, 1.0),
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.local_fire_department_rounded,
                                            size: 44,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 420),
                                    transitionBuilder: (child, animation) {
                                      final slide = Tween<Offset>(
                                        begin: const Offset(0, 0.65),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.elasticOut,
                                      ));
                                      return SlideTransition(
                                        position: slide,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '$currentStreak',
                                      key: ValueKey<int>(currentStreak),
                                      style: const TextStyle(
                                        fontFamily: 'Serif',
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n?.t('streak.days_upper') ?? 'ӨДӨР',
                                    style: const TextStyle(
                                      fontFamily: 'Serif',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n?.t('streak.hero_subtitle') ??
                                    'Цуврал гал асах бүрд таны дадал улам батжиж байна!',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white.withValues(alpha: 0.92),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedPressable(
                        onTap: () => _triggerStreakCelebration(bookProvider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: profile.isStreakClaimedToday
                                ? Colors.black.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(profile.isStreakClaimedToday ? '✓' : '🔥',
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                profile.isStreakClaimedToday
                                    ? (l10n?.t('streak.already_claimed_badge') ??
                                        'Өнөөдөр авсан ✓')
                                    : (l10n?.t('streak.boost_btn') ??
                                        'Өнөөдрийн цуврал +1'),
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
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Quick Streak Stats Row (Best Streak & Freeze)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              size: 18,
                              color: Color(0xFFFFB300),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n?.t('streak.longest') ?? 'Хамгийн урт',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                                Text(
                                  '$bestStreak ${l10n?.t('home.streak_badge') ?? 'өдөр'}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.ac_unit_rounded,
                              size: 18,
                              color: Colors.lightBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n?.t('streak.protection') ?? 'Хамгаалалт',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                                Text(
                                  hasFreeze
                                      ? (l10n?.t('streak.freeze_ready') ??
                                          '1 бэлэн')
                                      : (l10n?.t('streak.freeze_used') ??
                                          'Ашигласан'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: hasFreeze
                                        ? Colors.lightBlue
                                        : colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3. Monthly Activity Matrix
              Text(
                l10n?.t('streak.monthly_calendar') ??
                    'Энэ сарын цуврал календарь',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekDays
                          .map((day) => Expanded(
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: List.generate(28, (index) {
                        final dayNum = index + 1;
                        final isCompleted = dayNum <= currentStreak;
                        final isToday = dayNum == currentStreak;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFFFF6F00)
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: isToday
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '$dayNum',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Streak Milestones & Roadmap
              Text(
                l10n?.t('streak.milestones_title') ??
                    'Цувралын урамшуулал & Зорилтууд',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...milestones.map((m) {
                final isUnlocked = m['unlocked'] as bool;
                final days = m['days'] as int;
                final mTitle = m['title'] as String;
                final xp = m['xp'] as int;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? const Color(0xFFFF6F00).withValues(alpha: 0.08)
                        : colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked
                          ? const Color(0xFFFF6F00).withValues(alpha: 0.3)
                          : colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? const Color(0xFFFF6F00)
                              : colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            isUnlocked
                                ? Icons.check_circle_rounded
                                : Icons.lock_outline_rounded,
                            size: 20,
                            color: isUnlocked
                                ? Colors.white
                                : colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mTitle,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '$days ${l10n?.t('streak.days_in_a_row') ?? 'өдөр дараалан унших'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? const Color(0xFFFF6F00).withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+$xp XP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? const Color(0xFFFF6F00)
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
