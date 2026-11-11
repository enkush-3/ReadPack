'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { createReadPackApp } = require('../src/app');
const { createDefaultUserAccountTree, hashLegacyPassword } = require('../src/models/UserAccountTree');

test('ReadPack auth, protected user data, reading rewards and catalog API', async (t) => {
  const tempDirectory = fs.mkdtempSync(path.join(os.tmpdir(), 'readpack-api-test-'));
  const storageFilePath = path.join(tempDirectory, 'store.json');
  const emailMessages = [];
  const smsMessages = [];
  const pushDeliveries = [];
  let currentTime = Date.now();
  let otpCounter = 110000;
  const fixedSmsCode = '654321';
  const smsSender = async ({ to, purpose }) => {
    smsMessages.push({ to, purpose, code: fixedSmsCode });
    return { sid: `sms_${smsMessages.length}` };
  };
  smsSender.verify = async ({ to, code }) =>
    smsMessages.some((message) => message.to === to && message.code === code);

  const { createServer, store } = await createReadPackApp({
    storageFilePath,
    forceFallback: true,
    externalFetcher: async (query) => query.toLowerCase().includes('deep work')
      ? [{
        id: 'ext_deep_work_1',
        title: '<b>Deep Work:</b>   Rules for Focused Success',
        authors: [{ name: 'Newport, Cal (1982-)' }],
        imageLinks: { thumbnail: 'http://books.google.com/book.jpg?edge=curl' },
      }]
      : [],
    env: {
      NODE_ENV: 'test',
      JWT_ACCESS_SECRET: 'test-access-secret-with-at-least-thirty-two-bytes',
      JWT_REFRESH_SECRET: 'test-refresh-secret-with-at-least-thirty-two-bytes',
      OTP_HASH_SECRET: 'test-otp-secret-with-at-least-thirty-two-bytes',
      NOTIFICATION_SERVICE_TOKEN: 'test-notification-service-token',
      ALLOWED_ORIGINS: 'http://localhost:3000',
    },
    authOptions: {
      emailSender: async (message) => emailMessages.push(message),
      smsSender,
      identityVerifiers: {
        google: async (token) => {
          if (token !== 'valid-google-id-token') throw new Error('invalid token');
          return {
            subject: 'google_subject_01',
            email: 'google-reader@example.com',
            emailVerified: true,
            name: 'Google Reader',
          };
        },
        facebook: async (token) => {
          if (token !== 'valid-facebook-access-token') throw new Error('invalid token');
          return { subject: 'facebook_subject_01', email: null, emailVerified: false, name: 'Facebook Reader' };
        },
      },
      pushSender: async (payload) => {
        pushDeliveries.push(payload);
        return { sent: payload.tokens.length, failed: 0 };
      },
      now: () => currentTime,
      randomOtp: () => String(++otpCounter),
    },
  });

  const server = createServer();
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const baseUrl = `http://127.0.0.1:${server.address().port}/api/v1`;

  t.after(async () => {
    await new Promise((resolve) => server.close(resolve));
    fs.rmSync(tempDirectory, { recursive: true, force: true });
  });

  async function request(route, { method = 'POST', body, accessToken, serviceToken } = {}) {
    const headers = {};
    if (body !== undefined) headers['Content-Type'] = 'application/json';
    if (accessToken) headers.Authorization = `Bearer ${accessToken}`;
    if (serviceToken) headers['X-Service-Token'] = serviceToken;
    const response = await fetch(`${baseUrl}${route}`, {
      method,
      headers,
      ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
    });
    return { status: response.status, body: await response.json() };
  }

  await t.test('health/catalog remain available and no default account is seeded', async () => {
    const health = await request('/health', { method: 'GET' });
    assert.equal(health.status, 200);
    assert.ok(health.body.centralBooksCount >= 3);
    assert.equal((await store.getAllUserTrees()).length, 0);

    const catalog = await request('/books/search?q=Deep%20Work', { method: 'GET' });
    assert.equal(catalog.status, 200);
    assert.equal(catalog.body.source, 'external_api');
    assert.equal(catalog.body.results[0].author, 'Cal Newport');
  });

  let firstSession;
  let firstUserId;
  await t.test('email signup, hidden OTP, resend, Argon2id verification and session response', async () => {
    const signup = await request('/auth/signup', {
      body: {
        name: 'Reader One',
        contact: 'Reader.One@example.com',
        contactType: 'email',
        password: 'Correct-Horse-123',
      },
    });
    assert.equal(signup.status, 202);
    assert.deepEqual(Object.keys(signup.body).sort(), ['challengeId', 'expiresAt']);
    assert.ok(!JSON.stringify(signup.body).includes(emailMessages[0].code));

    const resent = await request('/auth/otp/resend', { body: { challengeId: signup.body.challengeId } });
    assert.equal(resent.status, 202);
    assert.equal(resent.body.challengeId, signup.body.challengeId);
    assert.ok(emailMessages.length >= 2);

    const verified = await request('/auth/otp/verify', {
      body: { challengeId: resent.body.challengeId, code: emailMessages.at(-1).code },
    });
    assert.equal(verified.status, 200);
    assert.ok(verified.body.accessToken);
    assert.ok(verified.body.refreshToken);
    assert.ok(verified.body.expiresAt);
    firstSession = verified.body;
    firstUserId = verified.body.userAccountTree.userId;
    assert.match(firstUserId, /^usr_[0-9a-f-]{36}$/);
    assert.equal(verified.body.userAccountTree.email, 'reader.one@example.com');
    assert.equal(verified.body.userAccountTree.authNode.passwordHash, undefined);
    assert.equal(verified.body.userAccountTree.authNode.verificationChallenge, undefined);
    assert.equal(verified.body.userAccountTree.authNode.refreshSessions, undefined);
    const stored = await store.findUserTree(firstUserId);
    assert.ok(stored.authNode.passwordHash.startsWith('$argon2id$'));

    const login = await request('/auth/login', {
      body: { contact: 'reader.one@example.com', contactType: 'email', password: 'Correct-Horse-123' },
    });
    assert.equal(login.status, 200);
    assert.ok(login.body.accessToken);
    const wrongPassword = await request('/auth/login', {
      body: { contact: 'reader.one@example.com', contactType: 'email', password: 'incorrect-password' },
    });
    assert.equal(wrongPassword.status, 401);
  });

  let phoneSession;
  await t.test('phone-only account has no synthetic email and contact lookup is typed', async () => {
    const signup = await request('/auth/signup', {
      body: {
        name: 'Phone Reader',
        contact: '+976 9911-2233',
        contactType: 'phone',
        email: 'optional@example.com',
        password: 'Phone-Reader-123',
      },
    });
    assert.equal(signup.status, 202);
    assert.equal(JSON.stringify(signup.body).includes(fixedSmsCode), false);
    assert.equal(smsMessages.at(-1).to, '+97699112233');

    const verified = await request('/auth/otp/verify', {
      body: { challengeId: signup.body.challengeId, code: fixedSmsCode },
    });
    assert.equal(verified.status, 200);
    phoneSession = verified.body;
    assert.equal(verified.body.userAccountTree.email, 'optional@example.com');
    assert.equal(verified.body.userAccountTree.authNode.emailVerified, false);
    assert.equal(verified.body.userAccountTree.profileNode.phoneNumber, '+97699112233');

    const stored = await store.findUserTree(verified.body.userAccountTree.userId);
    assert.equal(stored.email, 'optional@example.com');
    const emailLogin = await request('/auth/login', {
      body: { contact: 'optional@example.com', contactType: 'email', password: 'Phone-Reader-123' },
    });
    assert.equal(emailLogin.status, 403);
    const phoneLogin = await request('/auth/login', {
      body: { contact: '+97699112233', contactType: 'phone', password: 'Phone-Reader-123' },
    });
    assert.equal(phoneLogin.status, 200);

    const duplicatePhone = await request('/auth/signup', {
      body: {
        name: 'Duplicate',
        contact: '+97699112233',
        contactType: 'phone',
        password: 'Duplicate-Password-123',
      },
    });
    assert.equal(duplicatePhone.status, 409);
  });

  await t.test('user routes require a live bearer session scoped to its own userId', async () => {
    const noToken = await request(`/users/${firstUserId}/tree`, { method: 'GET' });
    assert.equal(noToken.status, 401);

    const ownTree = await request(`/users/${firstUserId}/tree`, {
      method: 'GET',
      accessToken: firstSession.accessToken,
    });
    assert.equal(ownTree.status, 200);
    assert.equal(ownTree.body.userAccountTree.userId, firstUserId);

    const otherAccount = await request(`/users/${phoneSession.userAccountTree.userId}/tree`, {
      method: 'GET',
      accessToken: firstSession.accessToken,
    });
    assert.equal(otherAccount.status, 403);

    const fakeXp = await request(`/users/${firstUserId}/tree`, {
      method: 'PUT',
      accessToken: firstSession.accessToken,
      body: { displayName: 'Changed Name', xpDelta: 99999 },
    });
    assert.equal(fakeXp.status, 400);
    assert.equal(fakeXp.body.error, 'server_managed_fields');

    const update = await request(`/users/${firstUserId}/tree`, {
      method: 'PUT',
      accessToken: firstSession.accessToken,
      body: { displayName: 'Reader One Updated', dailyGoalMinutes: 45, theme: 'dark' },
    });
    assert.equal(update.status, 200);
    assert.equal(update.body.userAccountTree.profileNode.displayName, 'Reader One Updated');
    assert.equal(update.body.userAccountTree.profileNode.preferencesNode.dailyGoalMinutes, 45);
  });

  await t.test('reading events persist canonical minutes and award XP at most once', async () => {
    const readingRoute = `/users/${firstUserId}/reading/events`;
    const event = {
      eventId: 'reading_event_001',
      book: { id: 'test-book-001', title: 'Test Book', author: 'Test Author' },
      minutesRead: 12,
      progress: 0.25,
      currentChapter: 1,
      currentPage: 20,
      highlight: { text: 'A useful excerpt', chapterIndex: 1 },
      note: { content: 'Read this again.' },
    };
    const saved = await request(readingRoute, {
      accessToken: firstSession.accessToken,
      body: event,
    });
    assert.equal(saved.status, 201);
    assert.equal(saved.body.earnedXp, 60);
    assert.equal(saved.body.readingStats.weeklyMinutesRead, 12);
    assert.equal(saved.body.readingStats.minutesReadToday, 12);
    assert.equal(saved.body.readingStats.totalXp, 60);
    assert.equal(saved.body.readingStats.currentStreak, 1);

    const duplicate = await request(readingRoute, { accessToken: firstSession.accessToken, body: event });
    assert.equal(duplicate.status, 200);
    assert.equal(duplicate.body.duplicate, true);
    assert.equal(duplicate.body.readingStats.totalXp, 60);
    assert.equal(duplicate.body.readingStats.weeklyMinutesRead, 12);

    const conflict = await request(readingRoute, {
      accessToken: firstSession.accessToken,
      body: { ...event, minutesRead: 13 },
    });
    assert.equal(conflict.status, 409);

    const zeroMinuteEvent = await request(readingRoute, {
      accessToken: firstSession.accessToken,
      body: { eventId: 'reading_event_zero', bookId: 'test-book-001', minutesRead: 0, progress: 0.25 },
    });
    assert.equal(zeroMinuteEvent.status, 201);
    assert.equal(zeroMinuteEvent.body.earnedXp, 0);
    assert.equal(zeroMinuteEvent.body.readingStats.totalXp, 60);
    assert.equal(zeroMinuteEvent.body.readingStats.weeklyMinutesRead, 12);

    const repeatedRequests = await Promise.all([
      request(readingRoute, {
        accessToken: firstSession.accessToken,
        body: { eventId: 'reading_event_002', bookId: 'test-book-001', minutesRead: 5, progress: 0.3 },
      }),
      request(readingRoute, {
        accessToken: firstSession.accessToken,
        body: { eventId: 'reading_event_002', bookId: 'test-book-001', minutesRead: 5, progress: 0.3 },
      }),
    ]);
    assert.deepEqual(repeatedRequests.map((item) => item.status).sort(), [200, 201]);
    const latest = await request(readingRoute, {
      accessToken: firstSession.accessToken,
      body: { eventId: 'reading_event_003', bookId: 'test-book-001', minutesRead: 0, progress: 0.3 },
    });
    assert.equal(latest.body.readingStats.totalXp, 85);
    assert.equal(latest.body.readingStats.weeklyMinutesRead, 17);

    const leaderboard = await request('/leaderboard?period=weekly', { method: 'GET' });
    assert.equal(leaderboard.status, 200);
    assert.equal(leaderboard.body.entries.length, 1);
    assert.equal(leaderboard.body.entries[0].xp, 85);
  });

  await t.test('refresh rotation, access revocation, logout, and provider token verification', async () => {
    const rotated = await request('/auth/refresh', { body: { refreshToken: firstSession.refreshToken } });
    assert.equal(rotated.status, 200);
    const oldAccess = await request(`/users/${firstUserId}/tree`, {
      method: 'GET',
      accessToken: firstSession.accessToken,
    });
    assert.equal(oldAccess.status, 401);
    const oldRefresh = await request('/auth/refresh', { body: { refreshToken: firstSession.refreshToken } });
    assert.equal(oldRefresh.status, 401);

    const google = await request('/auth/oauth/google', { body: { idToken: 'valid-google-id-token' } });
    assert.equal(google.status, 200);
    assert.equal(google.body.userAccountTree.email, 'google-reader@example.com');
    const invalidGoogle = await request('/auth/oauth/google', { body: { idToken: 'bad-token' } });
    assert.equal(invalidGoogle.status, 401);
    const facebook = await request('/auth/oauth/facebook', { body: { accessToken: 'valid-facebook-access-token' } });
    assert.equal(facebook.status, 200);
    assert.equal(facebook.body.userAccountTree.email, undefined);

    const catalogSync = await request('/books/sync', {
      accessToken: rotated.body.accessToken,
      body: { id: 'book_sync_test', title: 'A Synchronized Book', author: 'A. Writer' },
    });
    assert.equal(catalogSync.status, 201);
    const logout = await request('/auth/logout', {
      accessToken: rotated.body.accessToken,
      body: { refreshToken: rotated.body.refreshToken },
    });
    assert.equal(logout.status, 200);
    const revoked = await request(`/users/${firstUserId}/tree`, {
      method: 'GET',
      accessToken: rotated.body.accessToken,
    });
    assert.equal(revoked.status, 401);
  });

  await t.test('device token ownership moves between users and internal sends require service auth', async () => {
    const deviceToken = 'fcm_test_token_abcdefghijklmnopqrstuvwxyz_0123456789';
    const firstAccess = (await request('/auth/login', {
      body: { contact: 'reader.one@example.com', contactType: 'email', password: 'Correct-Horse-123' },
    })).body.accessToken;
    const phoneAccess = phoneSession.accessToken;
    const route = `/users/${firstUserId}/devices`;
    assert.deepEqual((await request(route, {
      accessToken: firstAccess,
      body: { token: deviceToken, platform: 'android' },
    })).body, { ok: true });
    const phoneId = phoneSession.userAccountTree.userId;
    assert.deepEqual((await request(`/users/${phoneId}/devices`, {
      accessToken: phoneAccess,
      body: { token: deviceToken, platform: 'ios' },
    })).body, { ok: true });

    assert.equal((await store.findUserTree(firstUserId)).notificationDevices.length, 0);
    assert.equal((await store.findUserTree(phoneId)).notificationDevices[0].platform, 'ios');
    const unauthorizedSend = await request('/internal/notifications/send', {
      body: { userId: phoneId, title: 'Hello', body: 'World' },
    });
    assert.equal(unauthorizedSend.status, 401);
    const send = await request('/internal/notifications/send', {
      serviceToken: 'test-notification-service-token',
      body: { userId: phoneId, title: 'Hello', body: 'World', data: { screen: 'home' } },
    });
    assert.deepEqual(send.body, { sent: 1, failed: 0 });
    assert.equal(pushDeliveries.at(-1).tokens[0], deviceToken);

    const removed = await request(`/users/${phoneId}/devices`, {
      method: 'DELETE',
      accessToken: phoneAccess,
      body: { token: deviceToken },
    });
    assert.deepEqual(removed.body, { ok: true });
    assert.equal((await store.findUserTree(phoneId)).notificationDevices.length, 0);
  });

  await t.test('password recovery is non-enumerating and invalidates sessions', async () => {
    const unknown = await request('/auth/password/forgot', {
      body: { contact: 'not-registered@example.com', contactType: 'email' },
    });
    const known = await request('/auth/password/forgot', {
      body: { contact: 'reader.one@example.com', contactType: 'email' },
    });
    assert.equal(unknown.status, 202);
    assert.equal(known.status, 202);
    assert.deepEqual(Object.keys(known.body).sort(), Object.keys(unknown.body).sort());
    assert.equal(emailMessages.at(-1).purpose, 'password_reset');

    const reset = await request('/auth/password/reset', {
      body: {
        challengeId: known.body.challengeId,
        code: emailMessages.at(-1).code,
        newPassword: 'New-Password-456',
      },
    });
    assert.deepEqual(reset.body, { status: 'password_reset' });
    const newLogin = await request('/auth/login', {
      body: { contact: 'reader.one@example.com', contactType: 'email', password: 'New-Password-456' },
    });
    assert.equal(newLogin.status, 200);
    const oldLogin = await request('/auth/login', {
      body: { contact: 'reader.one@example.com', contactType: 'email', password: 'Correct-Horse-123' },
    });
    assert.equal(oldLogin.status, 401);
  });

  await t.test('legacy email SHA-256 hashes migrate after correct login, default credentials do not work', async () => {
    const legacy = createDefaultUserAccountTree({ email: 'legacy@example.com', displayName: 'Legacy Reader' });
    legacy.authNode.passwordHash = hashLegacyPassword('Legacy-Password-123');
    legacy.authNode.emailVerified = false;
    await store.saveUserTree(legacy);

    const migrated = await request('/auth/login', {
      body: { contact: 'legacy@example.com', contactType: 'email', password: 'Legacy-Password-123' },
    });
    assert.equal(migrated.status, 200);
    const migratedTree = await store.findUserTree('legacy@example.com');
    assert.ok(migratedTree.authNode.passwordHash.startsWith('$argon2id$'));
    assert.equal(migratedTree.authNode.emailVerified, true);

    const defaultLogin = await request('/auth/login', {
      body: { contact: 'enkush@readpack.app', contactType: 'email', password: 'readpack123' },
    });
    assert.equal(defaultLogin.status, 401);
  });

  await t.test('OTP attempt limit and resend rotate the challenge secret without disclosing it', async () => {
    const signup = await request('/auth/signup', {
      body: {
        name: 'OTP Reader',
        contact: 'otp-reader@example.com',
        contactType: 'email',
        password: 'OTP-Reader-Password-123',
      },
    });
    for (let attempt = 0; attempt < 5; attempt += 1) {
      const wrong = await request('/auth/otp/verify', {
        body: { challengeId: signup.body.challengeId, code: '000000' },
      });
      assert.equal(wrong.status, 400);
    }
    const locked = await request('/auth/otp/verify', {
      body: { challengeId: signup.body.challengeId, code: emailMessages.at(-1).code },
    });
    assert.equal(locked.status, 429);

    const resent = await request('/auth/otp/resend', { body: { challengeId: signup.body.challengeId } });
    assert.equal(resent.status, 202);
    const verify = await request('/auth/otp/verify', {
      body: { challengeId: resent.body.challengeId, code: emailMessages.at(-1).code },
    });
    assert.equal(verify.status, 200);
  });
});
