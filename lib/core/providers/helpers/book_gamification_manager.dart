import 'package:readpack/models/user_stats.dart';

class LeaderboardCompetitor {
  final int rank;
  final String name;
  final int xp;
  final int streak;
  final int booksRead;
  final String avatarEmoji;
  final bool isCurrentUser;

  const LeaderboardCompetitor({
    required this.rank,
    required this.name,
    required this.xp,
    required this.streak,
    required this.booksRead,
    required this.avatarEmoji,
    this.isCurrentUser = false,
  });

  factory LeaderboardCompetitor.fromJson(
    Map<String, dynamic> json, {
    bool isCurrentUser = false,
  }) => LeaderboardCompetitor(
    rank: (json['rank'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? 'ReadPack Reader',
    xp: (json['xp'] as num?)?.toInt() ?? 0,
    streak: (json['streak'] as num?)?.toInt() ?? 0,
    booksRead: (json['booksRead'] as num?)?.toInt() ?? 0,
    avatarEmoji: '📚',
    isCurrentUser: isCurrentUser,
  );

  bool get isUser => isCurrentUser;

  String get badge {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '$rank';
  }
}

class BookGamificationManager {
  static UserProfile addReadingMinutes(UserProfile profile, int minutes) {
    if (minutes <= 0) return profile;
    final oldMinutes = profile.minutesReadToday;
    final newMinutes = oldMinutes + minutes;
    int earnedXp = minutes * 5;
    int newStreak = profile.streakDays;
    String newLastStreakDate = profile.lastStreakDate;
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (oldMinutes < profile.dailyGoalMinutes &&
        newMinutes >= profile.dailyGoalMinutes &&
        profile.lastStreakDate != today) {
      earnedXp += 50;
      newStreak += 1;
      newLastStreakDate = today;
    }

    // Update weekly minutes for today's weekday (0 = Mon .. 6 = Sun)
    final weekdayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
    final updatedWeekly = List<int>.from(
      profile.weeklyMinutes.length == 7
          ? profile.weeklyMinutes
          : const [0, 0, 0, 0, 0, 0, 0],
    );
    updatedWeekly[weekdayIdx] = updatedWeekly[weekdayIdx] + minutes;

    // Update time-of-day bucket
    final hour = DateTime.now().hour;
    final slotKey = hour >= 6 && hour < 12
        ? 'morning'
        : (hour >= 12 && hour < 18
              ? 'afternoon'
              : (hour >= 18 && hour < 23 ? 'evening' : 'night'));
    final updatedTimeOfDay = Map<String, int>.from(profile.timeOfDayMinutes);
    updatedTimeOfDay[slotKey] = (updatedTimeOfDay[slotKey] ?? 0) + minutes;

    var updated = profile.copyWith(
      minutesReadToday: newMinutes,
      streakDays: newStreak,
      lastStreakDate: newLastStreakDate,
      xp: profile.xp + earnedXp,
      weeklyMinutes: updatedWeekly,
      timeOfDayMinutes: updatedTimeOfDay,
    );

    if (newMinutes >= profile.dailyGoalMinutes) {
      final updatedAchievements = updated.achievements.map((a) {
        if (a.id == 'daily_goal') {
          return a.copyWith(isUnlocked: true);
        }
        return a;
      }).toList();
      updated = updated.copyWith(achievements: updatedAchievements);
    }

    return updated;
  }

  static List<LeaderboardCompetitor> getLeaderboardEntries(
    UserProfile profile, {
    String? displayUserName,
  }) {
    return const [];
  }

  static String computeLocalizedLevelTitle(
    int xp,
    String? Function(String key)? translate,
  ) {
    if (xp < 500) {
      return translate?.call('profile.level_1_title') ?? 'Эхлэн уншигч (Lv. 1)';
    }
    if (xp < 1500) {
      return translate?.call('profile.level_2_title') ??
          'Идэвхтэй уншигч (Lv. 2)';
    }
    if (xp < 3000) {
      return translate?.call('profile.level_3_title') ??
          'Номын хорхойтон (Lv. 3)';
    }
    if (xp < 5000) {
      return translate?.call('profile.level_4_title') ??
          'Мэргэшсэн уншигч (Lv. 4)';
    }
    return translate?.call('profile.level_5_title') ?? 'Мэргэн уншигч (Lv. 5)';
  }

  static UserProfile loginAsGuest(UserProfile profile) {
    return UserProfile.freshUser(
      name: 'Зочин',
      email: '',
      username: '@guest',
    ).copyWith(isGuest: true, streakDays: 0, minutesReadToday: 0, xp: 0);
  }

  static UserProfile loginWithEmail(
    UserProfile profile,
    String email,
    String name, {
    String? username,
    String? phoneNumber,
  }) {
    final cleanUsername = (username != null && username.isNotEmpty)
        ? (username.startsWith('@') ? username : '@$username')
        : (profile.username.isNotEmpty
              ? profile.username
              : '@${email.split('@').first.toLowerCase()}');
    return UserProfile.freshUser(
      name: name.isNotEmpty ? name : 'Уншигч',
      email: email,
      username: cleanUsername,
      phoneNumber: phoneNumber ?? profile.phoneNumber,
    );
  }

  static UserProfile registerNewUser({
    required String name,
    required String email,
    String? username,
    String? phoneNumber,
  }) {
    return UserProfile.freshUser(
      name: name,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
    );
  }

  static UserProfile logout() {
    return UserProfile.freshUser(
      name: 'Зочин',
      email: '',
      username: '@guest',
    ).copyWith(isGuest: true, streakDays: 0, minutesReadToday: 0, xp: 0);
  }

  static int computeUserLevel(int xp) {
    if (xp < 500) return 1;
    if (xp < 1500) return 2;
    if (xp < 3000) return 3;
    if (xp < 5000) return 4;
    return 5;
  }

  static String computeUserLevelTitle(int xp) {
    if (xp < 500) return 'Эхлэн уншигч (Lv. 1)';
    if (xp < 1500) return 'Идэвхтэй уншигч (Lv. 2)';
    if (xp < 3000) return 'Номын хорхойтон (Lv. 3)';
    if (xp < 5000) return 'Мэргэшсэн уншигч (Lv. 4)';
    return 'Мэргэн уншигч (Lv. 5)';
  }
}
