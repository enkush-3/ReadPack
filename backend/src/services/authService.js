'use strict';

const crypto = require('crypto');
const argon2 = require('argon2');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const {
  createDefaultUserAccountTree,
  computeLevel,
  computeLevelTitle,
  hashLegacyPassword,
} = require('../models/UserAccountTree');

const ACCESS_TOKEN_TTL_SECONDS = 15 * 60;
const REFRESH_TOKEN_TTL_SECONDS = 30 * 24 * 60 * 60;
const CHALLENGE_TTL_MS = 10 * 60 * 1000;
const MAX_CHALLENGE_ATTEMPTS = 5;
const ARGON_OPTIONS = { type: argon2.argon2id, memoryCost: 19456, timeCost: 2, parallelism: 1 };

class AuthError extends Error {
  constructor(statusCode, code, message) {
    super(message);
    this.name = 'AuthError';
    this.statusCode = statusCode;
    this.code = code;
  }
}

class AuthService {
  constructor({
    store,
    userTreeService,
    env = process.env,
    emailSender,
    smsSender,
    identityVerifiers = {},
    pushSender,
    now = () => Date.now(),
    randomOtp = () => String(crypto.randomInt(0, 1000000)).padStart(6, '0'),
  }) {
    this.store = store;
    this.userTreeService = userTreeService;
    this.env = env;
    this.emailSender = emailSender || createEmailSender(env);
    this.smsSender = smsSender || createSmsSender(env);
    this.identityVerifiers = {
      google: identityVerifiers.google || createGoogleVerifier(env),
      facebook: identityVerifiers.facebook || createFacebookVerifier(env),
    };
    this.pushSender = pushSender || createPushSender(env);
    this.now = now;
    this.randomOtp = randomOtp;
    this.accessSecret = configuredSecret(env, 'JWT_ACCESS_SECRET');
    this.refreshSecret = configuredSecret(env, 'JWT_REFRESH_SECRET');
    this.otpSecret = configuredSecret(env, 'OTP_HASH_SECRET');
    this.serviceToken = env.NOTIFICATION_SERVICE_TOKEN || '';
    this.deliveryWindows = new Map();
    this.loginWindows = new Map();
    this.decoyChallenges = new Map();
  }

  async signUp({ name, contact, email, password, contactType }) {
    const normalized = normalizeContact(contact, contactType);
    const optionalEmail = email ? normalizeContact(email, 'email').contact : null;
    if (contactType === 'email' && optionalEmail && optionalEmail !== normalized.contact) {
      throw new AuthError(400, 'invalid_contact', 'Email contact must match the optional email field.');
    }
    validatePassword(password);
    this.#checkRate(this.deliveryWindows, `signup:${normalized.contact}`, 5, 15 * 60 * 1000);
    if (await this.store.findUserTreeByContact(normalized.contact, contactType)) {
      throw new AuthError(409, 'contact_exists', 'This contact is already registered.');
    }
    const accountEmail = contactType === 'email' ? normalized.contact : optionalEmail;
    if (accountEmail && await this.store.findUserTreeByContact(accountEmail, 'email')) {
      throw new AuthError(409, 'contact_exists', 'This email is already registered.');
    }

    const tree = createDefaultUserAccountTree({
      email: accountEmail,
      phoneNumber: contactType === 'phone' ? normalized.contact : null,
      displayName: String(name || '').trim(),
      provider: 'email',
      passwordHash: await argon2.hash(password, ARGON_OPTIONS),
    });
    const challenge = this.#newChallenge(normalized.contact, contactType, 'signup');
    const delivery = await this.#deliverChallenge(challenge, normalized.contact, contactType);
    challenge.record.providerVerificationSid = delivery?.sid || null;
    tree.authNode.verificationChallenge = challenge.record;
    try {
      await this.store.saveUserTree(tree);
    } catch (error) {
      if (error.code === 11000) throw new AuthError(409, 'contact_exists', 'This contact is already registered.');
      throw error;
    }
    return challengeResponse(challenge.record);
  }

