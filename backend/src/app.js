'use strict';

const http = require('http');
const { URL } = require('url');
const { MongoStore } = require('./services/mongoStore');
const { BookCatalogService } = require('./services/bookCatalogService');
const { UserTreeService } = require('./services/userTreeService');
const { AuthError, AuthService, safeUserTree } = require('./services/authService');

const API_PREFIX = '/api/v1';
const MAX_REQUEST_BYTES = 1024 * 1024;

async function createReadPackApp({
  storageFilePath,
  mongoUri,
  forceFallback = false,
  externalFetcher,
  env = process.env,
  authOptions = {},
} = {}) {
  const store = new MongoStore({ storageFilePath });
  await store.init({ mongoUri, forceFallback, environment: env });
  const bookCatalogService = new BookCatalogService({ store, externalFetcher });
  const userTreeService = new UserTreeService({ store, bookCatalogService });
  const authService = new AuthService({ ...authOptions, store, userTreeService, env });
  const allowedOrigins = parseOrigins(env.ALLOWED_ORIGINS);
  const requestWindows = new Map();

  async function requestListener(req, res) {
    applyCors(req, res, allowedOrigins);
    if (req.method === 'OPTIONS') {
      if (!isAllowedOrigin(req.headers.origin, allowedOrigins)) {
        return sendJson(res, 403, errorBody('origin_not_allowed', 'Request origin is not allowed.'));
      }
      res.statusCode = 204;
      return res.end();
    }

    try {
      const { pathname, searchParams } = new URL(req.url, 'http://localhost');
      const body = await readJsonBody(req);
      enforceAuthRequestLimit(req, pathname, requestWindows);
      const response = await dispatchRequest({
        req,
        pathname,
        searchParams,
        body,
        store,
        bookCatalogService,
        userTreeService,
        authService,
      });
      if (!response) return sendJson(res, 404, errorBody('route_not_found', 'Route not found.'));
      return sendJson(res, response.status || 200, response.body);
    } catch (error) {
      const status = error instanceof AuthError ? error.statusCode : Number(error.statusCode || 500);
      const code = error instanceof AuthError ? error.code : error.code || (status === 500 ? 'internal_error' : 'bad_request');
      const message = status === 500 ? 'Request could not be completed.' : error.message;
      return sendJson(res, status, errorBody(code, message));
    }
  }

  return {
    app: requestListener,
    store,
    bookCatalogService,
    userTreeService,
    authService,
    createServer: () => http.createServer(requestListener),
  };
}

async function dispatchRequest({
  req,
  pathname,
  searchParams,
  body,
  store,
  bookCatalogService,
  userTreeService,
  authService,
}) {
  const method = req.method;
  if (method === 'GET' && pathname === `${API_PREFIX}/health`) {
    const books = await store.getAllBooks();
    return {
      body: {
        status: 'ok',
        engine: 'express_mongodb_tree',
        storageMode: store.mode,
        centralBooksCount: books.length,
      },
    };
  }
  if (method === 'GET' && pathname === `${API_PREFIX}/books/search`) {
    const searchResult = await bookCatalogService.searchBooks(searchParams.get('q') || searchParams.get('search') || '');
    return { body: searchResult };
  }
  if (method === 'POST' && pathname === `${API_PREFIX}/books/sync`) {
    await requireAccess(req, authService);
    const savedBook = await bookCatalogService.syncBookToCentralCatalog(body.book || body);
    return { status: 201, body: { status: 'synced_to_central_db', book: savedBook } };
  }
  if (method === 'GET' && pathname === `${API_PREFIX}/leaderboard`) {
    return { body: { entries: await authService.getLeaderboard(searchParams.get('period') || 'weekly') } };
  }
  if (pathname.startsWith(`${API_PREFIX}/auth/`)) {
    return dispatchAuthRequest(method, pathname.slice(`${API_PREFIX}/auth`.length), req, body, authService);
  }
  if (method === 'POST' && pathname === `${API_PREFIX}/internal/notifications/send`) {
    const result = await authService.sendNotification({
      serviceToken: req.headers['x-service-token'],
      userId: body.userId,
      title: body.title,
      body: body.body,
      data: body.data,
    });
    return { body: result };
  }

  const userRoute = pathname.match(/^\/api\/v1\/users\/([^/]+)\/(tree|reading|reading\/events|devices)$/);
  if (!userRoute) return null;
  const userId = decodePathSegment(userRoute[1]);
  const resource = userRoute[2];
  const session = await requireAccess(req, authService);
  if (session.userId !== userId) {
    throw new AuthError(403, 'user_mismatch', 'The requested account does not match the access token.');
  }

  if (resource === 'tree' && method === 'GET') {
    const tree = await userTreeService.getUserTree(userId);
    if (!tree) throw new AuthError(404, 'user_not_found', 'User account was not found.');
    return {
      body: {
        userAccountTree: safeUserTree(tree),
        readingStats: await authService.getReadingStats(userId),
      },
    };
  }
  if (resource === 'tree' && method === 'PUT') {
    const tree = await userTreeService.updatePreferencesAndProfile(userId, body);
    return { body: { status: 'updated', userAccountTree: safeUserTree(tree) } };
  }
  if (resource === 'reading/events' && method === 'POST') {
    const result = await authService.syncReadingEvent(userId, body);
    return { status: result.duplicate ? 200 : 201, body: result };
  }
  if (resource === 'reading' && method === 'POST') {
    if (body.eventId !== undefined) {
      throw new AuthError(400, 'event_endpoint_required', 'Reading events must use the /reading/events endpoint.');
    }
    const result = await userTreeService.syncReadingNode(userId, body);
    return {
      body: {
        status: 'synced',
        centralBook: result.centralBook,
        userAccountTree: safeUserTree(result.userAccountTree),
      },
    };
  }
  if (resource === 'devices' && method === 'POST') {
    return { body: await authService.registerDevice(userId, body) };
  }
  if (resource === 'devices' && method === 'DELETE') {
    return { body: await authService.removeDevice(userId, body.token) };
  }
  return null;
}

