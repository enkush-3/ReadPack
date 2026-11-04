import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showEditProfileSheet(BuildContext context, BookProvider bookProvider) {
    final nameCtrl = TextEditingController(text: bookProvider.userProfile.name);
    int selectedGoal = bookProvider.userProfile.dailyGoalMinutes;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            final colorScheme = Theme.of(dialogContext).colorScheme;

            return Container(
              padding: EdgeInsets.fromLTRB(
                  24, 20, 24, MediaQuery.of(dialogContext).viewInsets.bottom + 28),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.t('profile.edit_profile') ?? 'Профайл засах',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n?.t('auth.full_name_label') ?? 'Нэр',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n?.t('profile.daily_goal') ?? 'Өдрийн зорилго (минут)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [15, 30, 45, 60].map((mins) {
                      final isSelected = selectedGoal == mins;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => selectedGoal = mins);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '$mins ${l10n?.t('common.minutes_short') ?? 'мин'}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(l10n?.t('common.cancel') ?? 'Цуцлах'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final newName = nameCtrl.text.trim();
                            if (newName.isNotEmpty) {
                              bookProvider.updateUserProfile(
                                name: newName,
                                dailyGoalMinutes: selectedGoal,
                              );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n?.t('success.profile_updated') ??
                                        'Профайл амжилттай шинэчлэгдлээ',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Text(l10n?.t('common.save') ?? 'Хадгалах'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, BookProvider bookProvider) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n?.t('auth.logout') ?? 'Гарах',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n?.t('profile.logout_confirm') ??
                'Та гарахдаа итгэлтэй байна уу?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n?.t('common.cancel') ?? 'Цуцлах'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                bookProvider.logout();
                Navigator.of(context).pushReplacementNamed(Routes.auth);
              },
              child: Text(l10n?.t('auth.logout') ?? 'Гарах'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final profile = bookProvider.userProfile;
    final l10n = AppLocalizations.of(context);
    final displayName = profile.isGuest
        ? (l10n?.t('profile.guest_user') ?? profile.name)
        : profile.name;

    final goalProgress =
        (profile.minutesReadToday / profile.dailyGoalMinutes).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
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
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
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
                        Row(
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontFamily: 'Serif',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (profile.isGuest) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  l10n?.t('profile.guest_badge') ?? 'Зочин',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedPressable(
                    onTap: () => _showEditProfileSheet(context, bookProvider),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              // Guest banner prompt
              if (profile.isGuest) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer.withValues(alpha: 0.6),
                        colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: colorScheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n?.t('profile.guest_prompt') ??
                              'Та зочны горимоор орсон байна. Бүртгэл үүсгэж уншлагын ахицаа хадгалаарай.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.auth);
                        },
                        child: Text(
                          l10n?.t('profile.login_signup') ?? 'Нэвтрэх',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Level & XP Progression Card
              _buildXpProgressionCard(
                context: context,
                colorScheme: colorScheme,
                bookProvider: bookProvider,
                l10n: l10n,
              ),

              const SizedBox(height: 16),

              // Weekly League / Leaderboard Card
              _buildWeeklyLeagueCard(
                context: context,
                colorScheme: colorScheme,
                bookProvider: bookProvider,
                l10n: l10n,
              ),

              const SizedBox(height: 20),

              // Streak Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE65100).withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.streakDays} ${l10n?.t('profile.streak_days') ?? 'хоногийн уншлагын цуврал!'}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.minutesReadToday >= profile.dailyGoalMinutes
                                ? (l10n?.t('home.streak_goal_done') ??
                                    'Өнөөдрийн зорилго биелсэн! 🔥')
                                : (l10n
                                        ?.t('home.streak_goal_remaining')
                                        .replaceAll('{minutes}',
                                            '${profile.dailyGoalMinutes - profile.minutesReadToday}') ??
                                    '${profile.dailyGoalMinutes - profile.minutesReadToday} минут уншаад өдрийн зорилгодоо хүрээрэй.'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Daily Reading Goal Section
              Text(
                l10n?.t('profile.daily_goal') ?? 'Өдрийн зорилго',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
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
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 36,
                      lineWidth: 7,
                      percent: goalProgress,
                      progressColor: colorScheme.primary,
                      backgroundColor:
                          colorScheme.outlineVariant.withValues(alpha: 0.3),
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Text(
                        '${(goalProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.minutesReadToday} / ${profile.dailyGoalMinutes} ${l10n?.t('profile.minutes_today') ?? 'минут өнөөдөр'}',
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${profile.dailyGoalMinutes} ${l10n?.t('profile.daily_goal_sub') ?? 'минутын зорилго'}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2026 Reading Challenge (Goodreads-style)
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.t('profile.reading_challenge') ??
                        '2026 оны уншлагын челленж',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '2026',
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
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF4CAF50).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.emoji_events_rounded,
                              color: Color(0xFF4CAF50),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${profile.totalBooksRead} / 25 ${l10n?.t('home.books_count') ?? 'ном'}',
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (l10n?.t('profile.reading_challenge_sub') ??
                                        '{current} of {goal} books read ({percent}%)')
                                    .replaceAll(
                                        '{current}', '${profile.totalBooksRead}')
                                    .replaceAll('{goal}', '25')
                                    .replaceAll('{percent}',
                                        '${((profile.totalBooksRead / 25).clamp(0.0, 1.0) * 100).toInt()}'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearPercentIndicator(
                        lineHeight: 8,
                        percent:
                            (profile.totalBooksRead / 25).clamp(0.0, 1.0),
                        padding: EdgeInsets.zero,
                        backgroundColor:
                            colorScheme.outlineVariant.withValues(alpha: 0.3),
                        progressColor: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reading Habits & Time of Day Heatmap
              _buildReadingHabitsCard(
                context: context,
                colorScheme: colorScheme,
                l10n: l10n,
              ),

              const SizedBox(height: 24),

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

              // Achievements Section
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
                        ? colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3)
                        : colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.15),
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
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
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
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              achDesc,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (ach.isUnlocked)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 20,
                        )
                      else
                        Icon(
                          Icons.lock_outline_rounded,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          size: 20,
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Personalization / Retake Onboarding Card
              _buildRetakeOnboardingCard(context, colorScheme, l10n),

              const SizedBox(height: 28),

              // Comprehensive Settings Group
              Text(
                l10n?.t('profile.settings') ?? 'Тохиргоо',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Theme Switch
                    ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        l10n?.t('profile.dark_mode') ?? 'Харанхуй горим',
                      ),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),

                    // Language Switcher
                    ListTile(
                      leading: Icon(
                        Icons.language_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        l10n?.t('profile.language') ?? 'Хэл (Language)',
                      ),
                      trailing: DropdownButton<String>(
                        value: themeProvider.locale.languageCode,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: 'mn', child: Text('Монгол')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (lang) {
                          if (lang != null) {
                            themeProvider.setLocale(Locale(lang));
                          }
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),

                    // Daily Reminder Toggle
                    ListTile(
                      leading: Icon(
                        Icons.notifications_active_outlined,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        l10n?.t('profile.daily_reminder') ??
                            'Өдрийн уншлагын сануулга',
                      ),
                      trailing: Switch(
                        value: profile.notificationsEnabled,
                        onChanged: (val) {
                          bookProvider.updateUserProfile(
                            notificationsEnabled: val,
                          );
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),

                    // Book Recommendations Toggle
                    ListTile(
                      leading: Icon(
                        Icons.recommend_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        l10n?.t('profile.book_recommendations') ??
                            'Шинэ номын зөвлөмж',
                      ),
                      trailing: Switch(
                        value: profile.recommendationsEnabled,
                        onChanged: (val) {
                          bookProvider.updateUserProfile(
                            recommendationsEnabled: val,
                          );
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),

                    // Clear Cache Action
                    ListTile(
                      leading: Icon(
                        Icons.cleaning_services_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        l10n?.t('profile.storage_cache') ?? 'Кэш цэвэрлэх',
                      ),
                      subtitle: const Text(
                        '14.2 MB',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14),
                      onTap: () {
                        bookProvider.clearCache();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.t('profile.cache_cleared') ??
                                  'Кэш амжилттай цэвэрлэгдлээ (14.2 MB чөлөөллөө)',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),

                    // Logout
                    ListTile(
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        l10n?.t('profile.logout') ?? 'Гарах (Logout)',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () => _showLogoutDialog(context, bookProvider),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  l10n?.t('profile.version') ?? 'ReadPack v1.2.0 • 2026',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
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
      ),
    );
  }

  Widget _buildXpProgressionCard({
    required BuildContext context,
    required ColorScheme colorScheme,
    required BookProvider bookProvider,
    required AppLocalizations? l10n,
  }) {
    final xp = bookProvider.userProfile.xp;
    final levelTitle = bookProvider.userLevelTitle;
    int currentLevelBase = 0;
    int nextLevelTarget = 500;
    if (xp >= 500 && xp < 1500) {
      currentLevelBase = 500;
      nextLevelTarget = 1500;
    } else if (xp >= 1500 && xp < 3000) {
      currentLevelBase = 1500;
      nextLevelTarget = 3000;
    } else if (xp >= 3000 && xp < 5000) {
      currentLevelBase = 3000;
      nextLevelTarget = 5000;
    } else if (xp >= 5000) {
      currentLevelBase = 5000;
      nextLevelTarget = 10000;
    }

    final double levelProgress =
        ((xp - currentLevelBase) / (nextLevelTarget - currentLevelBase))
            .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.5),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '🛡️',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        levelTitle,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        l10n?.t('profile.level_title') ?? 'Түвшин ба Цол',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.amber.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '$xp XP',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearPercentIndicator(
              lineHeight: 8,
              percent: levelProgress,
              padding: EdgeInsets.zero,
              backgroundColor:
                  colorScheme.outlineVariant.withValues(alpha: 0.3),
              progressColor: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$xp / $nextLevelTarget XP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Дараагийн цолд хүрэхэд ${(nextLevelTarget - xp).clamp(0, 10000)} XP дутуу',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyLeagueCard({
    required BuildContext context,
    required ColorScheme colorScheme,
    required BookProvider bookProvider,
    required AppLocalizations? l10n,
  }) {
    final profile = bookProvider.userProfile;
    final leagueName =
        profile.weeklyLeague.isNotEmpty ? profile.weeklyLeague : 'Gold League';

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
        'isUser': true
      },
      {'rank': '4', 'name': 'Бат-Эрдэнэ', 'xp': 1290, 'badge': '4', 'isUser': false},
      {'rank': '5', 'name': 'Хулан', 'xp': 1150, 'badge': '5', 'isUser': false},
    ];

    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    ? Border.all(color: colorScheme.primary.withValues(alpha: 0.3))
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
                        fontWeight: isUser ? FontWeight.bold : FontWeight.w500,
                        color:
                            isUser ? colorScheme.primary : colorScheme.onSurface,
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
              l10n?.t('profile.diamond_promotion') ?? '💎 Эхний 3 байр Алмазан Лиг рүү дэвшинэ',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingHabitsCard({
    required BuildContext context,
    required ColorScheme colorScheme,
    required AppLocalizations? l10n,
  }) {
    return Container(
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
            children: [
              Icon(Icons.schedule_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n?.t('profile.time_of_day_insights') ??
                    'Уншлагын цагийн хуваарь',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.t('profile.peak_reading_time') ??
                'Таны хамгийн бүтээмжтэй уншдаг цаг: Орой 20:00 - 22:30 🌙',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeBar(
              l10n?.t('profile.morning') ?? 'Өглөө (06:00 - 12:00)',
              0.35,
              colorScheme,
              Colors.amber),
          const SizedBox(height: 8),
          _buildTimeBar(
              l10n?.t('profile.afternoon') ?? 'Өдөр (12:00 - 18:00)',
              0.25,
              colorScheme,
              Colors.blue),
          const SizedBox(height: 8),
          _buildTimeBar(
              l10n?.t('profile.night') ?? 'Орой (18:00 - 00:00)',
              0.40,
              colorScheme,
              Colors.indigoAccent),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              {'day': l10n?.t('home.days.mon') ?? 'Да', 'm': 30},
              {'day': l10n?.t('home.days.tue') ?? 'Мя', 'm': 25},
              {'day': l10n?.t('home.days.wed') ?? 'Лх', 'm': 40},
              {'day': l10n?.t('home.days.thu') ?? 'Пү', 'm': 20},
              {'day': l10n?.t('home.days.fri') ?? 'Ба', 'm': 35},
              {'day': l10n?.t('home.days.sat') ?? 'Бя', 'm': 45},
              {'day': l10n?.t('home.days.sun') ?? 'Ня', 'm': 30},
            ].map((d) {
              final mins = d['m'] as int;
              final height = (mins / 45.0) * 36;
              return Column(
                children: [
                  Container(
                    width: 14,
                    height: 40,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: mins >= 30
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d['day'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBar(
      String title, double percent, ColorScheme colorScheme, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.8))),
            Text('${(percent * 100).toInt()}%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearPercentIndicator(
            lineHeight: 6,
            percent: percent,
            padding: EdgeInsets.zero,
            backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.25),
            progressColor: barColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRetakeOnboardingCard(
      BuildContext context, ColorScheme colorScheme, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.tune_rounded, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.t('profile.retake_onboarding') ??
                      'Зорилго & Сонирхол шинэчлэх',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Унших жанр, өдрийн минутын зорилгоо дахин тохируулах',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.onboarding);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Засах',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