  async resendOtp({ challengeId }) {
    const tree = await this.store.findUserTreeByChallenge(challengeId);
    if (!tree) throw new AuthError(404, 'challenge_not_found', 'Verification request expired.');
    const previous = tree.authNode.verificationChallenge;
    this.#checkRate(this.deliveryWindows, `resend:${previous.contact}`, 5, 15 * 60 * 1000);
    const challenge = this.#newChallenge(
      previous.contact,
      previous.contactType,
      previous.purpose,
      challengeId
    );
    const delivery = await this.#deliverChallenge(challenge, previous.contact, previous.contactType);
    challenge.record.providerVerificationSid = delivery?.sid || null;
    tree.authNode.verificationChallenge = challenge.record;
    await this.store.saveUserTree(tree);
    return challengeResponse(challenge.record);
  }

  async verifyOtp({ challengeId, code }) {
    const tree = await this.store.findUserTreeByChallenge(challengeId);
    if (!tree) throw invalidCodeError();
    const challenge = tree.authNode.verificationChallenge;
    this.#validateChallenge(challenge, code);
    if (!(await this.#checkChallengeCode(challenge, code))) {
      await this.#recordChallengeFailure(tree, challenge);
      throw invalidCodeError();
    }
    if (challenge.purpose !== 'signup') {
      throw new AuthError(400, 'wrong_challenge', 'Use the password reset flow for this code.');
    }

    tree.authNode.emailVerified = challenge.contactType === 'email';
    tree.authNode.phoneVerified = challenge.contactType === 'phone';
    tree.authNode.verificationChallenge = null;
    await this.store.saveUserTree(tree);
    return this.#issueSession(tree);
  }

  async login({ contact, contactType, email, password }) {
    const resolvedContact = contact || email;
    const resolvedType = contactType || (String(resolvedContact || '').includes('@') ? 'email' : 'phone');
    const normalized = normalizeContact(resolvedContact, resolvedType);
    this.#checkRate(this.loginWindows, `login:${normalized.contact}`, 5, 15 * 60 * 1000);
    const tree = await this.store.findUserTreeByContact(normalized.contact, resolvedType);
    if (!tree || !tree.authNode?.passwordHash) throw invalidCredentialsError();

    const isLegacyEmailAccount = resolvedType === 'email' && isLegacyHash(tree.authNode.passwordHash);
    const isVerified = resolvedType === 'email'
      ? Boolean(tree.authNode.emailVerified || isLegacyEmailAccount)
      : Boolean(tree.authNode.phoneVerified);
    if (!isVerified) throw new AuthError(403, 'contact_not_verified', 'Verify your contact before signing in.');
    if (!(await this.#verifyPassword(tree, password, resolvedType))) throw invalidCredentialsError();

    tree.authNode.lastLoginAt = new Date(this.now()).toISOString();
    if (isLegacyEmailAccount) tree.authNode.emailVerified = true;
    await this.store.saveUserTree(tree);
    return this.#issueSession(tree);
  }

  async requestPasswordReset({ contact, contactType }) {
    const normalized = normalizeContact(contact, contactType);
    this.#checkRate(this.deliveryWindows, `reset:${normalized.contact}`, 5, 15 * 60 * 1000);
    const tree = await this.store.findUserTreeByContact(normalized.contact, contactType);
    const verified = contactType === 'email'
      ? Boolean(tree?.authNode?.emailVerified)
      : Boolean(tree?.authNode?.phoneVerified);
    if (!tree || !verified) {
      const challengeId = crypto.randomUUID();
      this.decoyChallenges.set(challengeId, this.now() + CHALLENGE_TTL_MS);
      return { challengeId, expiresAt: new Date(this.now() + CHALLENGE_TTL_MS).toISOString() };
    }

    const challenge = this.#newChallenge(normalized.contact, contactType, 'password_reset');
    tree.authNode.verificationChallenge = challenge.record;
    try {
      const delivery = await this.#deliverChallenge(challenge, normalized.contact, contactType);
      challenge.record.providerVerificationSid = delivery?.sid || null;
    } catch (_) {
      // Recovery responses do not reveal whether the contact exists or delivery is configured.
    }
    await this.store.saveUserTree(tree);
    return challengeResponse(challenge.record);
  }

  async resetPassword({ challengeId, code, newPassword }) {
    validatePassword(newPassword);
    const tree = await this.store.findUserTreeByChallenge(challengeId);
    if (!tree) throw invalidCodeError();
    const challenge = tree.authNode.verificationChallenge;
    this.#validateChallenge(challenge, code);
    if (challenge.purpose !== 'password_reset' || !(await this.#checkChallengeCode(challenge, code))) {
      await this.#recordChallengeFailure(tree, challenge);
      throw invalidCodeError();
    }

    tree.authNode.passwordHash = await argon2.hash(newPassword, ARGON_OPTIONS);
    tree.authNode.verificationChallenge = null;
    tree.authNode.refreshSessions = [];
    await this.store.saveUserTree(tree);
    this.decoyChallenges.delete(challengeId);
    return { status: 'password_reset' };
  }

  async oauthSignIn(provider, token) {
    const verifier = this.identityVerifiers[provider];
    if (!verifier || typeof token !== 'string' || !token) {
      throw new AuthError(400, 'invalid_provider_token', 'Provider token is required.');
    }
    let identity;
    try {
      identity = await verifier(token);
    } catch (_) {
      throw new AuthError(401, 'invalid_provider_token', 'Provider token could not be verified.');
    }
    if (!identity?.subject) throw new AuthError(401, 'invalid_provider_token', 'Provider identity is invalid.');

    let tree = await this.store.findUserTreeByProvider(provider, identity.subject);
    if (!tree && identity.email && identity.emailVerified) {
      tree = await this.store.findUserTreeByContact(identity.email, 'email');
    }
    if (!tree) {
      tree = createDefaultUserAccountTree({
        email: identity.emailVerified ? identity.email : null,
        displayName: identity.name || 'ReadPack Reader',
        provider,
        providerSubject: identity.subject,
        emailVerified: Boolean(identity.emailVerified),
      });
    } else {
      tree.authNode.provider = provider;
      tree.authNode.providerSubject = identity.subject;
      tree.authNode.emailVerified = Boolean(identity.emailVerified);
      tree.authNode.lastLoginAt = new Date(this.now()).toISOString();
    }
    await this.store.saveUserTree(tree);
    return this.#issueSession(tree);
  }

  async authenticateAccessToken(authorizationHeader) {
    const token = String(authorizationHeader || '').match(/^Bearer\s+(.+)$/i)?.[1];
    if (!token) throw new AuthError(401, 'missing_token', 'Bearer access token is required.');
    try {
      const payload = jwt.verify(token, this.accessSecret, {
        algorithms: ['HS256'],
        issuer: 'readpack-api',
      });
      if (payload.tokenUse !== 'access' || !payload.sub || !payload.sid) throw new Error('Wrong token type');
      const tree = await this.store.findUserTree(payload.sub);
      const session = tree?.authNode?.refreshSessions?.find((item) => item.sessionId === payload.sid);
      if (!session || session.expiresAt <= new Date(this.now()).toISOString()) throw new Error('Revoked session');
      return { userId: payload.sub, sessionId: payload.sid };
    } catch (error) {
      if (error instanceof AuthError) throw error;
      throw new AuthError(401, 'invalid_token', 'Access token is invalid, expired, or revoked.');
    }
  }

  async refreshSession(refreshToken) {
    const payload = this.#verifyRefreshToken(refreshToken);
    return this.store.withUserLock(payload.sub, async () => {
      const tree = await this.store.findUserTree(payload.sub);
      const sessions = tree?.authNode?.refreshSessions || [];
      const session = sessions.find((item) => item.sessionId === payload.sid);
      if (!session || session.expiresAt <= new Date(this.now()).toISOString() || !safeEqual(session.tokenHash, hashToken(refreshToken))) {
        throw new AuthError(401, 'invalid_refresh_token', 'Refresh token is invalid or expired.');
      }
      tree.authNode.refreshSessions = sessions.filter((item) => item.sessionId !== payload.sid);
      await this.store.saveUserTree(tree);
      return this.#issueSession(tree);
    });
  }

  async logout(userId, refreshToken) {
    const payload = this.#verifyRefreshToken(refreshToken);
    if (payload.sub !== userId) throw new AuthError(403, 'session_mismatch', 'Session belongs to another user.');
    const tree = await this.store.findUserTree(userId);
    if (tree) {
      tree.authNode.refreshSessions = (tree.authNode.refreshSessions || []).filter(
        (session) => session.sessionId !== payload.sid
      );
      await this.store.saveUserTree(tree);
    }
    return { status: 'logged_out' };
  }

  async registerDevice(userId, { token, platform }) {
    if (typeof token !== 'string' || token.length < 20 || token.length > 4096) {
      throw new AuthError(400, 'invalid_device_token', 'A valid push token is required.');
    }
    if (!['android', 'ios'].includes(platform)) throw new AuthError(400, 'invalid_platform', 'Platform must be android or ios.');
    const tree = await this.store.findUserTree(userId);
    if (!tree) throw new AuthError(404, 'user_not_found', 'User account was not found.');
    await this.store.removeNotificationTokenFromOtherUsers(userId, token);
    const devices = tree.notificationDevices || [];
    tree.notificationDevices = [
      ...devices.filter((device) => device.token !== token),
      { token, platform, updatedAt: new Date(this.now()).toISOString() },
    ].slice(-10);
    await this.store.saveUserTree(tree);
    return { ok: true };
  }

  async removeDevice(userId, token) {
    const tree = await this.store.findUserTree(userId);
    if (tree) {
      tree.notificationDevices = (tree.notificationDevices || []).filter((device) => device.token !== token);
      await this.store.saveUserTree(tree);
    }
    return { ok: true };
  }

  async sendNotification({ serviceToken, userId, title, body, data = {} }) {
    if (!this.serviceToken || !safeEqual(serviceToken, this.serviceToken)) {
      throw new AuthError(401, 'invalid_service_token', 'Service authorization is required.');
    }
    const tree = await this.store.findUserTree(userId);
    if (!tree) throw new AuthError(404, 'user_not_found', 'User account was not found.');
    const tokens = (tree.notificationDevices || []).map((device) => device.token);
    if (tokens.length === 0) return { sent: 0, failed: 0 };
    return this.pushSender({ tokens, title, body, data });
  }

  async getLeaderboard(period = 'weekly') {
    if (!['weekly', 'monthly'].includes(period)) {
      throw new AuthError(400, 'invalid_period', 'Period must be weekly or monthly.');
    }
    const start = leaderboardStart(period, this.now());
    const [trees, events] = await Promise.all([
      this.store.getAllUserTrees(),
      this.store.getReadingEventsSince(start),
    ]);
    const xpByUser = new Map();
    for (const event of events) {
      xpByUser.set(event.userId, (xpByUser.get(event.userId) || 0) + Number(event.xp || 0));
    }
    return trees
      .filter((tree) => tree.authNode?.emailVerified || tree.authNode?.phoneVerified)
      .map((tree) => {
        const xp = xpByUser.get(tree.userId) || 0;
        return {
          userId: tree.userId,
          name: tree.profileNode?.displayName || 'ReadPack Reader',
          xp,
          level: computeLevel(xp),
          title: computeLevelTitle(xp),
        };
      })
      .filter((entry) => entry.xp > 0)
      .sort((left, right) => right.xp - left.xp)
      .map((entry, index) => ({ ...entry, rank: index + 1 }));
  }

  async getReadingStats(userId) {
    return this.#collectReadingStats(userId);
  }

  async syncReadingEvent(userId, payload) {
    const eventId = String(payload?.eventId || '').trim();
    const minutes = Number(payload?.minutesRead ?? 0);
    if (!eventId || eventId.length > 128) throw new AuthError(400, 'event_id_required', 'A unique reading event id is required.');
    if (!Number.isInteger(minutes) || minutes < 0 || minutes > 180) {
      throw new AuthError(400, 'invalid_minutes', 'Reading minutes must be an integer from 0 to 180.');
    }
    const timezoneOffsetMinutes = Number(payload.timezoneOffsetMinutes ?? 0);
    if (!Number.isInteger(timezoneOffsetMinutes) || timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw new AuthError(400, 'invalid_timezone', 'Timezone offset must be between -840 and 840 minutes.');
    }
    if (!this.userTreeService) throw new AuthError(503, 'reading_sync_unavailable', 'Reading sync is unavailable.');

    return this.store.withUserLock(userId, async () => {
      const bookId = typeof payload.book === 'object' ? payload.book.id : payload.bookId || payload.book;
      if (!bookId) throw new AuthError(400, 'book_required', 'A bookId or book payload is required.');
      const payloadHash = hashToken(stableSerialize({
        bookId,
        minutes,
        timezoneOffsetMinutes,
        shelfId: payload.shelfId,
        status: payload.status,
        progress: payload.progress,
        currentChapter: payload.currentChapter,
        currentPage: payload.currentPage,
        highlight: payload.highlight,
        note: payload.note,
      }));
      let event = await this.store.findReadingEvent(userId, eventId);
      if (event && event.payloadHash !== payloadHash) {
        throw new AuthError(409, 'event_id_conflict', 'Event id was already used with different data.');
      }
      if (!event) {
        const createdAt = new Date(this.now()).toISOString();
        const result = await this.store.createReadingEvent({
          userId,
          eventId,
          payloadHash,
          bookId: String(bookId),
          minutes,
          timezoneOffsetMinutes,
          readingDate: localDateKey(createdAt, timezoneOffsetMinutes),
          xp: 0,
          status: 'pending',
          createdAt,
        });
        event = result.event;
      }
      if (event.status === 'complete') return this.#readingResponse(userId, event, true);

      const synced = await this.userTreeService.syncReadingNode(userId, { ...payload, minutesRead: 0 });
      const currentTree = await this.store.findUserTree(userId);
      const previousXpEvent = currentTree?.gamificationTree?.xpNode?.xpEvents
        ?.find((item) => item.eventId === eventId);
      const rewards = previousXpEvent
        ? { tree: currentTree, earnedXp: previousXpEvent.xp, duplicate: true }
        : await this.userTreeService.applyReadingRewards(userId, {
          eventId,
          minutes: event.minutes,
          timezoneOffsetMinutes: event.timezoneOffsetMinutes || 0,
          payloadHash,
          createdAt: new Date(event.createdAt).toISOString(),
        });
      await this.store.completeReadingEvent(userId, eventId, {
        xp: rewards.earnedXp,
        createdAt: new Date(event.createdAt).toISOString(),
      });
      const response = await this.#readingResponse(userId, {
        ...event,
        xp: rewards.earnedXp,
        bookId: String(bookId),
      }, Boolean(rewards.duplicate));
      return { ...response, centralBook: synced.centralBook };
    });
  }

  #newChallenge(contact, contactType, purpose, challengeId = crypto.randomUUID()) {
    if (!this.otpSecret) throw new AuthError(503, 'auth_not_configured', 'Authentication is not configured on this server.');
    const code = contactType === 'email' ? this.randomOtp() : null;
    return {
      code,
      record: {
        challengeId,
        purpose,
        contact,
        contactType,
        otpHash: code ? this.#hashOtp(code) : null,
        providerVerificationSid: null,
        expiresAt: new Date(this.now() + CHALLENGE_TTL_MS).toISOString(),
        attempts: 0,
      },
    };
  }

  async #deliverChallenge(challenge, contact, contactType) {
    if (contactType === 'email') {
      await this.emailSender({ to: contact, code: challenge.code, purpose: challenge.record.purpose });
      return null;
    }
    return this.smsSender({ to: contact, purpose: challenge.record.purpose });
  }

  #validateChallenge(challenge, code) {
    if (!challenge || challenge.expiresAt <= new Date(this.now()).toISOString()) throw invalidCodeError();
    if (challenge.attempts >= MAX_CHALLENGE_ATTEMPTS) {
      throw new AuthError(429, 'too_many_attempts', 'Too many verification attempts. Request a new code.');
    }
    if (!/^\d{6}$/.test(String(code || ''))) throw invalidCodeError();
  }

  async #checkChallengeCode(challenge, code) {
    if (challenge.contactType === 'phone') return Boolean(await this.smsSender.verify({ to: challenge.contact, code }));
    return safeEqual(challenge.otpHash || '', this.#hashOtp(code));
  }

  async #recordChallengeFailure(tree, challenge) {
    challenge.attempts = Number(challenge.attempts || 0) + 1;
    tree.authNode.verificationChallenge = challenge;
    await this.store.saveUserTree(tree);
  }

  #hashOtp(code) {
    return crypto.createHmac('sha256', this.otpSecret).update(String(code)).digest('hex');
  }

  #checkRate(windows, key, limit, windowMs) {
    const currentTime = this.now();
    const previous = windows.get(key) || { count: 0, start: currentTime };
    if (currentTime - previous.start >= windowMs) {
      windows.set(key, { count: 1, start: currentTime });
      return;
    }
    if (previous.count >= limit) throw new AuthError(429, 'rate_limited', 'Please wait before trying again.');
    windows.set(key, { ...previous, count: previous.count + 1 });
  }

  async #verifyPassword(tree, password, contactType) {
    if (typeof password !== 'string' || !password) return false;
    const storedHash = String(tree.authNode.passwordHash || '');
    if (storedHash.startsWith('$argon2')) {
      try {
        return await argon2.verify(storedHash, password);
      } catch (_) {
        return false;
      }
    }
    if (contactType !== 'email' || !isLegacyHash(storedHash)) return false;
    if (tree.email === 'enkush@readpack.app' && safeEqual(storedHash, hashLegacyPassword('readpack123'))) return false;
    if (!safeEqual(storedHash, hashLegacyPassword(password))) return false;
    tree.authNode.passwordHash = await argon2.hash(password, ARGON_OPTIONS);
    await this.store.saveUserTree(tree);
    return true;
  }

  async #issueSession(tree) {
    if (!this.accessSecret || !this.refreshSecret || !this.otpSecret) {
      throw new AuthError(503, 'auth_not_configured', 'Authentication is not configured on this server.');
    }
    const sessionId = crypto.randomUUID();
    const issuedAt = Math.floor(this.now() / 1000);
    const accessToken = jwt.sign(
      { tokenUse: 'access', sid: sessionId },
      this.accessSecret,
      { algorithm: 'HS256', subject: tree.userId, issuer: 'readpack-api', expiresIn: ACCESS_TOKEN_TTL_SECONDS }
    );
    const refreshToken = jwt.sign(
      { tokenUse: 'refresh', sid: sessionId },
      this.refreshSecret,
      { algorithm: 'HS256', subject: tree.userId, issuer: 'readpack-api', expiresIn: REFRESH_TOKEN_TTL_SECONDS }
    );
    tree.authNode.refreshSessions = (tree.authNode.refreshSessions || [])
      .filter((session) => session.expiresAt > new Date(this.now()).toISOString())
      .slice(-4);
    tree.authNode.refreshSessions.push({
      sessionId,
      tokenHash: hashToken(refreshToken),
      expiresAt: new Date((issuedAt + REFRESH_TOKEN_TTL_SECONDS) * 1000).toISOString(),
    });
    await this.store.saveUserTree(tree);
    return {
      accessToken,
      refreshToken,
      expiresAt: new Date((issuedAt + ACCESS_TOKEN_TTL_SECONDS) * 1000).toISOString(),
      userAccountTree: safeUserTree(tree),
    };
  }

  async #readingResponse(userId, event, duplicate) {
    const [stats, books] = await Promise.all([
      this.#collectReadingStats(userId),
      this.store.getAllBooks(),
    ]);
    return {
      status: 'synced',
      duplicate,
      eventId: event.eventId,
      earnedXp: Number(event.xp || 0),
      readingStats: stats,
      userAccountTree: safeUserTree(await this.store.findUserTree(userId)),
      centralBook: books.find((item) => item.id === event.bookId) || null,
    };
  }

  async #collectReadingStats(userId) {
    const [tree, events] = await Promise.all([
      this.store.findUserTree(userId),
      this.store.getReadingEventsSince(leaderboardStart('weekly', this.now()) - 24 * 60 * 60 * 1000),
    ]);
    const userEvents = events.filter((item) => item.userId === userId);
    const mostRecentEvent = userEvents
      .slice()
      .sort((left, right) => Date.parse(right.createdAt) - Date.parse(left.createdAt))[0];
    const offset = Number(mostRecentEvent?.timezoneOffsetMinutes || 0);
    const today = localDateKey(new Date(this.now()).toISOString(), offset);
    const weekStart = mondayDateKey(today);
    const weeklyMinutes = [0, 0, 0, 0, 0, 0, 0];
    for (const event of userEvents) {
      const eventDate = event.readingDate || localDateKey(event.createdAt, event.timezoneOffsetMinutes || 0);
      if (eventDate < weekStart || eventDate > today) continue;
      const weekday = new Date(`${eventDate}T00:00:00.000Z`).getUTCDay();
      const mondayIndex = (weekday + 6) % 7;
      weeklyMinutes[mondayIndex] += Number(event.minutes || 0);
    }
    return {
      weeklyMinutes,
      weeklyMinutesRead: weeklyMinutes.reduce((sum, minutes) => sum + minutes, 0),
      minutesReadToday: Number(tree?.gamificationTree?.streakNode?.minutesReadToday || 0),
      totalXp: Number(tree?.gamificationTree?.xpNode?.totalXp || 0),
      currentStreak: Number(tree?.gamificationTree?.streakNode?.currentStreak || 0),
      lastActiveDate: tree?.gamificationTree?.streakNode?.lastActiveDate || null,
    };
  }

  #verifyRefreshToken(refreshToken) {
    try {
      const payload = jwt.verify(refreshToken, this.refreshSecret, {
        algorithms: ['HS256'],
        issuer: 'readpack-api',
      });
      if (payload.tokenUse !== 'refresh' || !payload.sub || !payload.sid) throw new Error('Wrong token type');
      return payload;
    } catch (_) {
      throw new AuthError(401, 'invalid_refresh_token', 'Refresh token is invalid or expired.');
    }
  }
}

