'use strict';

const http = require('http');
const { URL } = require('url');
const { MongoStore } = require('./services/mongoStore');
const { BookCatalogService } = require('./services/bookCatalogService');
const { UserTreeService } = require('./services/userTreeService');

/**
 * Creates the ReadPack Express.js API Application (with automatic native HTTP
 * adapter fallback if `node_modules/express` is not yet installed).
 */
async function createReadPackApp({
  storageFilePath,
  mongoUri,
  forceFallback = false,
  externalFetcher,
} = {}) {
  const store = new MongoStore({ storageFilePath });
  await store.init({ mongoUri, forceFallback });

  const bookCatalogService = new BookCatalogService({
    store,
    externalFetcher,
  });
  const userTreeService = new UserTreeService({
    store,
    bookCatalogService,
  });

  // Shared route handlers (Express (req, res) signature)
  const handlers = {
    async health(req, res) {
      const books = await store.getAllBooks();
      return sendJson(res, 200, {
        status: 'ok',
        engine: 'express_mongodb_tree',
        storageMode: store.mode,
        centralBooksCount: books.length,
      });
    },

    async searchBooks(req, res, queryObj) {
      try {
        const q = queryObj.q ?? queryObj.search ?? '';
        const result = await bookCatalogService.searchBooks(q);
        return sendJson(res, 200, result);
      } catch (err) {
        return sendJson(res, 500, { error: err.message });
      }
    },

    async syncBook(req, res, body) {
      try {
        const bookPayload = body?.book || body;
        const savedBook = await bookCatalogService.syncBookToCentralCatalog(
          bookPayload
        );
        return sendJson(res, 201, {
          status: 'synced_to_central_db',
          book: savedBook,
        });
      } catch (err) {
        return sendJson(res, 400, { error: err.message });
      }
    },

    async authLogin(req, res, body) {
      try {
        const userAccountTree = await userTreeService.loginOrRegister({
          email: body?.email,
          name: body?.name || body?.displayName,
          password: body?.password,
          provider: body?.provider || 'email',
        });
        return sendJson(res, 200, {
          status: 'authenticated',
          userAccountTree,
        });
      } catch (err) {
        return sendJson(res, 400, { error: err.message });
      }
    },

    async getUserTree(req, res, userId) {
      try {
        const tree = await userTreeService.getUserTree(userId);
        if (!tree) {
          return sendJson(res, 404, { error: 'User account tree not found' });
        }
        return sendJson(res, 200, { userAccountTree: tree });
      } catch (err) {
        return sendJson(res, 500, { error: err.message });
      }
    },

    async updateUserTree(req, res, userId, body) {
      try {
        const tree = await userTreeService.updatePreferencesAndProfile(
          userId,
          body
        );
        return sendJson(res, 200, {
          status: 'updated',
          userAccountTree: tree,
        });
      } catch (err) {
        return sendJson(res, 400, { error: err.message });
      }
    },

    async syncUserReading(req, res, userId, body) {
      try {
        const result = await userTreeService.syncReadingNode(userId, body);
        return sendJson(res, 201, {
          status: 'synced',
          source: 'central_db',
          centralBook: result.centralBook,
          userAccountTree: result.userAccountTree,
        });
      } catch (err) {
        return sendJson(res, 400, { error: err.message });
      }
    },
  };

  // Try loading Express if installed in node_modules
  try {
    const express = require('express');
    const app = express();
    app.use(express.json({ limit: '2mb' }));
    app.use((req, res, next) => {
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader(
        'Access-Control-Allow-Methods',
        'GET,POST,PUT,PATCH,DELETE,OPTIONS'
      );
      res.setHeader(
        'Access-Control-Allow-Headers',
        'Content-Type, Authorization'
      );
      if (req.method === 'OPTIONS') return res.sendStatus(204);
      next();
    });

    app.get('/api/v1/health', (req, res) => handlers.health(req, res));
    app.get('/api/v1/books/search', (req, res) =>
      handlers.searchBooks(req, res, req.query || {})
    );
    app.post('/api/v1/books/sync', (req, res) =>
      handlers.syncBook(req, res, req.body || {})
    );
    app.post('/api/v1/auth/login', (req, res) =>
      handlers.authLogin(req, res, req.body || {})
    );
    app.get('/api/v1/users/:userId/tree', (req, res) =>
      handlers.getUserTree(req, res, decodeURIComponent(req.params.userId))
    );
    app.put('/api/v1/users/:userId/tree', (req, res) =>
      handlers.updateUserTree(
        req,
        res,
        decodeURIComponent(req.params.userId),
        req.body || {}
      )
    );
    app.post('/api/v1/users/:userId/reading', (req, res) =>
      handlers.syncUserReading(
        req,
        res,
        decodeURIComponent(req.params.userId),
        req.body || {}
      )
    );

    return {
      app,
      store,
      bookCatalogService,
      userTreeService,
      createServer: () => http.createServer(app),
    };
  } catch (_) {
    // Express-compatible HTTP router when running without node_modules installed
    const requestListener = async (req, res) => {
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader(
        'Access-Control-Allow-Methods',
        'GET,POST,PUT,PATCH,DELETE,OPTIONS'
      );
      res.setHeader(
        'Access-Control-Allow-Headers',
        'Content-Type, Authorization'
      );
      if (req.method === 'OPTIONS') {
        res.statusCode = 204;
        return res.end();
      }

      const parsedUrl = new URL(req.url, 'http://localhost');
      const pathname = parsedUrl.pathname;
      const queryObj = Object.fromEntries(parsedUrl.searchParams.entries());
      const body = await readJsonBody(req);

      if (req.method === 'GET' && pathname === '/api/v1/health') {
        return handlers.health(req, res);
      }
      if (req.method === 'GET' && pathname === '/api/v1/books/search') {
        return handlers.searchBooks(req, res, queryObj);
      }
      if (req.method === 'POST' && pathname === '/api/v1/books/sync') {
        return handlers.syncBook(req, res, body);
      }
      if (req.method === 'POST' && pathname === '/api/v1/auth/login') {
        return handlers.authLogin(req, res, body);
      }

      const treeMatch = pathname.match(/^\/api\/v1\/users\/([^/]+)\/tree$/);
      if (treeMatch) {
        const userId = decodeURIComponent(treeMatch[1]);
        if (req.method === 'GET') return handlers.getUserTree(req, res, userId);
        if (req.method === 'PUT')
          return handlers.updateUserTree(req, res, userId, body);
      }

      const readingMatch = pathname.match(
        /^\/api\/v1\/users\/([^/]+)\/reading$/
      );
      if (readingMatch && req.method === 'POST') {
        const userId = decodeURIComponent(readingMatch[1]);
        return handlers.syncUserReading(req, res, userId, body);
      }

      return sendJson(res, 404, { error: `Route not found: ${pathname}` });
    };

    return {
      app: requestListener,
      store,
      bookCatalogService,
      userTreeService,
      createServer: () => http.createServer(requestListener),
    };
  }
}

function sendJson(res, statusCode, payload) {
  if (typeof res.status === 'function' && typeof res.json === 'function') {
    return res.status(statusCode).json(payload);
  }
  res.statusCode = statusCode;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.end(JSON.stringify(payload));
}

function readJsonBody(req) {
  return new Promise((resolve) => {
    if (req.method === 'GET' || req.method === 'HEAD') return resolve({});
    let raw = '';
    req.on('data', (chunk) => {
      raw += chunk;
    });
    req.on('end', () => {
      if (!raw) return resolve({});
      try {
        resolve(JSON.parse(raw));
      } catch (_) {
        resolve({});
      }
    });
    req.on('error', () => resolve({}));
  });
}

module.exports = { createReadPackApp };
