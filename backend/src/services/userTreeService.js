'use strict';

const {
  createDefaultUserAccountTree,
  computeLevel,
  computeLevelTitle,
  hashPassword,
} = require('../models/UserAccountTree');

/**
 * Service managing the MongoDB Hierarchical User Account Tree (`UserAccountTree`)
 * and synchronizing user reading progress, shelves, highlights, notes, and gamification
 * with the Central Books Catalog.
 */
class UserTreeService {
  constructor({ store, bookCatalogService }) {
    this.store = store;
    this.bookCatalogService = bookCatalogService;
  }

  async loginOrRegister({ email, name, password = 'readpack123', provider = 'email' }) {
    const cleanEmail = String(email || '').trim().toLowerCase();
    if (!cleanEmail || !cleanEmail.includes('@')) {
      throw new Error('Valid email is required');
    }

    let userTree = await this.store.findUserTree(cleanEmail);
    if (!userTree) {
      userTree = createDefaultUserAccountTree({
        email: cleanEmail,
        displayName: name || cleanEmail.split('@')[0],
        password,
        provider,
      });
    } else {
      userTree.authNode = {
        ...userTree.authNode,
        provider: provider || userTree.authNode?.provider || 'email',
        lastLoginAt: new Date().toISOString(),
      };
      if (name && name.trim()) {
        userTree.profileNode.displayName = name.trim();
      }
    }

    return await this.store.saveUserTree(userTree);
  }

  async getUserTree(userIdOrEmail) {
    let userTree = await this.store.findUserTree(userIdOrEmail);
    if (!userTree && String(userIdOrEmail).includes('@')) {
      userTree = createDefaultUserAccountTree({
        email: userIdOrEmail,
        displayName: String(userIdOrEmail).split('@')[0],
      });
      userTree = await this.store.saveUserTree(userTree);
    }
    return userTree;
  }

  async updatePreferencesAndProfile(userIdOrEmail, payload = {}) {
    let userTree = await this.getUserTree(userIdOrEmail);
    if (!userTree) {
      throw new Error('User account tree not found');
    }

    if (payload.displayName || payload.name) {
      userTree.profileNode.displayName = String(
        payload.displayName || payload.name
      ).trim();
    }
    if (payload.bio !== undefined) {
      userTree.profileNode.bio = String(payload.bio);
    }
    if (payload.preferencesNode || payload.dailyGoalMinutes || payload.yearlyBookGoal) {
      const prefs = payload.preferencesNode || payload;
      userTree.profileNode.preferencesNode = {
        ...userTree.profileNode.preferencesNode,
        ...(prefs.language ? { language: prefs.language } : {}),
        ...(prefs.theme ? { theme: prefs.theme } : {}),
        ...(prefs.dailyGoalMinutes !== undefined
          ? { dailyGoalMinutes: Number(prefs.dailyGoalMinutes) }
          : {}),
        ...(prefs.yearlyBookGoal !== undefined
          ? { yearlyBookGoal: Number(prefs.yearlyBookGoal) }
          : {}),
        ...(Array.isArray(prefs.favoriteGenres)
          ? { favoriteGenres: prefs.favoriteGenres }
          : {}),
        ...(prefs.notificationsEnabled !== undefined
          ? { notificationsEnabled: Boolean(prefs.notificationsEnabled) }
          : {}),
        ...(prefs.recommendationsEnabled !== undefined
          ? { recommendationsEnabled: Boolean(prefs.recommendationsEnabled) }
          : {}),
      };
    }

    if (payload.xpDelta && Number(payload.xpDelta) > 0) {
      const newXp =
        Number(userTree.gamificationTree.xpNode.totalXp || 0) +
        Number(payload.xpDelta);
      userTree.gamificationTree.xpNode.totalXp = newXp;
      userTree.gamificationTree.xpNode.level = computeLevel(newXp);
      userTree.gamificationTree.xpNode.title = computeLevelTitle(newXp);
    }

    return await this.store.saveUserTree(userTree);
  }

