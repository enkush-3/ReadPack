import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/user_stats.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    required this.userName,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context);
    if (hour < 12) {
      return l10n?.t('home.greeting_morning') ?? 'Өглөөний мэнд,';
    } else if (hour < 18) {
      return l10n?.t('home.greeting_afternoon') ?? 'Өдрийн мэнд,';
    } else {
      return l10n?.t('home.greeting_evening') ?? 'Оройн мэнд,';
    }
  }

  void _showStreakSheet(BuildContext context, UserProfile profile,
      ColorScheme colorScheme, AppLocalizations? l10n) {
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
              // Pull bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Streak Flame Hero
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
                  child: Text(
                    '🔥',
                    style: TextStyle(fontSize: 38),
                  ),
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

              // Streak freeze pill
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
                    const Icon(Icons.shield_rounded,
                        size: 16, color: Color(0xFF0091EA)),
                    const SizedBox(width: 6),
                    Text(
                      l10n?.t('home.streak_freeze') ?? 'Цуврал хамгаалагдсан',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0091EA),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Daily Goal Progress Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
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
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearPercentIndicator(
                        lineHeight: 10,
                        percent: goalPct,
                        padding: EdgeInsets.zero,
                        backgroundColor:
                            colorScheme.outlineVariant.withValues(alpha: 0.3),
                        progressColor: const Color(0xFFFF5722),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      remainingMins <= 0
                          ? (l10n?.t('home.streak_goal_done') ??
                              'Өнөөдрийн зорилго биелсэн! 🔥')
                          : (l10n
                                  ?.t('home.streak_goal_remaining')
                                  .replaceAll('{minutes}', '$remainingMins') ??
                              'Өнөөдөр дахин $remainingMins минут уншаад зорилгоо биелүүлээрэй.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 7-day Activity Dots
              Text(
                l10n?.t('home.streak_weekly') ?? '7 хоногийн амжилт',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
                  final daysFallback = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];
                  final dayLabel = l10n?.t('home.days.${dayKeys[index]}') ?? daysFallback[index];
                  final isDone = index < profile.streakDays.clamp(0, 7);
                  return Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? const Color(0xFFFF5722)
                              : colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFF5722)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            isDone
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            size: 18,
                            color: isDone
                                ? Colors.white
                                : colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isDone ? FontWeight.bold : FontWeight.normal,
                          color: isDone
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Close / Continue button
              AnimatedPressable(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      l10n?.t('common.done') ?? 'Боллоо',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final profile = bookProvider.userProfile;
    final unreadCount = bookProvider.unreadNotificationsCount;
    final l10n = AppLocalizations.of(context);
    final displayName = profile.isGuest
        ? (l10n?.t('profile.guest_user') ?? (userName.isNotEmpty ? userName : 'Guest'))
        : (userName.isNotEmpty ? userName : profile.name);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Avatar + Greeting
        Expanded(
          child: Row(
            children: [
              AnimatedPressable(
                onTap: onAvatarTap,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getGreeting(context),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Right side: Reading Streak Badge + Notifications
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Interactive Reading Streak (Flame) Badge
            AnimatedPressable(
              onTap: () => _showStreakSheet(context, profile, colorScheme, l10n),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF5722).withValues(alpha: 0.15),
                      const Color(0xFFFF9800).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.streakDays} ${l10n?.t('home.streak_badge') ?? 'хоног'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Notification Bell
            AnimatedPressable(
              onTap: onNotificationTap ??
                  () {
                    Navigator.of(context).pushNamed(Routes.notifications);
                  },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      unreadCount > 0
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        child: Center(
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}