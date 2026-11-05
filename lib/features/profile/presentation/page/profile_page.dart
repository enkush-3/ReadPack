import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/profile/widgets/profile_achievements_card.dart';
import 'package:readpack/features/profile/widgets/profile_challenge_card.dart';
import 'package:readpack/features/profile/widgets/profile_habits_card.dart';
import 'package:readpack/features/profile/widgets/profile_header_card.dart';
import 'package:readpack/features/profile/widgets/profile_league_card.dart';
import 'package:readpack/features/profile/widgets/profile_retake_card.dart';
import 'package:readpack/features/profile/widgets/profile_settings_card.dart';
import 'package:readpack/features/profile/widgets/profile_xp_card.dart';
import 'package:readpack/helper/translation.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final profile = bookProvider.userProfile;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header (Avatar, Name, Guest badge & Guest prompt)
              ProfileHeaderCard(bookProvider: bookProvider),

              const SizedBox(height: 20),

              // Level & XP Progression Card
              ProfileXpCard(bookProvider: bookProvider),

              const SizedBox(height: 16),

              // Weekly League / Leaderboard Card
              ProfileLeagueCard(bookProvider: bookProvider),

              const SizedBox(height: 20),

              // Streak Banner
              _buildStreakBanner(profile, colorScheme, l10n),

              const SizedBox(height: 24),

              // Daily Reading Goal & 2026 Reading Challenge
              ProfileChallengeCard(bookProvider: bookProvider),

              const SizedBox(height: 24),

              // Reading Habits & Time of Day Insights
              const ProfileHabitsCard(),

              const SizedBox(height: 24),

              // Statistics & Achievements
              ProfileAchievementsCard(bookProvider: bookProvider),

              const SizedBox(height: 24),

              // Personalization / Retake Onboarding Card
              const ProfileRetakeCard(),

              const SizedBox(height: 28),

              // Settings Card
              ProfileSettingsCard(
                bookProvider: bookProvider,
                themeProvider: themeProvider,
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

  Widget _buildStreakBanner(
    dynamic profile,
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
    final remainingMinutes =
        (profile.dailyGoalMinutes - profile.minutesReadToday).clamp(0, 9999);

    return Container(
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
                      : (l10n?.t('home.streak_goal_remaining', {
                            'minutes': '$remainingMinutes',
                          }) ??
                          '$remainingMinutes минут уншаад өдрийн зорилгодоо хүрээрэй.'),
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
    );
  }
}