  /**
   * Synchronizes a book interaction (reading progress, save to shelf, reading challenge,
   * highlight, or note) into BOTH:
   * 1. Central Books Collection (`books`) via On-Demand Upsert.
   * 2. User's Hierarchical `readingTree` & `gamificationTree` in MongoDB.
   */
  async syncReadingNode(
    userIdOrEmail,
    {
      book,
      shelfId = 'currently_reading',
      status = 'reading',
      progress = 0.0,
      currentChapter = 0,
      currentPage = 0,
      highlight = null,
      note = null,
      minutesRead = 0,
    } = {}
  ) {
    let userTree = await this.getUserTree(userIdOrEmail);
    if (!userTree) {
      userTree = createDefaultUserAccountTree({
        userId: String(userIdOrEmail).startsWith('usr_')
          ? userIdOrEmail
          : undefined,
        email: String(userIdOrEmail).includes('@')
          ? userIdOrEmail
          : `${userIdOrEmail}@readpack.app`,
        displayName: 'Уншигч',
      });
    }

    // Step 1: Upsert the book into the Central Books Catalog so future searches hit central_db!
    let centralBook = null;
    if (book && typeof book === 'object') {
      centralBook = await this.bookCatalogService.syncBookToCentralCatalog(book);
    } else if (typeof book === 'string') {
      const all = await this.store.getAllBooks();
      centralBook = all.find((b) => b.id === book) || {
        id: book,
        title: 'Synced Book',
        author: 'Unknown Author',
      };
    } else {
      throw new Error('Book object or bookId is required to sync reading node');
    }

    // Step 2: Locate or create target shelf node in readingTree.shelves
    if (!userTree.readingTree || !Array.isArray(userTree.readingTree.shelves)) {
      userTree.readingTree = { shelves: [] };
    }
    let shelf = userTree.readingTree.shelves.find((s) => s.shelfId === shelfId);
    if (!shelf) {
      shelf = {
        shelfId,
        name: shelfId,
        childrenBooks: [],
      };
      userTree.readingTree.shelves.push(shelf);
    }

    // Step 3: Upsert child book node inside shelf.childrenBooks
    const numericProgress = Number(progress ?? 0);
    const effectiveStatus =
      numericProgress >= 1.0 ? 'completed' : status || 'reading';

    let bookNode = shelf.childrenBooks.find((b) => b.bookId === centralBook.id);
    if (!bookNode) {
      bookNode = {
        bookId: centralBook.id,
        title: centralBook.title,
        author: centralBook.author,
        status: effectiveStatus,
        progress: numericProgress,
        currentChapter: Number(currentChapter || 0),
        currentPage: Number(currentPage || 0),
        updatedAt: new Date().toISOString(),
        highlightsNodes: [],
        notesNodes: [],
      };
      shelf.childrenBooks.push(bookNode);
    } else {
      bookNode.title = centralBook.title || bookNode.title;
      bookNode.author = centralBook.author || bookNode.author;
      bookNode.status = effectiveStatus || bookNode.status;
      bookNode.progress =
        progress !== undefined ? numericProgress : bookNode.progress;
      bookNode.currentChapter =
        currentChapter !== undefined
          ? Number(currentChapter)
          : bookNode.currentChapter;
      bookNode.currentPage =
        currentPage !== undefined ? Number(currentPage) : bookNode.currentPage;
      bookNode.updatedAt = new Date().toISOString();
    }

    // Attach highlight node if provided
    if (highlight && highlight.text) {
      bookNode.highlightsNodes.push({
        highlightId: highlight.highlightId || `hl_${Date.now()}`,
        chapterIndex: Number(highlight.chapterIndex || currentChapter || 0),
        text: String(highlight.text),
        color: highlight.color || 'yellow',
        createdAt: new Date().toISOString(),
      });
    }

    // Attach note node if provided
    if (note && note.content) {
      bookNode.notesNodes.push({
        noteId: note.noteId || `nt_${Date.now()}`,
        content: String(note.content),
        createdAt: new Date().toISOString(),
      });
    }

    // Step 4: Update gamificationTree nodes
    const earnedXp = Math.max(15, Number(minutesRead || 0) * 5);
    const totalXp =
      Number(userTree.gamificationTree.xpNode.totalXp || 0) + earnedXp;
    userTree.gamificationTree.xpNode.totalXp = totalXp;
    userTree.gamificationTree.xpNode.level = computeLevel(totalXp);
    userTree.gamificationTree.xpNode.title = computeLevelTitle(totalXp);

    if (minutesRead > 0) {
      userTree.gamificationTree.streakNode.minutesReadToday =
        Number(userTree.gamificationTree.streakNode.minutesReadToday || 0) +
        Number(minutesRead);
      const todayIso = new Date().toISOString().slice(0, 10);
      if (
        !userTree.gamificationTree.streakNode.historyDates.includes(todayIso)
      ) {
        userTree.gamificationTree.streakNode.historyDates.push(todayIso);
        const nextStreak =
          Number(userTree.gamificationTree.streakNode.currentStreak || 0) + 1;
        userTree.gamificationTree.streakNode.currentStreak = nextStreak;
        userTree.gamificationTree.streakNode.longestStreak = Math.max(
          Number(userTree.gamificationTree.streakNode.longestStreak || 0),
          nextStreak
        );
      }
    }

    if (
      effectiveStatus === 'completed' ||
      numericProgress >= 1.0 ||
      shelfId === 'challenge_2026'
    ) {
      const completedIds =
        userTree.gamificationTree.challengeNode.completedBookIds || [];
      if (!completedIds.includes(centralBook.id)) {
        completedIds.push(centralBook.id);
      }
      userTree.gamificationTree.challengeNode.completedBookIds = completedIds;

      if (effectiveStatus === 'completed' && shelfId !== 'completed') {
        let completedShelf = userTree.readingTree.shelves.find(
          (s) => s.shelfId === 'completed'
        );
        if (!completedShelf) {
          completedShelf = {
            shelfId: 'completed',
            name: 'Уншиж дууссан',
            childrenBooks: [],
          };
          userTree.readingTree.shelves.push(completedShelf);
        }
        if (
          !completedShelf.childrenBooks.some((b) => b.bookId === centralBook.id)
        ) {
          completedShelf.childrenBooks.push({ ...bookNode });
        }
      }
    }

    const savedTree = await this.store.saveUserTree(userTree);
    return {
      centralBook,
      userAccountTree: savedTree,
    };
  }
}

module.exports = { UserTreeService };
