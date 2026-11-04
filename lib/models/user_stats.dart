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

  const UserProfile({
    this.name = 'Enkush',
    this.email = 'enkush@readpack.app',
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

  UserProfile copyWith({
    String? name,
    String? email,
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
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
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
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? 'Enkush',
    email: json['email'] as String? ?? 'enkush@readpack.app',
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
  );
}