async function dispatchAuthRequest(method, route, req, body, authService) {
  if (method === 'POST' && route === '/signup') {
    return { status: 202, body: await authService.signUp(body) };
  }
  if (method === 'POST' && route === '/otp/resend') {
    return { status: 202, body: await authService.resendOtp(body) };
  }
  if (method === 'POST' && route === '/otp/verify') {
    return { body: await authService.verifyOtp(body) };
  }
  if (method === 'POST' && route === '/login') {
    return { body: await authService.login(body) };
  }
  if (method === 'POST' && route === '/refresh') {
    return { body: await authService.refreshSession(body.refreshToken) };
  }
  if (method === 'POST' && route === '/logout') {
    const session = await requireAccess(req, authService);
    return { body: await authService.logout(session.userId, body.refreshToken) };
  }
  if (method === 'POST' && route === '/oauth/google') {
    return { body: await authService.oauthSignIn('google', body.idToken) };
  }
  if (method === 'POST' && route === '/oauth/facebook') {
    return { body: await authService.oauthSignIn('facebook', body.accessToken) };
  }
  if (method === 'POST' && route === '/password/forgot') {
    return { status: 202, body: await authService.requestPasswordReset(body) };
  }
  if (method === 'POST' && route === '/password/reset') {
    return { body: await authService.resetPassword(body) };
  }
  return null;
}

async function requireAccess(req, authService) {
  return authService.authenticateAccessToken(req.headers.authorization);
}

function parseOrigins(value) {
  const configured = String(value || '').split(',').map((origin) => origin.trim()).filter(Boolean);
  return new Set(configured.length > 0 ? configured : ['http://localhost:3000', 'http://localhost:5000']);
}

function enforceAuthRequestLimit(req, pathname, windows) {
  if (!pathname.startsWith(`${API_PREFIX}/auth/`)) return;
  const windowMs = 15 * 60 * 1000;
  const key = `${req.socket.remoteAddress || 'unknown'}:${pathname}`;
  const now = Date.now();
  const previous = windows.get(key) || { count: 0, resetAt: now + windowMs };
  if (previous.resetAt <= now) {
    windows.set(key, { count: 1, resetAt: now + windowMs });
    return;
  }
  const limit = pathname.endsWith('/login') ? 20 : 30;
  if (previous.count >= limit) {
    throw new AuthError(429, 'rate_limited', 'Please wait before trying again.');
  }
  windows.set(key, { ...previous, count: previous.count + 1 });
}

function isAllowedOrigin(origin, origins) {
  return !origin || origins.has(origin);
}

function applyCors(req, res, allowedOrigins) {
  const origin = req.headers.origin;
  if (origin && allowedOrigins.has(origin)) res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Vary', 'Origin');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Authorization,X-Service-Token');
}

function decodePathSegment(value) {
  try {
    return decodeURIComponent(value);
  } catch (_) {
    throw new AuthError(400, 'invalid_path', 'Path parameter is invalid.');
  }
}

function sendJson(res, statusCode, payload) {
  if (res.writableEnded) return;
  res.statusCode = statusCode;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.end(JSON.stringify(payload));
}

function errorBody(code, message) {
  return { error: code, message };
}

async function readJsonBody(req) {
  if (req.method === 'GET' || req.method === 'HEAD') return {};
  const contentLength = Number(req.headers['content-length'] || 0);
  if (contentLength > MAX_REQUEST_BYTES) {
    const error = new Error('Request body is too large.');
    error.statusCode = 413;
    error.code = 'payload_too_large';
    throw error;
  }
  let raw = '';
  for await (const chunk of req) {
    raw += chunk;
    if (Buffer.byteLength(raw) > MAX_REQUEST_BYTES) {
      const error = new Error('Request body is too large.');
      error.statusCode = 413;
      error.code = 'payload_too_large';
      throw error;
    }
  }
  if (!raw) return {};
  try {
    const body = JSON.parse(raw);
    if (!body || typeof body !== 'object' || Array.isArray(body)) throw new Error('Object body required');
    return body;
  } catch (_) {
    const error = new Error('Request body must be a valid JSON object.');
    error.statusCode = 400;
    error.code = 'invalid_json';
    throw error;
  }
}

module.exports = { createReadPackApp };
