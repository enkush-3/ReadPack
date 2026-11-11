'use strict';

const { computeLevel, computeLevelTitle } = require('../models/UserAccountTree');

class UserTreeService {
  constructor({ store, bookCatalogService }) {
    this.store = store;
    this.bookCatalogService = bookCatalogService;
  }

  getUserTree(userId) {
    return this.store.findUserTree(userId);
  }

  async updatePreferencesAndProfile(userId, payload = {}) {
    if (payload.xpDelta !== undefined || payload.gamificationTree !== undefined) {
      throw serviceError(400, 'server_managed_fields', 'Gamification fields are managed by the server.');
    }
    const tree = await this.#requireUserTree(userId);
    this.#updateProfile(tree, payload);
    this.#updatePreferences(tree, payload.preferencesNode || payload);
    return this.store.saveUserTree(tree);
  }

  async syncReadingNode(userId, payload = {}) {
    const tree = await this.#requireUserTree(userId);
    const centralBook = await this.#resolveBook(payload.book || payload.bookId);
    const reading = normalizeReadingProgress(payload);
    const shelf = getOrCreateShelf(tree, reading.shelfId);
    const bookNode = findOrCreateBookNode(shelf, centralBook, reading);
    bookNode.syncReadingEventIds = bookNode.syncReadingEventIds || [];
    if (reading.eventId && bookNode.syncReadingEventIds.includes(reading.eventId)) {
      return { centralBook, userAccountTree: tree };
    }
    updateBookNode(bookNode, reading, centralBook);
    attachHighlight(bookNode, reading.highlight, reading.currentChapter);
    attachNote(bookNode, reading.note);
    if (reading.eventId) bookNode.syncReadingEventIds.push(reading.eventId);
    updateCompletedBooks(tree, centralBook.id, reading, bookNode);

    const userAccountTree = await this.store.saveUserTree(tree);
    return { centralBook, userAccountTree };
  }

  async applyReadingRewards(userId, event) {
    const tree = await this.#requireUserTree(userId);
    const xpNode = tree.gamificationTree.xpNode;
    xpNode.xpEvents = xpNode.xpEvents || [];
    const previousEvent = xpNode.xpEvents.find((item) => item.eventId === event.eventId);
    if (previousEvent) return { tree, earnedXp: previousEvent.xp, duplicate: true };

    const earnedXp = event.minutes * 5;
    const createdAt = event.createdAt || new Date().toISOString();
    xpNode.xpEvents.push({
      eventId: event.eventId,
      xp: earnedXp,
      minutes: event.minutes,
      createdAt,
      payloadHash: event.payloadHash,
    });
    xpNode.totalXp = Number(xpNode.totalXp || 0) + earnedXp;
    xpNode.level = computeLevel(xpNode.totalXp);
    xpNode.title = computeLevelTitle(xpNode.totalXp);

    if (event.minutes > 0) {
      updateReadingStreak(
        tree,
        event.minutes,
        createdAt,
        event.timezoneOffsetMinutes || 0,
      );
    }
    return { tree: await this.store.saveUserTree(tree), earnedXp, duplicate: false };
  }

  async #requireUserTree(userId) {
    const tree = await this.store.findUserTree(userId);
    if (!tree) throw serviceError(404, 'user_not_found', 'User account was not found.');
    return tree;
  }

  async #resolveBook(book) {
    if (book && typeof book === 'object') {
      return this.bookCatalogService.syncBookToCentralCatalog(book);
    }
    if (typeof book !== 'string' || !book.trim()) {
    throw serviceError(400, 'book_required', 'A book object or bookId is required.');
    }
    const books = await this.store.getAllBooks();
    const found = books.find((item) => item.id === book.trim());
    if (!found) throw serviceError(404, 'book_not_found', 'Book was not found.');
    return found;
  }

  #updateProfile(tree, payload) {
    const displayName = payload.displayName ?? payload.name;
    if (displayName !== undefined) {
      const normalized = String(displayName).trim();
      if (!normalized || normalized.length > 80) throw serviceError(400, 'invalid_name', 'Name must be 1 to 80 characters.');
      tree.profileNode.displayName = normalized;
    }
    if (payload.bio !== undefined) {
      const bio = String(payload.bio).trim();
      if (bio.length > 300) throw serviceError(400, 'invalid_bio', 'Bio cannot exceed 300 characters.');
      tree.profileNode.bio = bio;
    }
  }

  #updatePreferences(tree, preferences) {
    const allowedLanguages = ['mn', 'en'];
    const allowedThemes = ['system', 'light', 'dark', 'sepia'];
    const current = tree.profileNode.preferencesNode;
    if (preferences.language !== undefined) {
      if (!allowedLanguages.includes(preferences.language)) throw serviceError(400, 'invalid_language', 'Language must be mn or en.');
      current.language = preferences.language;
    }
    if (preferences.theme !== undefined) {
      if (!allowedThemes.includes(preferences.theme)) throw serviceError(400, 'invalid_theme', 'Theme is invalid.');
      current.theme = preferences.theme;
    }
    setBoundedNumber(current, preferences, 'dailyGoalMinutes', 1, 720);
    setBoundedNumber(current, preferences, 'yearlyBookGoal', 1, 500);
    if (Array.isArray(preferences.favoriteGenres)) {
      current.favoriteGenres = preferences.favoriteGenres.slice(0, 20).map(String);
    }
    setBoolean(current, preferences, 'notificationsEnabled');
    setBoolean(current, preferences, 'recommendationsEnabled');
  }
}

