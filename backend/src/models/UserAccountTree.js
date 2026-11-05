'use strict';

const crypto = require('crypto');

/**
 * MongoDB Mongoose Schema Definition & Builder for the Hierarchical
 * User Account Tree Document (`UserAccountTree`).
 *
 * Tree Hierarchy:
 * UserAccountTree (Root)
 *  ├── authNode (passwordHash, provider, lastLoginAt)
 *  ├── profileNode (displayName, avatarUrl, bio)
 *  │    └── preferencesNode (language, theme, dailyGoalMinutes, yearlyBookGoal, favoriteGenres, ...)
 *  ├── readingTree
 *  │    └── shelves[] (currently_reading, saved, completed, challenge)
 *  │         └── childrenBooks[] (bookId, title, author, status, progress, currentChapter, currentPage)
 *  │              ├── highlightsNodes[] (highlightId, chapterIndex, text, color, createdAt)
 *  │              └── notesNodes[] (noteId, content, createdAt)
 *  └── gamificationTree
 *       ├── xpNode (totalXp, level, title, weeklyLeague)
 *       ├── streakNode (currentStreak, longestStreak, minutesReadToday, streakFreezeAvailable, historyDates[])
 *       └── challengeNode (year, targetBooks, completedBookIds[], achievementsNodes[])
 */
function registerMongooseUserTreeModel(mongoose) {
  if (mongoose.models && mongoose.models.UserAccountTree) {
    return mongoose.models.UserAccountTree;
  }

  const HighlightNodeSchema = new mongoose.Schema(
    {
      highlightId: { type: String, required: true },
      chapterIndex: { type: Number, default: 0 },
      text: { type: String, required: true },
      color: { type: String, default: 'yellow' },
      createdAt: { type: String, default: () => new Date().toISOString() },
    },
    { _id: false }
  );

  const NoteNodeSchema = new mongoose.Schema(
    {
      noteId: { type: String, required: true },
      content: { type: String, required: true },
      createdAt: { type: String, default: () => new Date().toISOString() },
    },
    { _id: false }
  );

  const ChildBookNodeSchema = new mongoose.Schema(
    {
      bookId: { type: String, required: true },
      title: { type: String, required: true },
      author: { type: String, default: 'Unknown Author' },
      status: {
        type: String,
        enum: ['reading', 'saved', 'completed', 'challenge'],
        default: 'reading',
      },
      progress: { type: Number, default: 0 },
      currentChapter: { type: Number, default: 0 },
      currentPage: { type: Number, default: 0 },
      updatedAt: { type: String, default: () => new Date().toISOString() },
      highlightsNodes: { type: [HighlightNodeSchema], default: [] },
      notesNodes: { type: [NoteNodeSchema], default: [] },
    },
    { _id: false }
  );

  const ShelfNodeSchema = new mongoose.Schema(
    {
      shelfId: { type: String, required: true },
      name: { type: String, required: true },
      childrenBooks: { type: [ChildBookNodeSchema], default: [] },
    },
    { _id: false }
  );

  const UserAccountTreeSchema = new mongoose.Schema(
    {
      userId: { type: String, required: true, unique: true, index: true },
      email: { type: String, required: true, unique: true, index: true },
      authNode: {
        passwordHash: { type: String, required: true },
        provider: { type: String, default: 'email' },
        lastLoginAt: { type: String, default: () => new Date().toISOString() },
      },
      profileNode: {
        displayName: { type: String, required: true },
        avatarUrl: { type: String, default: null },
        bio: { type: String, default: 'ReadPack Reader' },
        preferencesNode: {
          language: { type: String, default: 'mn' },
          theme: { type: String, default: 'system' },
          dailyGoalMinutes: { type: Number, default: 30 },
          yearlyBookGoal: { type: Number, default: 24 },
          favoriteGenres: {
            type: [String],
            default: ['Бизнес', 'Хувь хүний хөгжил', 'Сэтгэл зүй'],
          },
          notificationsEnabled: { type: Boolean, default: true },
          recommendationsEnabled: { type: Boolean, default: true },
        },
      },
      readingTree: {
        shelves: { type: [ShelfNodeSchema], default: [] },
      },
      gamificationTree: {
        xpNode: {
          totalXp: { type: Number, default: 100 },
          level: { type: Number, default: 1 },
          title: { type: String, default: 'Эхлэн уншигч (Lv. 1)' },
          weeklyLeague: { type: String, default: 'Gold League' },
        },
        streakNode: {
          currentStreak: { type: Number, default: 1 },
          longestStreak: { type: Number, default: 1 },
          minutesReadToday: { type: Number, default: 0 },
          streakFreezeAvailable: { type: Boolean, default: true },
          historyDates: { type: [String], default: [] },
        },
        challengeNode: {
          year: { type: Number, default: 2026 },
          targetBooks: { type: Number, default: 24 },
          completedBookIds: { type: [String], default: [] },
          achievementsNodes: { type: Array, default: [] },
        },
      },
    },
    { timestamps: true }
  );

  return mongoose.model('UserAccountTree', UserAccountTreeSchema, 'users');
}