function normalizeContact(contact, contactType) {
  const value = String(contact || '').trim();
  if (contactType === 'email') {
    const normalized = value.toLowerCase();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalized)) {
      throw new AuthError(400, 'invalid_contact', 'Enter a valid email address.');
    }
    return { contact: normalized, contactType };
  }
  if (contactType === 'phone') {
    const normalized = value.replace(/[\s()-]/g, '');
    if (!/^\+[1-9]\d{7,14}$/.test(normalized)) {
      throw new AuthError(400, 'invalid_contact', 'Enter a phone number in E.164 format.');
    }
    return { contact: normalized, contactType };
  }
  throw new AuthError(400, 'invalid_contact_type', 'Contact type must be email or phone.');
}

function validatePassword(password) {
  if (typeof password !== 'string' || password.length < 8 || password.length > 128) {
    throw new AuthError(400, 'invalid_password', 'Password must contain 8 to 128 characters.');
  }
}

function challengeResponse(challenge) {
  return { challengeId: challenge.challengeId, expiresAt: challenge.expiresAt };
}

function safeUserTree(tree) {
  if (!tree) return null;
  const safe = structuredClone(tree);
  if (safe.authNode) {
    delete safe.authNode.passwordHash;
    delete safe.authNode.verificationChallenge;
    delete safe.authNode.refreshSessions;
  }
  if (safe.gamificationTree?.xpNode) delete safe.gamificationTree.xpNode.xpEvents;
  delete safe.notificationDevices;
  return safe;
}

