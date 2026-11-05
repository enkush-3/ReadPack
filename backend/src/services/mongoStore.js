'use strict';

const fs = require('fs');
const path = require('path');
const { getInitialCentralBooks, registerMongooseCentralBookModel } = require('../models/CentralBook');
const {
  createDefaultUserAccountTree,
  registerMongooseUserTreeModel,
} = require('../models/UserAccountTree');

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
    this.storageFilePath =
      storageFilePath ||
      path.join(__dirname, '..', '..', 'data', 'mongodb_fallback_store.json');

    this.state = {
      books: [],
      users: [],
    };
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
        this.mode = 'mongodb_mongoose';

        const count = await this.BookModel.countDocuments();
        if (count === 0) {
          await this.BookModel.insertMany(getInitialCentralBooks());
        }
        const userCount = await this.UserModel.countDocuments({
          email: 'enkush@readpack.app',
        });
        if (userCount === 0) {
          await this.UserModel.create(
            createDefaultUserAccountTree({
              userId: 'usr_enkush_01',
              email: 'enkush@readpack.app',
              displayName: 'Enkush',
            })
          );
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
          this.state = parsed;
          return;
        }
      }
    } catch (_) {}

    this.state = {
      books: getInitialCentralBooks(),
      users: [
        createDefaultUserAccountTree({
          userId: 'usr_enkush_01',
          email: 'enkush@readpack.app',
          displayName: 'Enkush',
        }),
      ],
    };
    this._persistToDisk();
  }

  _persistToDisk() {
    try {
      const dir = path.dirname(this.storageFilePath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      fs.writeFileSync(
        this.storageFilePath,
        JSON.stringify(this.state, null, 2),
        'utf8'
      );
    } catch (_) {}
  }

  async getAllBooks() {
    if (this.mode === 'mongodb_mongoose' && this.BookModel) {
      return await this.BookModel.find({}).lean();
    }
    return [...this.state.books];
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
      this.state.books[idx] = {
        ...this.state.books[idx],
        ...bookDoc,
        id: this.state.books[idx].id,
        updatedAt: new Date().toISOString(),
      };
      this._persistToDisk();
      return this.state.books[idx];
    }

    const inserted = {
      ...bookDoc,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    this.state.books.push(inserted);
    this._persistToDisk();
    return inserted;
  }

  async findUserTree(userIdOrEmail) {
    const key = String(userIdOrEmail || '').trim().toLowerCase();
    if (this.mode === 'mongodb_mongoose' && this.UserModel) {
      return await this.UserModel.findOne({
        $or: [{ userId: userIdOrEmail }, { email: key }],
      }).lean();
    }

    return (
      this.state.users.find(
        (u) => u.userId === userIdOrEmail || u.email.toLowerCase() === key
      ) || null
    );
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

    const idx = this.state.users.findIndex(
      (u) =>
        u.userId === userTreeDoc.userId ||
        u.email.toLowerCase() === userTreeDoc.email.toLowerCase()
    );
    if (idx >= 0) {
      this.state.users[idx] = userTreeDoc;
    } else {
      this.state.users.push(userTreeDoc);
    }
    this._persistToDisk();
    return userTreeDoc;
  }
}

module.exports = { MongoStore };