function computeLevel(xp) {
  if (xp < 500) return 1;
  if (xp < 1500) return 2;
  if (xp < 3000) return 3;
  if (xp < 5000) return 4;
  return 5;
}

function computeLevelTitle(xp) {
  if (xp < 500) return 'Эхлэн уншигч (Lv. 1)';
  if (xp < 1500) return 'Идэвхтэй уншигч (Lv. 2)';
  if (xp < 3000) return 'Номын хорхойтон (Lv. 3)';
  if (xp < 5000) return 'Мэргэшсэн уншигч (Lv. 4)';
  return 'Мэргэн уншигч (Lv. 5)';
}

function hashPassword(rawPassword = 'readpack123') {
  return crypto.createHash('sha256').update(String(rawPassword)).digest('hex');
}

function createDefaultUserAccountTree({
  userId,
  email,
  displayName = 'Уншигч',
  password = 'readpack123',
  provider = 'email',
  xp = 1450,
  streakDays = 7,
}) {
  const cleanEmail = String(email || 'user@readpack.app').trim().toLowerCase();
  const resolvedId =
    userId ||
    `usr_${cleanEmail.replace(/[^a-z0-9]/g, '_').replace(/_+/g, '_')}`;
  const todayIso = new Date().toISOString().slice(0, 10);

  return {
    userId: resolvedId,
    email: cleanEmail,
    authNode: {
      passwordHash: hashPassword(password),
      provider,
      lastLoginAt: new Date().toISOString(),
    },
    profileNode: {
      displayName: displayName || 'Уншигч',
      avatarUrl: null,
      bio: 'ReadPack дижитал уншигч',
      preferencesNode: {
        language: 'mn',
        theme: 'system',
        dailyGoalMinutes: 30,
        yearlyBookGoal: 24,
        favoriteGenres: ['Бизнес', 'Хувь хүний хөгжил', 'Сэтгэл зүй'],
        notificationsEnabled: true,
        recommendationsEnabled: true,
      },
    },
    readingTree: {
      shelves: [
        {
          shelfId: 'currently_reading',
          name: 'Уншиж буй',
          childrenBooks: [],
        },
        {
          shelfId: 'saved',
          name: 'Хадгалсан',
          childrenBooks: [],
        },
        {
          shelfId: 'completed',
          name: 'Уншиж дууссан',
          childrenBooks: [],
        },
        {
          shelfId: 'challenge_2026',
          name: '2026 оны Челленж',
          childrenBooks: [],
        },
      ],
    },
    gamificationTree: {
      xpNode: {
        totalXp: xp,
        level: computeLevel(xp),
        title: computeLevelTitle(xp),
        weeklyLeague: 'Gold League',
      },
      streakNode: {
        currentStreak: streakDays,
        longestStreak: Math.max(streakDays, 7),
        minutesReadToday: 24,
        streakFreezeAvailable: true,
        historyDates: [todayIso],
      },
      challengeNode: {
        year: 2026,
        targetBooks: 24,
        completedBookIds: [],
        achievementsNodes: [
          {
            id: 'streak_7',
            title: '🔥 7 хоногийн цуврал',
            isUnlocked: streakDays >= 7,
            progress: Math.min(1.0, streakDays / 7),
          },
        ],
      },
    },
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
}

module.exports = {
  registerMongooseUserTreeModel,
  createDefaultUserAccountTree,
  computeLevel,
  computeLevelTitle,
  hashPassword,
};