function invalidCodeError() {
  return new AuthError(400, 'invalid_code', 'The code is invalid or expired.');
}

function invalidCredentialsError() {
  return new AuthError(401, 'invalid_credentials', 'Email/phone or password is incorrect.');
}

function isLegacyHash(value) {
  return /^[a-f\d]{64}$/i.test(String(value || ''));
}

function hashToken(token) {
  return crypto.createHash('sha256').update(String(token)).digest('hex');
}

function safeEqual(left, right) {
  const leftBuffer = Buffer.from(String(left));
  const rightBuffer = Buffer.from(String(right));
  return leftBuffer.length === rightBuffer.length && crypto.timingSafeEqual(leftBuffer, rightBuffer);
}

function stableSerialize(value) {
  if (Array.isArray(value)) return `[${value.map(stableSerialize).join(',')}]`;
  if (value && typeof value === 'object') {
    return `{${Object.keys(value).sort().map((key) => `${JSON.stringify(key)}:${stableSerialize(value[key])}`).join(',')}}`;
  }
  return JSON.stringify(value);
}

function leaderboardStart(period, currentTime) {
  const date = new Date(currentTime);
  if (period === 'monthly') return Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), 1);
  const daysSinceMonday = (date.getUTCDay() + 6) % 7;
  return Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate() - daysSinceMonday);
}

