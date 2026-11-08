class ReadingAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final double progress;

  const ReadingAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.progress = 1.0,
  });

  ReadingAchievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? isUnlocked,
    double? progress,
  }) {
    return ReadingAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'isUnlocked': isUnlocked,
    'progress': progress,
  };

  factory ReadingAchievement.fromJson(Map<String, dynamic> json) =>
      ReadingAchievement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        progress: (json['progress'] as num?)?.toDouble() ?? 1.0,
      );
}

class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final int streakDays;
  final int dailyGoalMinutes;
  final int minutesReadToday;
  final int totalBooksRead;
  final int totalHoursRead;
  final int readingSpeedWpm;
  final bool isGuest;
  final bool streakFreezeAvailable;
  final bool notificationsEnabled;
  final bool recommendationsEnabled;
  final List<ReadingAchievement> achievements;
  final int xp;
  final String weeklyLeague;
  final List<String> favoriteGenres;
  final int yearlyGoalBooks;
  final bool onboardingCompleted;
  final String lastStreakDate;
  final List<int> weeklyMinutes;
  final Map<String, int> timeOfDayMinutes;
  final int reminderHour;
  final bool remindersEnabled;

  const UserProfile({
    this.name = 'Enkush',
    this.email = 'enkush@readpack.app',
    this.avatarUrl = '',
    this.streakDays = 7,
    this.dailyGoalMinutes = 30,
    this.minutesReadToday = 24,
    this.totalBooksRead = 14,
    this.totalHoursRead = 42,
    this.readingSpeedWpm = 250,
    this.isGuest = false,
    this.streakFreezeAvailable = true,
    this.notificationsEnabled = true,
    this.recommendationsEnabled = true,
    this.xp = 1450,
    this.weeklyLeague = 'Gold League',
    this.favoriteGenres = const ['Бизнес', 'Хувь хүний хөгжил', 'Сэтгэл зүй'],
    this.yearlyGoalBooks = 24,
    this.onboardingCompleted = true,
    this.lastStreakDate = '',
    this.weeklyMinutes = const [35, 45, 25, 40, 50, 60, 30],
    this.timeOfDayMinutes = const {
      'morning': 40,
      'afternoon': 75,
      'evening': 150,
      'night': 20,
    },
    this.reminderHour = 20,
    this.remindersEnabled = true,
    this.achievements = const [
      ReadingAchievement(
        id: 'streak_7',
        title: '🔥 7 Day Streak',
        description: 'Read every day for one full week',
        icon: '🔥',
        isUnlocked: true,
      ),
      ReadingAchievement(
        id: 'bookworm',
        title: '🐛 Avid Bookworm',
        description: 'Finish reading 10 or more books',
        icon: '📚',
        isUnlocked: true,
      ),
      ReadingAchievement(
        id: 'night_owl',
        title: '🦉 Night Owl',
        description: 'Read past midnight for 30 minutes',
        icon: '🌙',
        isUnlocked: true,
      ),
      ReadingAchievement(
        id: 'speed_reader',
        title: '⚡ Speed Reader',
        description: 'Read at over 240 words per minute',
        icon: '⚡',
        isUnlocked: false,
        progress: 0.8,
      ),
    ],
  });

  int get bestStreakDays => streakDays > 14 ? streakDays : 14;

  int get totalWeeklyMinutes =>
      weeklyMinutes.fold<int>(0, (sum, m) => sum + m);

  int get _totalTimeOfDayMinutes {
    final total = timeOfDayMinutes.values.fold<int>(0, (s, v) => s + v);
    return total > 0 ? total : 285;
  }

  int get morningPercentage =>
      (((timeOfDayMinutes['morning'] ?? 40) / _totalTimeOfDayMinutes) * 100)
          .round();

  int get afternoonPercentage =>
      (((timeOfDayMinutes['afternoon'] ?? 75) / _totalTimeOfDayMinutes) * 100)
          .round();

  int get eveningPercentage =>
      (((timeOfDayMinutes['evening'] ?? 150) / _totalTimeOfDayMinutes) * 100)
          .round();

  int get nightPercentage {
    final rem = 100 - morningPercentage - afternoonPercentage - eveningPercentage;
    return rem.clamp(0, 100);
  }

  bool get isStreakClaimedToday {
    if (minutesReadToday >= dailyGoalMinutes) return true;
    if (lastStreakDate.isEmpty) return false;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return lastStreakDate == today;
  }

  int get userLevel {
    if (xp < 500) return 1;
    if (xp < 1500) return 2;
    if (xp < 3000) return 3;
    if (xp < 5000) return 4;
    return 5;
  }

  String get userLevelTitle {
    if (xp < 500) return 'Эхлэн уншигч (Lv. 1)';
    if (xp < 1500) return 'Идэвхтэй уншигч (Lv. 2)';
    if (xp < 3000) return 'Номын хорхойтон (Lv. 3)';
    if (xp < 5000) return 'Мэргэшсэн уншигч (Lv. 4)';
    return 'Мэргэн уншигч (Lv. 5)';
  }

  int get currentLevelBase {
    if (xp >= 500 && xp < 1500) return 500;
    if (xp >= 1500 && xp < 3000) return 1500;
    if (xp >= 3000 && xp < 5000) return 3000;
    if (xp >= 5000) return 5000;
    return 0;
  }

  int get xpNeededForNextLevel {
    if (xp >= 500 && xp < 1500) return 1500;
    if (xp >= 1500 && xp < 3000) return 3000;
    if (xp >= 3000 && xp < 5000) return 5000;
    if (xp >= 5000) return 10000;
    return 500;
  }

  int get xpInCurrentLevel => (xp - currentLevelBase).clamp(0, 10000);

  double get levelProgress =>
      ((xp - currentLevelBase) / (xpNeededForNextLevel - currentLevelBase))
          .clamp(0.0, 1.0);

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? streakDays,
    int? dailyGoalMinutes,
    int? minutesReadToday,
    int? totalBooksRead,
    int? totalHoursRead,
    int? readingSpeedWpm,
    bool? isGuest,
    bool? streakFreezeAvailable,
    bool? notificationsEnabled,
    bool? recommendationsEnabled,
    List<ReadingAchievement>? achievements,
    int? xp,
    String? weeklyLeague,
    List<String>? favoriteGenres,
    int? yearlyGoalBooks,
    bool? onboardingCompleted,
    String? lastStreakDate,
    List<int>? weeklyMinutes,
    Map<String, int>? timeOfDayMinutes,
    int? reminderHour,
    bool? remindersEnabled,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      streakDays: streakDays ?? this.streakDays,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      minutesReadToday: minutesReadToday ?? this.minutesReadToday,
      totalBooksRead: totalBooksRead ?? this.totalBooksRead,
      totalHoursRead: totalHoursRead ?? this.totalHoursRead,
      readingSpeedWpm: readingSpeedWpm ?? this.readingSpeedWpm,
      isGuest: isGuest ?? this.isGuest,
      streakFreezeAvailable:
          streakFreezeAvailable ?? this.streakFreezeAvailable,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      recommendationsEnabled:
          recommendationsEnabled ?? this.recommendationsEnabled,
      achievements: achievements ?? this.achievements,
      xp: xp ?? this.xp,
      weeklyLeague: weeklyLeague ?? this.weeklyLeague,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      yearlyGoalBooks: yearlyGoalBooks ?? this.yearlyGoalBooks,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      weeklyMinutes: weeklyMinutes ?? this.weeklyMinutes,
      timeOfDayMinutes: timeOfDayMinutes ?? this.timeOfDayMinutes,
      reminderHour: reminderHour ?? this.reminderHour,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'streakDays': streakDays,
    'dailyGoalMinutes': dailyGoalMinutes,
    'minutesReadToday': minutesReadToday,
    'totalBooksRead': totalBooksRead,
    'totalHoursRead': totalHoursRead,
    'readingSpeedWpm': readingSpeedWpm,
    'isGuest': isGuest,
    'streakFreezeAvailable': streakFreezeAvailable,
    'notificationsEnabled': notificationsEnabled,
    'recommendationsEnabled': recommendationsEnabled,
    'achievements': achievements.map((a) => a.toJson()).toList(),
    'xp': xp,
    'weeklyLeague': weeklyLeague,
    'favoriteGenres': favoriteGenres,
    'yearlyGoalBooks': yearlyGoalBooks,
    'onboardingCompleted': onboardingCompleted,
    'lastStreakDate': lastStreakDate,
    'weeklyMinutes': weeklyMinutes,
    'timeOfDayMinutes': timeOfDayMinutes,
    'reminderHour': reminderHour,
    'remindersEnabled': remindersEnabled,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? 'Enkush',
    email: json['email'] as String? ?? 'enkush@readpack.app',
    avatarUrl: json['avatarUrl'] as String? ?? '',
    streakDays: json['streakDays'] as int? ?? 7,
    dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 30,
    minutesReadToday: json['minutesReadToday'] as int? ?? 24,
    totalBooksRead: json['totalBooksRead'] as int? ?? 14,
    totalHoursRead: json['totalHoursRead'] as int? ?? 42,
    readingSpeedWpm: json['readingSpeedWpm'] as int? ?? 250,
    isGuest: json['isGuest'] as bool? ?? false,
    streakFreezeAvailable: json['streakFreezeAvailable'] as bool? ?? true,
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    recommendationsEnabled: json['recommendationsEnabled'] as bool? ?? true,
    achievements: (json['achievements'] as List<dynamic>?)
            ?.map((a) => ReadingAchievement.fromJson(a as Map<String, dynamic>))
            .toList() ??
        const [],
    xp: json['xp'] as int? ?? 1450,
    weeklyLeague: json['weeklyLeague'] as String? ?? 'Gold League',
    favoriteGenres: (json['favoriteGenres'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const ['Бизнес', 'Хувь хүний хөгжил', 'Сэтгэл зүй'],
    yearlyGoalBooks: json['yearlyGoalBooks'] as int? ?? 24,
    onboardingCompleted: json['onboardingCompleted'] as bool? ?? true,
    lastStreakDate: json['lastStreakDate'] as String? ?? '',
    weeklyMinutes: (json['weeklyMinutes'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        const [35, 45, 25, 40, 50, 60, 30],
    timeOfDayMinutes: (json['timeOfDayMinutes'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
        const {
          'morning': 40,
          'afternoon': 75,
          'evening': 150,
          'night': 20,
        },
    reminderHour: json['reminderHour'] as int? ?? 20,
    remindersEnabled: json['remindersEnabled'] as bool? ?? true,
  );
}
