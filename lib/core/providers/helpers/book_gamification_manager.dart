import 'package:readpack/models/user_stats.dart';

class BookGamificationManager {
  static UserProfile addReadingMinutes(UserProfile profile, int minutes) {
    if (minutes <= 0) return profile;
    final oldMinutes = profile.minutesReadToday;
    final newMinutes = oldMinutes + minutes;
    int earnedXp = minutes * 5;
    int newStreak = profile.streakDays;
    if (oldMinutes < profile.dailyGoalMinutes &&
        newMinutes >= profile.dailyGoalMinutes) {
      earnedXp += 50;
      newStreak += 1;
    }

    var updated = profile.copyWith(
      minutesReadToday: newMinutes,
      streakDays: newStreak,
      xp: profile.xp + earnedXp,
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