function localDateKey(timestamp, timezoneOffsetMinutes) {
  const date = new Date(new Date(timestamp).getTime() + timezoneOffsetMinutes * 60 * 1000);
  return date.toISOString().slice(0, 10);
}

function mondayDateKey(dateKey) {
  const date = new Date(`${dateKey}T00:00:00.000Z`);
  const daysSinceMonday = (date.getUTCDay() + 6) % 7;
  date.setUTCDate(date.getUTCDate() - daysSinceMonday);
  return date.toISOString().slice(0, 10);
}

function developmentSecret(env) {
  return env.NODE_ENV === 'production' ? '' : crypto.randomBytes(32).toString('hex');
}

function configuredSecret(env, key) {
  const configured = String(env[key] || '');
  if (env.NODE_ENV === 'production' && Buffer.byteLength(configured) < 32) return '';
  return configured || developmentSecret(env);
}

function createEmailSender(env) {
  return async ({ to, code, purpose }) => {
    if (!env.SMTP_HOST || !env.SMTP_FROM) {
      throw new AuthError(503, 'email_delivery_unavailable', 'Email verification is not configured.');
    }
    const nodemailer = require('nodemailer');
    const transporter = nodemailer.createTransport({
      host: env.SMTP_HOST,
      port: Number(env.SMTP_PORT || 587),
      secure: String(env.SMTP_SECURE).toLowerCase() === 'true',
      auth: env.SMTP_USER ? { user: env.SMTP_USER, pass: env.SMTP_PASSWORD } : undefined,
    });
    const subject = purpose === 'password_reset' ? 'Reset your ReadPack password' : 'Verify your ReadPack account';
    await transporter.sendMail({
      from: env.SMTP_FROM,
      to,
      subject,
      text: `Your ReadPack code is ${code}. It expires in 10 minutes. If you did not request this, ignore this message.`,
    });
  };
}

