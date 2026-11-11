# ReadPack Backend API Contract

**Base path:** `/api/v1`
**Content type:** `application/json`
**Identity:** each account has a stable UUID-like `userId`; email is optional and phone numbers are stored in E.164 format.

All private account routes require `Authorization: Bearer <accessToken>`. Access tokens expire after 15 minutes. Refresh tokens expire after 30 days, rotate on every refresh, and are stored only as SHA-256 digests. Logging out or rotating a refresh token revokes its access session immediately.

## Authentication

### Create an account

`POST /auth/signup` accepts a primary email or phone contact. Phone-only accounts do not receive a synthetic email. A phone signup may include an optional email field; it remains unverified until a separate email verification is completed.

```json
{
  "name": "ReadPack Reader",
  "contact": "+97699112233",
  "contactType": "phone",
  "email": "reader@example.com",
  "password": "a-long-password"
}
```

`contactType` is `email` or `phone`; phone numbers must be E.164. Passwords must contain 8–128 characters. The response is `202 Accepted`:

```json
{
  "challengeId": "opaque-challenge-id",
  "expiresAt": "2026-11-12T02:10:00.000Z"
}
```

OTP values are never returned by the API. Email OTPs are HMAC-hashed in storage; SMS OTPs use Twilio Verify. Challenges expire after 10 minutes and allow five verification attempts.

### Resend signup OTP

`POST /auth/otp/resend` with `{ "challengeId": "opaque-challenge-id" }` returns `202` with the same response fields and a renewed expiry. It never returns the OTP. The challenge ID remains stable while its code is rotated.

### Verify signup OTP

`POST /auth/otp/verify` with `{ "challengeId": "opaque-challenge-id", "code": "123456" }` returns a session:

```json
{
  "accessToken": "<JWT>",
  "refreshToken": "<JWT>",
  "expiresAt": "2026-11-12T02:15:00.000Z",
  "userAccountTree": { "userId": "usr_<uuid>", "email": "reader@example.com" }
}
```

The response tree excludes password hashes, OTP challenge records, refresh-session hashes and push-device tokens.

### Sign in

`POST /auth/login` accepts an explicit contact type:

```json
{ "contact": "reader@example.com", "contactType": "email", "password": "a-long-password" }
```

It returns the same session shape as OTP verification. Incorrect credentials return `401`; an unverified new account returns `403`. Existing email/password accounts using the former SHA-256 format are checked against the supplied password and rehashed with Argon2id after a successful sign-in. This migration applies only to email/password authentication.

### Refresh and logout

- `POST /auth/refresh` with `{ "refreshToken": "<JWT>" }` returns a new session and revokes both the previous refresh token and its access session. Replaying the old refresh token returns `401`.
- `POST /auth/logout` requires a valid Bearer access token and `{ "refreshToken": "<current refresh JWT>" }`. It returns `{ "status": "logged_out" }` and revokes that session.

### Google and Facebook sign-in

- `POST /auth/oauth/google` accepts `{ "idToken": "<Google ID token>" }`. The server verifies signature, issuer, expiry and configured audience using `GOOGLE_CLIENT_IDS`.
- `POST /auth/oauth/facebook` accepts `{ "accessToken": "<Facebook user access token>" }`. The server checks token validity and app ownership with Facebook Graph before accepting the provider subject.

Provider tokens are never treated as ReadPack API access tokens. Verified Google email identities can be linked to an existing account; Facebook sign-in uses its verified provider subject and does not assume an email address.

### Password recovery

- `POST /auth/password/forgot` accepts `{ "contact": "...", "contactType": "email" }` or phone. It returns `202` with `{ "challengeId", "expiresAt" }`; the response has the same shape whether or not the account exists.
- `POST /auth/password/reset` accepts `{ "challengeId": "...", "code": "123456", "newPassword": "a-new-long-password" }` and returns `{ "status": "password_reset" }`. Password reset revokes existing refresh/access sessions.

## User data and reading

The `userId` in each account route must match the subject of the Bearer token. Email addresses cannot be used in place of `userId`.

- `GET /users/:userId/tree` returns `{ "userAccountTree": { ... } }`.
- `PUT /users/:userId/tree` updates `displayName`, `bio`, and preference fields (`language`, `theme`, `dailyGoalMinutes`, `yearlyBookGoal`, `favoriteGenres`, `notificationsEnabled`, `recommendationsEnabled`). It returns `{ "status": "updated", "userAccountTree": { ... } }`. Gamification values are server-managed; requests that include client-supplied XP fields are rejected with `400 server_managed_fields`.
- `POST /users/:userId/reading` saves a book/shelf/progress update. It accepts a `book` object or existing `bookId`, plus optional shelf, status, progress, chapter, page, highlight and note fields. It returns `{ "status": "synced", "centralBook": { ... }, "userAccountTree": { ... } }`.
- The same `POST /users/:userId/reading` endpoint records a reading event when the body includes a unique `eventId`. Example:

```json
{
  "eventId": "client-generated-unique-id",
  "bookId": "b_atomic_habits",
  "minutesRead": 12
}
```

Reading-event responses include the canonical weekly minutes, today's minutes, current streak and total XP:

```json
{
  "status": "synced",
  "duplicate": false,
  "eventId": "client-generated-unique-id",
  "earnedXp": 60,
  "readingStats": {
    "weeklyMinutesRead": 12,
    "minutesReadToday": 12,
    "totalXp": 60,
    "currentStreak": 1
  },
  "userAccountTree": { "userId": "usr_<uuid>" },
  "centralBook": { "id": "b_atomic_habits" }
}
```

The event's XP is `minutesRead × 5`; a zero-minute event earns zero XP. Repeating an identical `eventId` returns the prior result with `duplicate: true` and does not change XP, minutes or streak. Reusing it with different payload data returns `409 event_id_conflict`. Weekly minutes are derived from persisted reading events in the current UTC week.

`GET /leaderboard?period=weekly|monthly` returns `{ "entries": [...] }` from verified users' persisted reading events. The list is empty when no qualifying activity exists; no sample users are added.

## Push device registration

- `POST /users/:userId/devices` (Bearer protected) accepts `{ "token": "<FCM/APNs token>", "platform": "android" }` and returns `{ "ok": true }`. A token is owned by only one account; registering it under another account removes the previous association. Up to ten devices are retained per account.
- `DELETE /users/:userId/devices` with `{ "token": "<FCM/APNs token>" }` removes that user's registration and returns `{ "ok": true }`.
- `POST /internal/notifications/send` is server-to-server only and requires `X-Service-Token: <NOTIFICATION_SERVICE_TOKEN>`. Its body is `{ "userId", "title", "body", "data" }`; the response is `{ "sent": 0, "failed": 0 }` or Firebase's multicast counts.

## Catalog and health

- `GET /health` reports API health and cached catalog count.
- `GET /books/search?q=...` searches the shared catalog.
- `POST /books/sync` requires a valid Bearer token and accepts `{ "book": { ... } }` or a book object.

## Errors and deployment configuration

Errors use `{ "error": "machine_readable_code", "message": "Human-readable message." }`. Authentication, OTP and login actions are rate-limited. Production deployments must set independent high-entropy `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`, `OTP_HASH_SECRET`, database credentials and HTTPS API configuration. Email uses SMTP, SMS uses Twilio Verify, Google/Facebook use their provider credentials, and push uses Firebase Admin credentials. Keep real values outside the repository; `backend/.env.example` contains empty templates only.
