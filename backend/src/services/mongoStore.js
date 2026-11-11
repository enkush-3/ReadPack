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
 * - Automatically falls back to a file-backed MongoDB document & tree store
 *   (`backend/data/mongodb_fallback_store.json`) when no local `mongod` daemon is running,
 *   guaranteeing 100% deterministic execution in local dev, CI, and offline environments.
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

  async init({ mongoUri = process.env.MONGODB_URI, forceFallback = false } = {}) {
    if (this._initialized) return;

    if (mongoUri && !forceFallback) {
      try {
        // Attempt live Mongoose connection if mongoose is installed and mongod is reachable
        const mongoose = require('mongoose');
        await mongoose.connect(mongoUri, {
          serverSelectionTimeoutMS: 1500,
        });
        this.UserModel = registerMongooseUserTreeModel(mongoose);
        this.BookModel = registerMongooseCentralBookModel(mongoose);
        this.ReadingEventModel = registerMongooseReadingEventModel(mongoose);
        this.mode = 'mongodb_mongoose';

        const count = await this.BookModel.countDocuments();
        if (count === 0) {
          await this.BookModel.insertMany(getInitialCentralBooks());
        }
        this._initialized = true;
        return;
      } catch (_) {
        // Fallback to local MongoDB JSON document store when mongod is not running
      }
    }

    this._loadFromDisk();
    this._initialized = true;
  }

  _loadFromDisk() {
    try {
      if (fs.existsSync(this.storageFilePath)) {
        const raw = fs.readFileSync(this.storageFilePath, 'utf8');
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed.books) && Array.isArray(parsed.users)) {
          this.state = { ...parsed, readingEvents: parsed.readingEvents || [] };
          return;
        }
      }
    } catch (_) {}

    this.state = { books: getInitialCentralBooks(), users: [], readingEvents: [] };
    this._persistToDisk();
  }

  _persistToDisk() {
    try {
      const dir = path.dirname(this.storageFilePath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      const tmpPath = `${this.storageFilePath}.tmp.${process.pid}.${Date.now()}_${Math.random()
        .toString(36)
        .slice(2, 8)}`;
      fs.writeFileSync(tmpPath, JSON.stringify(this.state, null, 2), 'utf8');
      fs.renameSync(tmpPath, this.storageFilePath);
    } catch (_) {}
  }

  async getAllBooks() {
    if (this.mode === 'mongodb_mongoose' && this.BookModel) {
      return await this.BookModel.find({}).lean();
    }
    return structuredClone(this.state.books);
  }

  async upsertBook(bookDoc) {
    if (this.mode === 'mongodb_mongoose' && this.BookModel) {
      const updated = await this.BookModel.findOneAndUpdate(
        {
          $or: [
            { id: bookDoc.id },
            ...(bookDoc.externalId ? [{ externalId: bookDoc.externalId }] : []),
            {
              normalizedTitle: bookDoc.normalizedTitle,
              normalizedAuthor: bookDoc.normalizedAuthor,
            },
          ],
        },
        { $set: bookDoc },
        { upsert: true, new: true, lean: true }
      );
      return updated;
    }

    const idx = this.state.books.findIndex(
      (b) =>
        b.id === bookDoc.id ||
        (bookDoc.externalId && b.externalId === bookDoc.externalId) ||
        (b.normalizedTitle === bookDoc.normalizedTitle &&
          b.normalizedAuthor === bookDoc.normalizedAuthor)
    );

    if (idx >= 0) {
      this.state.books[idx] = structuredClone({
        ...this.state.books[idx],
        ...bookDoc,
        id: this.state.books[idx].id,
        updatedAt: new Date().toISOString(),
      });
      this._persistToDisk();
      return structuredClone(this.state.books[idx]);
    }

    const inserted = structuredClone({
      ...bookDoc,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });
    this.state.books.push(inserted);
    this._persistToDisk();
    return structuredClone(inserted);
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
    for (const tree of this.state.users) {
      if (tree.userId === userId) continue;
      tree.notificationDevices = (tree.notificationDevices || []).filter(
        (device) => device.token !== token
      );
    }
    this._persistToDisk();
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
    this.state.readingEvents.push(structuredClone(event));
    this._persistToDisk();
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
    const event = this.state.readingEvents.find(
      (item) => item.userId === userId && item.eventId === eventId
    );
    if (!event) return null;
    Object.assign(event, { xp, status: 'complete', createdAt, completedAt });
    this._persistToDisk();
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
      return await this.UserModel.findOneAndUpdate(
        { userId: userTreeDoc.userId },
        { $set: userTreeDoc },
        { upsert: true, new: true, lean: true }
      );
    }

    const cloned = structuredClone(userTreeDoc);
    const idx = this.state.users.findIndex(
      (u) =>
        u.userId === cloned.userId ||
        (cloned.email && u.email?.toLowerCase() === cloned.email.toLowerCase()) ||
        (cloned.profileNode?.phoneNumber &&
          u.profileNode?.phoneNumber === cloned.profileNode.phoneNumber)
    );
    if (idx >= 0) {
      this.state.users[idx] = cloned;
    } else {
      this.state.users.push(cloned);
    }
    this._persistToDisk();
    return structuredClone(cloned);
  }
}

module.exports = { MongoStore };