function createSmsSender(env) {
  let service;
  const getService = () => {
    if (!env.TWILIO_ACCOUNT_SID || !env.TWILIO_AUTH_TOKEN || !env.TWILIO_VERIFY_SERVICE_SID) {
      throw new AuthError(503, 'sms_delivery_unavailable', 'SMS verification is not configured.');
    }
    if (!service) {
      const client = require('twilio')(env.TWILIO_ACCOUNT_SID, env.TWILIO_AUTH_TOKEN);
      service = client.verify.v2.services(env.TWILIO_VERIFY_SERVICE_SID);
    }
    return service;
  };
  return Object.assign(
    async ({ to }) => {
      const verification = await getService().verifications.create({ to, channel: 'sms' });
      return { sid: verification.sid };
    },
    {
      verify: async ({ to, code }) => {
        const check = await getService().verificationChecks.create({ to, code });
        return check.status === 'approved';
      },
    }
  );
}

function createGoogleVerifier(env) {
  const client = new OAuth2Client();
  const audiences = String(env.GOOGLE_CLIENT_IDS || '').split(',').map((item) => item.trim()).filter(Boolean);
  return async (idToken) => {
    if (audiences.length === 0) throw new Error('Google OAuth is not configured.');
    const ticket = await client.verifyIdToken({ idToken, audience: audiences });
    const payload = ticket.getPayload();
    if (!payload?.sub) throw new Error('Google token has no subject.');
    return {
      subject: payload.sub,
      email: payload.email?.toLowerCase() || null,
      emailVerified: Boolean(payload.email_verified),
      name: payload.name || payload.email?.split('@')[0],
    };
  };
}

