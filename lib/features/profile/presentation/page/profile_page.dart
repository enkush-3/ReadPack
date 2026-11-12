import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/profile/widgets/profile_achievements_card.dart';
import 'package:readpack/features/profile/widgets/profile_guest_card.dart';
import 'package:readpack/features/profile/widgets/profile_habits_card.dart';
import 'package:readpack/features/profile/widgets/profile_header_card.dart';
import 'package:readpack/features/profile/widgets/profile_league_card.dart';
import 'package:readpack/features/profile/widgets/profile_xp_card.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/page_loading_skeleton.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<BookProvider>();
      if (!provider.userProfile.isGuest) {
        provider.refreshLeaderboard(period: 'monthly');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final profile = bookProvider.userProfile;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: bookProvider.isLoading
            ? const PageLoadingSkeleton()
            : bookProvider.errorMessage != null
                ? ErrorStateView(
                    errorMessage: bookProvider.errorMessage!,
                    onRetry: bookProvider.retryInitialization,
                  )
                : SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
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
                // Level & XP Progression Card (tappable -> UserLevelDetailPage)
                ProfileXpCard(bookProvider: bookProvider),

                const SizedBox(height: 20),

                // Reading Habits & Time of Day Insights (tappable -> ReadingSchedulePage)
                const ProfileHabitsCard(),

                const SizedBox(height: 20),

                // Statistics Section (Books read -> ReadBooksSheet, Streak -> StreakDetailPage)
                ProfileAchievementsCard(bookProvider: bookProvider),

                const SizedBox(height: 20),

                // Weekly League / Leaderboard Card (moved below statistics)
                ProfileLeagueCard(bookProvider: bookProvider),

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
