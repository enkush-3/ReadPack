'use strict';

const fs = require('fs');
const path = require('path');
const { getInitialCentralBooks, registerMongooseCentralBookModel } = require('../models/CentralBook');
const {
  registerMongooseUserTreeModel,
} = require('../models/UserAccountTree');
const { registerMongooseReadingEventModel } = require('../models/ReadingEvent');

/**
 * Dual-Mode MongoDB Storage Engine:
 * - Connects to a live MongoDB instance (`MONGODB_URI`) via Mongoose when available.
 * - Uses a file-backed document store in non-production only when explicitly enabled.
 */
class MongoStore {
  constructor({ storageFilePath } = {}) {
    this.mode = 'document_tree_store';
    this.UserModel = null;
    this.BookModel = null;
    this.ReadingEventModel = null;
    this.storageFilePath =
      storageFilePath ||
      path.join(__dirname, '..', '..', 'data', 'mongodb_fallback_store.json');

    this.state = {
      books: [],
      users: [],
      readingEvents: [],
    };
    this.userLocks = new Map();
    this._initialized = false;
  }

  async init({ mongoUri, forceFallback = false, environment = process.env } = {}) {
    if (this._initialized) return;
    const settings = this._storageSettings({
      mongoUri,
      forceFallback,
      environment,
    });
    this._assertStorageSettings(settings);
    if (settings.mongoUri && !settings.forceFallback) {
      await this._initializeMongoOrFallback(settings);
      return;
    }
    this._initializeJsonFallback(settings.allowJsonFallback);
  }

  async _initializeMongoOrFallback(settings) {
    try {
      await this._connectMongo(settings.mongoUri);
    } catch (error) {
      if (!settings.allowJsonFallback) {
        throw new Error('MongoDB connection failed; JSON fallback is disabled', {
          cause: error,
        });
      }
      this._initializeJsonFallback(settings.allowJsonFallback);
    }
  }

  _storageSettings({ mongoUri, forceFallback, environment }) {
    const isProduction = environment.NODE_ENV === 'production';
    return {
      mongoUri: mongoUri ?? environment.MONGODB_URI,
      forceFallback,
      allowJsonFallback:
        !isProduction &&
        (forceFallback || environment.ALLOW_JSON_FALLBACK === 'true'),
      isProduction,
    };
  }

  _assertStorageSettings(settings) {
    if (settings.isProduction && settings.forceFallback) {
      throw new Error('JSON fallback storage is disabled in production');
    }
    if (!settings.mongoUri && !settings.allowJsonFallback) {
      throw new Error(
        'MONGODB_URI is required unless JSON fallback is explicitly enabled outside production',
      );
    }
  }