function normalizeReadingProgress(payload) {
  const progress = Number(payload.progress ?? 0);
  if (!Number.isFinite(progress) || progress < 0 || progress > 1) {
      throw serviceError(400, 'invalid_progress', 'Progress must be between 0 and 1.');
  }
  return {
    shelfId: String(payload.shelfId || 'currently_reading').slice(0, 80),
    status: ['reading', 'saved', 'completed', 'challenge'].includes(payload.status)
      ? payload.status
      : 'reading',
    progress,
    currentChapter: nonNegativeInteger(payload.currentChapter, 'currentChapter'),
    currentPage: nonNegativeInteger(payload.currentPage, 'currentPage'),
    highlight: payload.highlight,
    note: payload.note,
    eventId: payload.eventId ? String(payload.eventId) : null,
  };
}

function nonNegativeInteger(value, name) {
  const number = Number(value || 0);
  if (!Number.isInteger(number) || number < 0) throw serviceError(400, 'invalid_progress', `${name} must be a non-negative integer.`);
  return number;
}

function getOrCreateShelf(tree, shelfId) {
  tree.readingTree.shelves = tree.readingTree.shelves || [];
  let shelf = tree.readingTree.shelves.find((item) => item.shelfId === shelfId);
  if (!shelf) {
    shelf = { shelfId, name: shelfId, childrenBooks: [] };
    tree.readingTree.shelves.push(shelf);
  }
  return shelf;
}

function findOrCreateBookNode(shelf, book, reading) {
  let node = shelf.childrenBooks.find((item) => item.bookId === book.id);
  if (!node) {
    node = {
      bookId: book.id,
      title: book.title,
      author: book.author,
      status: reading.status,
      progress: reading.progress,
      currentChapter: reading.currentChapter,
      currentPage: reading.currentPage,
      updatedAt: new Date().toISOString(),
      highlightsNodes: [],
      notesNodes: [],
    };
    shelf.childrenBooks.push(node);
  }
  return node;
}

function updateBookNode(node, reading, book) {
  node.title = book.title || node.title;
  node.author = book.author || node.author;
  node.status = reading.progress >= 1 ? 'completed' : reading.status;
  node.progress = reading.progress;
  node.currentChapter = reading.currentChapter;
  node.currentPage = reading.currentPage;
  node.updatedAt = new Date().toISOString();
}

function attachHighlight(bookNode, highlight, currentChapter) {
  if (!highlight?.text) return;
  bookNode.highlightsNodes.push({
    highlightId: highlight.highlightId || `hl_${cryptoId()}`,
    chapterIndex: Number(highlight.chapterIndex ?? currentChapter),
    text: String(highlight.text).slice(0, 5000),
    color: String(highlight.color || 'yellow'),
    createdAt: new Date().toISOString(),
  });
}

function attachNote(bookNode, note) {
  if (!note?.content) return;
  bookNode.notesNodes.push({
    noteId: note.noteId || `nt_${cryptoId()}`,
    content: String(note.content).slice(0, 5000),
    createdAt: new Date().toISOString(),
  });
}

function updateCompletedBooks(tree, bookId, reading, bookNode) {
  const isComplete = reading.progress >= 1 || reading.status === 'completed' || reading.shelfId === 'challenge_2026';
  if (!isComplete) return;
  const challenge = tree.gamificationTree.challengeNode;
  challenge.completedBookIds = challenge.completedBookIds || [];
  if (!challenge.completedBookIds.includes(bookId)) challenge.completedBookIds.push(bookId);
  if (bookNode.status !== 'completed' || reading.shelfId === 'completed') return;

  const completedShelf = getOrCreateShelf(tree, 'completed');
  if (!completedShelf.childrenBooks.some((item) => item.bookId === bookId)) {
    completedShelf.childrenBooks.push(structuredClone(bookNode));
  }
}

function updateReadingStreak(tree, minutes, createdAt, timezoneOffsetMinutes = 0) {
  const streak = tree.gamificationTree.streakNode;
  const dateKey = new Date(
    new Date(createdAt).getTime() + timezoneOffsetMinutes * 60 * 1000,
  ).toISOString().slice(0, 10);
  const previousDate = streak.lastActiveDate;
  if (previousDate !== dateKey) {
    const yesterday = new Date(`${dateKey}T00:00:00.000Z`);
    yesterday.setUTCDate(yesterday.getUTCDate() - 1);
    streak.currentStreak = previousDate === yesterday.toISOString().slice(0, 10)
      ? Number(streak.currentStreak || 0) + 1
      : 1;
    streak.longestStreak = Math.max(Number(streak.longestStreak || 0), streak.currentStreak);
    streak.lastActiveDate = dateKey;
    streak.historyDates = [...new Set([...(streak.historyDates || []), dateKey])];
    streak.minutesReadToday = 0;
  }
  streak.minutesReadToday = Number(streak.minutesReadToday || 0) + minutes;
}

function setBoundedNumber(target, source, key, minimum, maximum) {
  if (source[key] === undefined) return;
  const value = Number(source[key]);
  if (!Number.isInteger(value) || value < minimum || value > maximum) {
    throw serviceError(400, 'invalid_preference', `${key} must be an integer from ${minimum} to ${maximum}.`);
  }
  target[key] = value;
}

function setBoolean(target, source, key) {
  if (source[key] !== undefined) target[key] = Boolean(source[key]);
}

function cryptoId() {
  return require('crypto').randomUUID();
}

function serviceError(statusCode, code, message) {
  return Object.assign(new Error(message), { statusCode, code });
}

module.exports = { UserTreeService };
