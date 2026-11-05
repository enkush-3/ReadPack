import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/profile/widgets/profile_achievements_card.dart';
import 'package:readpack/features/profile/widgets/profile_challenge_card.dart';
import 'package:readpack/features/profile/widgets/profile_guest_card.dart';
import 'package:readpack/features/profile/widgets/profile_habits_card.dart';
import 'package:readpack/features/profile/widgets/profile_header_card.dart';
import 'package:readpack/features/profile/widgets/profile_league_card.dart';
import 'package:readpack/features/profile/widgets/profile_retake_card.dart';
import 'package:readpack/features/profile/widgets/profile_xp_card.dart';
import 'package:readpack/helper/translation.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
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
              // User Header (Avatar, Name, Settings / Edit button)
              ProfileHeaderCard(bookProvider: bookProvider),

              const SizedBox(height: 20),

              if (profile.isGuest) ...[
                // Guest Onboarding & Feature Teaser Card
                ProfileGuestCard(bookProvider: bookProvider),
                const SizedBox(height: 24),
              ] else ...[
                // Level & XP Progression Card
                ProfileXpCard(bookProvider: bookProvider),

                const SizedBox(height: 16),

                // Weekly League / Leaderboard Card
                ProfileLeagueCard(bookProvider: bookProvider),

                const SizedBox(height: 20),

                // Daily Reading Goal & 2026 Reading Challenge
                ProfileChallengeCard(bookProvider: bookProvider),

                const SizedBox(height: 24),

                // Reading Habits & Time of Day Insights
                const ProfileHabitsCard(),

                const SizedBox(height: 24),

                // Statistics & Achievements (streak sheet accessible via tapping streak stat)
                ProfileAchievementsCard(bookProvider: bookProvider),

                const SizedBox(height: 24),

                // Personalization / Retake Onboarding Card
                const ProfileRetakeCard(),

                const SizedBox(height: 28),
              ],

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
}