  async _connectMongo(mongoUri) {
    const mongoose = require('mongoose');
    await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 1500 });
    const userModel = registerMongooseUserTreeModel(mongoose);
    const bookModel = registerMongooseCentralBookModel(mongoose);
    const readingEventModel = registerMongooseReadingEventModel(mongoose);
    if ((await bookModel.countDocuments()) === 0) {
      await bookModel.insertMany(getInitialCentralBooks());
    }
    this.UserModel = userModel;
    this.BookModel = bookModel;
    this.ReadingEventModel = readingEventModel;
    this.mode = 'mongodb_mongoose';
    this._initialized = true;
  }

  _initializeJsonFallback(allowJsonFallback) {
    if (!allowJsonFallback) {
      throw new Error('JSON fallback storage is not enabled');
    }
    this._loadFromDisk();
    this._initialized = true;
  }

  _loadFromDisk() {
    if (fs.existsSync(this.storageFilePath)) {
      const serializedState = fs.readFileSync(this.storageFilePath, 'utf8');
      const parsedState = JSON.parse(serializedState);
      if (
        !parsedState ||
        typeof parsedState !== 'object' ||
        Array.isArray(parsedState) ||
        !Array.isArray(parsedState.books) ||
        !Array.isArray(parsedState.users) ||
        (parsedState.readingEvents !== undefined &&
          !Array.isArray(parsedState.readingEvents))
      ) {
        throw new Error(`Fallback store has an invalid structure: ${this.storageFilePath}`);
      }
      this.state = {
        ...parsedState,
        readingEvents: parsedState.readingEvents || [],
      };
      return;
    }

    this.state = { books: getInitialCentralBooks(), users: [], readingEvents: [] };
    this._persistToDisk(this.state);
  }

  _persistToDisk(nextState) {
    const directory = path.dirname(this.storageFilePath);
    fs.mkdirSync(directory, { recursive: true });
    const temporaryFilePath = `${this.storageFilePath}.tmp.${process.pid}.${Date.now()}_${Math.random()
      .toString(36)
      .slice(2, 8)}`;

    try {
      fs.writeFileSync(temporaryFilePath, JSON.stringify(nextState, null, 2), {
        encoding: 'utf8',
        mode: 0o600,
        flag: 'wx',
      });
      fs.renameSync(temporaryFilePath, this.storageFilePath);
    } catch (error) {
      fs.rmSync(temporaryFilePath, { force: true });
      throw error;
    }
  }

  async getAllBooks() {
    if (this.mode === 'mongodb_mongoose' && this.BookModel) {
      return await this.BookModel.find({}).lean();
    }
    return structuredClone(this.state.books);
  }

  async upsertBook(bookDoc) {
    if (this.mode === 'mongodb_mongoose' && this.BookModel) {
      return this._upsertMongoBook(bookDoc);
    }

    return this._upsertFallbackBook(bookDoc);
  }

  async _upsertMongoBook(bookDoc) {
    const match = this._bookMatch(bookDoc);
    const existingBook = await this.BookModel.findOne(match).lean();
    const mergedBook = existingBook
      ? this._mergeBook(existingBook, bookDoc)
      : this._createBook(bookDoc);
    delete mergedBook._id;
    delete mergedBook.__v;
    return this.BookModel.findOneAndUpdate(
      match,
      { $set: mergedBook },
      { upsert: true, new: true, lean: true }
    );
  }

  _bookMatch(bookDoc) {
    return {
      $or: [
        { id: bookDoc.id },
        ...(bookDoc.externalId ? [{ externalId: bookDoc.externalId }] : []),
        {
          normalizedTitle: bookDoc.normalizedTitle,
          normalizedAuthor: bookDoc.normalizedAuthor,
        },
      ],
    };
  }

  _upsertFallbackBook(bookDoc) {
    const nextState = structuredClone(this.state);
    const bookIndex = this._findMatchingBookIndex(nextState.books, bookDoc);
    const savedBook =
      bookIndex >= 0
        ? this._mergeBook(nextState.books[bookIndex], bookDoc)
        : this._createBook(bookDoc);

    if (bookIndex >= 0) {
      nextState.books[bookIndex] = savedBook;
    } else {
      nextState.books.push(savedBook);
    }

    this._persistToDisk(nextState);
    this.state = nextState;
    return structuredClone(savedBook);
  }

  _findMatchingBookIndex(books, bookDoc) {
    return books.findIndex(
      (book) =>
        book.id === bookDoc.id ||
        (bookDoc.externalId && book.externalId === bookDoc.externalId) ||
        (book.normalizedTitle === bookDoc.normalizedTitle &&
          book.normalizedAuthor === bookDoc.normalizedAuthor)
    );
  }

  _mergeBook(existingBook, incomingBook) {
    const existingCatalog = this._withoutUserReadingState(existingBook);
    const incomingCatalog = this._withoutUserReadingState(incomingBook);
    return structuredClone({
      ...existingCatalog,
      ...this._mergeCatalogFields(existingCatalog, incomingCatalog),
      id: existingBook.id,
      updatedAt: new Date().toISOString(),
    });
  }

  _mergeCatalogFields(existingBook, incomingBook) {
    const mergedBook = { ...incomingBook };
    for (const [field, value] of Object.entries(incomingBook)) {
      if (
        this._isUnknownCatalogValue(field, value) &&
        existingBook[field] != null
      ) {
        mergedBook[field] = existingBook[field];
      }
    }
    return mergedBook;
  }

  _isUnknownCatalogValue(field, value) {
    return (
      value == null ||
      value === '' ||
      value === false ||
      value === 0 ||
      (Array.isArray(value) && value.length === 0) ||
      (field === 'category' && value === 'book.categories.all') ||
      (field === 'colorHex' && value === 0xff2c3e50)
    );
  }

  _withoutUserReadingState(book) {
    const catalogBook = { ...book };
    delete catalogBook.progress;
    delete catalogBook.currentPage;
    delete catalogBook.currentChapterIndex;
    delete catalogBook.isSaved;
    delete catalogBook.isFavorite;
    return catalogBook;
  }

  _createBook(bookDoc) {
    const createdAt = new Date().toISOString();
    return structuredClone({
      ...this._withoutUserReadingState(bookDoc),
      createdAt,
      updatedAt: createdAt,
    });
  }

  async findUserTree(userIdOrEmail) {
    const key = String(userIdOrEmail || '').trim().toLowerCase();
    if (!key) return null;
    if (this.mode === 'mongodb_mongoose' && this.UserModel) {
      return await this.UserModel.findOne({
        $or: [{ userId: userIdOrEmail }, { email: key }],
      }).lean();
    }

    const found =
      this.state.users.find(
        (u) =>
          u.userId === userIdOrEmail ||
          (u.email && u.email.toLowerCase() === key) ||
          (u.profileNode?.phoneNumber && u.profileNode.phoneNumber === userIdOrEmail)
      ) || null;
    return found ? structuredClone(found) : null;
  }

  async findUserTreeByContact(contact, contactType) {
    const normalized = String(contact || '').trim().toLowerCase();
    if (!normalized) return null;
    if (this.mode === 'mongodb_mongoose' && this.UserModel) {
      const query = contactType === 'phone'
        ? { 'profileNode.phoneNumber': String(contact).trim() }
        : { email: normalized };
      return await this.UserModel.findOne(query).lean();
    }
    const found = this.state.users.find((tree) =>
      contactType === 'phone'
        ? tree.profileNode?.phoneNumber === String(contact).trim()
        : tree.email === normalized
    );
    return found ? structuredClone(found) : null;
  }

  async findUserTreeByProvider(provider, providerSubject) {
    if (!provider || !providerSubject) return null;
    if (this.mode === 'mongodb_mongoose' && this.UserModel) {
      return await this.UserModel.findOne({
        'authNode.provider': provider,
        'authNode.providerSubject': providerSubject,
      }).lean();
    }
    const found = this.state.users.find(
      (tree) =>
        tree.authNode?.provider === provider &&
        tree.authNode?.providerSubject === providerSubject
    );
    return found ? structuredClone(found) : null;
  }

  async findUserTreeByChallenge(challengeId) {
    if (!challengeId) return null;
    if (this.mode === 'mongodb_mongoose' && this.UserModel) {
      return await this.UserModel.findOne({
        'authNode.verificationChallenge.challengeId': challengeId,
      }).lean();
    }
    const found = this.state.users.find(
      (tree) => tree.authNode?.verificationChallenge?.challengeId === challengeId
    );
    return found ? structuredClone(found) : null;
  }

  async getAllUserTrees() {
    if (this.mode === 'mongodb_mongoose' && this.UserModel) {
      return await this.UserModel.find({}).lean();
    }
    return structuredClone(this.state.users);
  }

  async removeNotificationTokenFromOtherUsers(userId, token) {
    if (this.mode === 'mongodb_mongoose' && this.UserModel) {
      await this.UserModel.updateMany(
        { userId: { $ne: userId }, 'notificationDevices.token': token },
        { $pull: { notificationDevices: { token } } }
      );
      return;
    }
    const nextState = structuredClone(this.state);
    for (const tree of nextState.users) {
      if (tree.userId === userId) continue;
      tree.notificationDevices = (tree.notificationDevices || []).filter(
        (device) => device.token !== token
      );
    }
    this._persistToDisk(nextState);
    this.state = nextState;
  }

  async findReadingEvent(userId, eventId) {
    if (this.mode === 'mongodb_mongoose' && this.ReadingEventModel) {
      return this.ReadingEventModel.findOne({ userId, eventId }).lean();
    }
    const event = this.state.readingEvents.find(
      (item) => item.userId === userId && item.eventId === eventId
    );
    return event ? structuredClone(event) : null;
  }

  async createReadingEvent(event) {
    if (this.mode === 'mongodb_mongoose' && this.ReadingEventModel) {
      try {
        const created = await this.ReadingEventModel.create(event);
        return { created: true, event: created.toObject() };
      } catch (error) {
        if (error.code !== 11000) throw error;
        return { created: false, event: await this.findReadingEvent(event.userId, event.eventId) };
      }
    }

    const existing = await this.findReadingEvent(event.userId, event.eventId);
    if (existing) return { created: false, event: existing };
    const nextState = structuredClone(this.state);
    nextState.readingEvents.push(structuredClone(event));
    this._persistToDisk(nextState);
    this.state = nextState;
    return { created: true, event: structuredClone(event) };
  }

  async completeReadingEvent(userId, eventId, { xp, createdAt }) {
    const completedAt = new Date().toISOString();
    if (this.mode === 'mongodb_mongoose' && this.ReadingEventModel) {
      return this.ReadingEventModel.findOneAndUpdate(
        { userId, eventId },
        { $set: { xp, status: 'complete', createdAt, completedAt } },
        { new: true, lean: true }
      );
    }
    const nextState = structuredClone(this.state);
    const event = nextState.readingEvents.find(
      (item) => item.userId === userId && item.eventId === eventId
    );
    if (!event) return null;
    Object.assign(event, { xp, status: 'complete', createdAt, completedAt });
    this._persistToDisk(nextState);
    this.state = nextState;
    return structuredClone(event);
  }

  async getReadingEventsSince(timestamp) {
    const createdAt = new Date(timestamp);
    if (this.mode === 'mongodb_mongoose' && this.ReadingEventModel) {
      return this.ReadingEventModel.find({ status: 'complete', createdAt: { $gte: createdAt } }).lean();
    }
    return structuredClone(
      this.state.readingEvents.filter(
        (event) => event.status === 'complete' && Date.parse(event.createdAt) >= timestamp
      )
    );
  }

  async withUserLock(userId, operation) {
    const previous = this.userLocks.get(userId) || Promise.resolve();
    let release;
    const current = new Promise((resolve) => { release = resolve; });
    const tail = previous.then(() => current);
    this.userLocks.set(userId, tail);
    await previous;
    try {
      return await operation();
    } finally {
      release();
      if (this.userLocks.get(userId) === tail) this.userLocks.delete(userId);
    }
  }

  async saveUserTree(userTreeDoc) {
    userTreeDoc.updatedAt = new Date().toISOString();
    if (this.mode === 'mongodb_mongoose' && this.UserModel) {
      return this._saveMongoUserTree(userTreeDoc);
    }

    return this._saveFallbackUserTree(userTreeDoc);
  }

  _saveMongoUserTree(userTreeDoc) {
    return this.UserModel.findOneAndUpdate(
      { userId: userTreeDoc.userId },
      { $set: userTreeDoc },
      { upsert: true, new: true, lean: true }
    );
  }

  _saveFallbackUserTree(userTreeDoc) {
    const cloned = structuredClone(userTreeDoc);
    const nextState = structuredClone(this.state);
    const userIndex = nextState.users.findIndex(
      (u) =>
        u.userId === cloned.userId ||
        (cloned.email && u.email?.toLowerCase() === cloned.email.toLowerCase()) ||
        (cloned.profileNode?.phoneNumber &&
          u.profileNode?.phoneNumber === cloned.profileNode.phoneNumber)
    );
    if (userIndex >= 0) {
      nextState.users[userIndex] = cloned;
    } else {
      nextState.users.push(cloned);
    }
    this._persistToDisk(nextState);
    this.state = nextState;
    return structuredClone(cloned);
  }
}

module.exports = { MongoStore };
