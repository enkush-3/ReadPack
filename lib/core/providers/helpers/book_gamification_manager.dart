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
          : const [35, 45, 25, 40, 50, 60, 30],
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
    final userName = displayUserName ?? profile.name;
    final raw = <LeaderboardCompetitor>[
      const LeaderboardCompetitor(
        rank: 1,
        name: 'Номин-Эрдэнэ',
        xp: 1890,
        streak: 19,
        booksRead: 6,
        avatarEmoji: '👑',
      ),
      const LeaderboardCompetitor(
        rank: 2,
        name: 'Төмөрөө Б.',
        xp: 1820,
        streak: 15,
        booksRead: 5,
        avatarEmoji: '🚀',
      ),
      LeaderboardCompetitor(
        rank: 3,
        name: userName,
        xp: profile.xp,
        streak: profile.streakDays,
        booksRead: profile.totalBooksRead,
        avatarEmoji: '⚡',
        isCurrentUser: true,
      ),
      const LeaderboardCompetitor(
        rank: 4,
        name: 'Ану-Үжин Г.',
        xp: 1610,
        streak: 14,
        booksRead: 5,
        avatarEmoji: '🔥',
      ),
      const LeaderboardCompetitor(
        rank: 5,
        name: 'Билгүүн Т.',
        xp: 1540,
        streak: 12,
        booksRead: 4,
        avatarEmoji: '📚',
      ),
      const LeaderboardCompetitor(
        rank: 6,
        name: 'Тэмүүлэн Д.',
        xp: 1420,
        streak: 10,
        booksRead: 4,
        avatarEmoji: '🌟',
      ),
      const LeaderboardCompetitor(
        rank: 7,
        name: 'Мишээл Э.',
        xp: 1280,
        streak: 9,
        booksRead: 3,
        avatarEmoji: '🦊',
      ),
      const LeaderboardCompetitor(
        rank: 8,
        name: 'Гантулга О.',
        xp: 1150,
        streak: 7,
        booksRead: 3,
        avatarEmoji: '🎯',
      ),
      const LeaderboardCompetitor(
        rank: 9,
        name: 'Сарнай Ч.',
        xp: 980,
        streak: 5,
        booksRead: 2,
        avatarEmoji: '🌸',
      ),
      const LeaderboardCompetitor(
        rank: 10,
        name: 'Ананд Х.',
        xp: 840,
        streak: 4,
        booksRead: 2,
        avatarEmoji: '🦉',
      ),
    ];

    raw.sort((a, b) => b.xp.compareTo(a.xp));

    return List.generate(raw.length, (i) {
      final item = raw[i];
      return LeaderboardCompetitor(
        rank: i + 1,
        name: item.name,
        xp: item.xp,
        streak: item.streak,
        booksRead: item.booksRead,
        avatarEmoji: item.avatarEmoji,
        isCurrentUser: item.isCurrentUser,
      );
    });
  }

  static String computeLocalizedLevelTitle(
    int xp,
    String? Function(String key)? translate,
  ) {
    if (xp < 500) {
      return translate?.call('profile.level_1_title') ??
          'Эхлэн уншигч (Lv. 1)';
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
    return translate?.call('profile.level_5_title') ??
        'Мэргэн уншигч (Lv. 5)';
  }

  static UserProfile loginAsGuest(UserProfile profile) {
    return profile.copyWith(
      name: 'Зочин',
      email: 'guest@readpack.app',
      isGuest: true,
      streakDays: 1,
    );
  }

  static UserProfile loginWithEmail(
      UserProfile profile, String email, String name) {
    return profile.copyWith(
      name: name.isNotEmpty ? name : 'Уншигч',
      email: email,
      isGuest: false,
    );
  }

  static UserProfile logout() {
    return const UserProfile(
      name: 'Зочин',
      email: 'guest@readpack.app',
      isGuest: true,
      streakDays: 0,
      minutesReadToday: 0,
    );
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
