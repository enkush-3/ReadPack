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
      syncReadingEventIds: { type: [String], default: [] },
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
      email: {
        type: String,
        lowercase: true,
        trim: true,
        unique: true,
        sparse: true,
        index: true,
        default: undefined,
      },
      authNode: {
        passwordHash: { type: String, default: null },
        provider: { type: String, default: 'email' },
        providerSubject: { type: String, default: null },
        emailVerified: { type: Boolean, default: false },
        phoneVerified: { type: Boolean, default: false },
        lastLoginAt: { type: String, default: () => new Date().toISOString() },
        verificationChallenge: {
          challengeId: { type: String, default: null },
          purpose: { type: String, default: null },
          contact: { type: String, default: null },
          contactType: { type: String, default: null },
          otpHash: { type: String, default: null },
          providerVerificationSid: { type: String, default: null },
          expiresAt: { type: String, default: null },
          attempts: { type: Number, default: 0 },
        },
        refreshSessions: {
          type: [{ sessionId: String, tokenHash: String, expiresAt: String }],
          default: [],
        },
      },
      profileNode: {
        displayName: { type: String, required: true },
        phoneNumber: {
          type: String,
          trim: true,
          unique: true,
          sparse: true,
          default: undefined,
        },
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
      notificationDevices: {
        type: [{ token: String, platform: String, updatedAt: String }],
        default: [],
      },
      gamificationTree: {
        xpNode: {
          totalXp: { type: Number, default: 0 },
          xpEvents: { type: [mongoose.Schema.Types.Mixed], default: [] },
          level: { type: Number, default: 1 },
          title: { type: String, default: 'Эхлэн уншигч (Lv. 1)' },
          weeklyLeague: { type: String, default: '' },
        },
        streakNode: {
          currentStreak: { type: Number, default: 0 },
          longestStreak: { type: Number, default: 0 },
          minutesReadToday: { type: Number, default: 0 },
          streakFreezeAvailable: { type: Boolean, default: true },
          historyDates: { type: [String], default: [] },
          lastActiveDate: { type: String, default: null },
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

  UserAccountTreeSchema.index(
    { 'authNode.provider': 1, 'authNode.providerSubject': 1 },
    { unique: true, partialFilterExpression: { 'authNode.providerSubject': { $type: 'string' } } }
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

function hashLegacyPassword(rawPassword) {
  return crypto.createHash('sha256').update(String(rawPassword)).digest('hex');
}

function createDefaultUserAccountTree({
  userId,
  email = null,
  phoneNumber = null,
  displayName = 'Уншигч',
  provider = 'email',
  providerSubject = null,
  passwordHash = null,
  emailVerified = false,
  phoneVerified = false,
}) {
  const cleanEmail = email ? String(email).trim().toLowerCase() : null;
  const resolvedId = userId || `usr_${crypto.randomUUID()}`;

  return {
    userId: resolvedId,
    ...(cleanEmail ? { email: cleanEmail } : {}),
    authNode: {
      passwordHash,
      provider,
      providerSubject,
      emailVerified,
      phoneVerified,
      lastLoginAt: new Date().toISOString(),
      verificationChallenge: null,
      refreshSessions: [],
    },
    profileNode: {
      displayName: displayName || 'Уншигч',
      ...(phoneNumber ? { phoneNumber } : {}),
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
    notificationDevices: [],
    gamificationTree: {
      xpNode: {
        totalXp: 0,
        xpEvents: [],
        level: 1,
        title: computeLevelTitle(0),
        weeklyLeague: '',
      },
      streakNode: {
        currentStreak: 0,
        longestStreak: 0,
        minutesReadToday: 0,
        streakFreezeAvailable: true,
        historyDates: [],
        lastActiveDate: null,
      },
      challengeNode: {
        year: new Date().getFullYear(),
        targetBooks: 24,
        completedBookIds: [],
        achievementsNodes: [
          {
            id: 'streak_7',
            title: '🔥 7 хоногийн цуврал',
            isUnlocked: false,
            progress: 0,
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
  hashLegacyPassword,
};