function createFacebookVerifier(env) {
  return async (accessToken) => {
    if (!env.FACEBOOK_APP_ID || !env.FACEBOOK_APP_SECRET) throw new Error('Facebook OAuth is not configured.');
    const appToken = `${env.FACEBOOK_APP_ID}|${env.FACEBOOK_APP_SECRET}`;
    const debugUrl = new URL('https://graph.facebook.com/debug_token');
    debugUrl.searchParams.set('input_token', accessToken);
    debugUrl.searchParams.set('access_token', appToken);
    const debugResponse = await fetch(debugUrl);
    const debugBody = await debugResponse.json();
    const tokenData = debugBody.data;
    if (!debugResponse.ok || !tokenData?.is_valid || tokenData.app_id !== env.FACEBOOK_APP_ID) {
      throw new Error('Facebook token is invalid.');
    }
    const profileUrl = new URL('https://graph.facebook.com/me');
    profileUrl.searchParams.set('fields', 'id,name');
    profileUrl.searchParams.set('access_token', accessToken);
    const profileResponse = await fetch(profileUrl);
    const profile = await profileResponse.json();
    if (!profileResponse.ok || !profile.id || profile.id !== tokenData.user_id) {
      throw new Error('Facebook identity does not match token.');
    }
    return { subject: profile.id, email: null, emailVerified: false, name: profile.name };
  };
}

function createPushSender(env) {
  return async ({ tokens, title, body, data }) => {
    if (!env.FIREBASE_SERVICE_ACCOUNT_JSON) {
      throw new AuthError(503, 'push_delivery_unavailable', 'Push notifications are not configured.');
    }
    const admin = require('firebase-admin');
    if (admin.apps.length === 0) {
      const serviceAccount = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT_JSON);
      admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    }
    const result = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: Object.fromEntries(Object.entries(data || {}).map(([key, value]) => [key, String(value)])),
    });
    return { sent: result.successCount, failed: result.failureCount };
  };
}

module.exports = { AuthError, AuthService, safeUserTree };
