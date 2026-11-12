# ReadPack service setup

The app keeps provider credentials out of source control. Local reminders work without Firebase; push notifications and provider sign-in become available after their platform and backend settings are configured.

## API endpoint

Run the Flutter app with the HTTPS API root used by the deployment:

```sh
flutter run --dart-define=READPACK_API_BASE_URL=https://api.example.com/api/v1
```

The default `http://10.0.2.2:4000/api/v1` address is for an Android emulator talking to a local development server. iOS simulators and desktop builds use `localhost`. Release builds should set `READPACK_API_BASE_URL` to the deployed HTTPS URL.

## Backend credentials

Use Node.js 20.12 or later. Copy `backend/.env.example` to `backend/.env`, then configure the MongoDB connection and independent random secrets for access tokens, refresh tokens, OTP hashing, and internal notification requests. `npm start` loads this file automatically. Production refuses to start authenticated sessions when its JWT or OTP secrets are shorter than 32 bytes.

Generate a different value for each secret:

```sh
openssl rand -hex 32
```

Set only the providers the deployment uses:

- Email verification and password reset: `SMTP_HOST`, `SMTP_PORT`, `SMTP_SECURE`, `SMTP_FROM`, and SMTP credentials.
- Phone verification: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, and `TWILIO_VERIFY_SERVICE_SID`.
- Google identity verification: comma separated `GOOGLE_CLIENT_IDS` containing the authorized OAuth client IDs.
- Facebook identity verification: `FACEBOOK_APP_ID` and `FACEBOOK_APP_SECRET`.
- Push delivery: `FIREBASE_SERVICE_ACCOUNT_JSON` with the Firebase Admin service account JSON, serialized on one line.

Keep `backend/.env` outside Git and restrict service-account and provider credentials to the backend runtime.

## Google sign-in

Register the Android application ID and iOS bundle ID in Google Cloud OAuth. Include the Android signing certificate SHA fingerprints and create a Web OAuth client for backend token verification. Pass that Web client ID to Flutter:

```sh
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

Add the authorized Android client ID, iOS client ID, and Web client ID to backend `GOOGLE_CLIENT_IDS`. Social sign-in requires the native Google OAuth configuration for the target platform; it never falls back to a local account.

## Facebook sign-in

Configure a Facebook app, Android package/hash, iOS bundle ID, and the app's client token in Meta Developer settings. Supply Android values through Gradle properties or environment variables:

```sh
FACEBOOK_APP_ID=your-app-id \
FACEBOOK_CLIENT_TOKEN=your-client-token \
flutter run
```

For Xcode, copy `ios/Flutter/RunnerSecrets.xcconfig.example` to `ios/Flutter/RunnerSecrets.xcconfig` and set `FACEBOOK_APP_ID` and `FACEBOOK_CLIENT_TOKEN` there. That local file is ignored by Git. Configure the same app ID and app secret in the backend environment.

## Firebase Cloud Messaging

Register `com.example.readpact` and the iOS bundle ID with Firebase. Place the downloaded `google-services.json` at `android/app/google-services.json` and `GoogleService-Info.plist` at `ios/Runner/GoogleService-Info.plist`. Android applies the Google Services Gradle plugin when the JSON file exists. The files are ignored by Git; use the service account JSON only on the backend for push sends.

Firebase client setup is optional for local scheduled reminders. Device token registration and remote sends require Firebase client configuration, user notification permission, a signed-in account, and the backend Firebase Admin service account.

## Local services

Start MongoDB and the backend together with Docker Compose. Compose reads the optional `backend/.env`, waits for MongoDB to become healthy, and stores database files in its named volume:

```sh
cd backend
docker compose up --build -d
docker compose logs -f backend
```

To run the backend directly on your machine, configure `backend/.env`, install dependencies, and start the server:

```sh
cd backend
npm install
npm start
```

The backend falls back to its local JSON store if a MongoDB server is unreachable. The fallback store is development storage; use MongoDB for persistent deployments. Email and phone verification require SMTP or Twilio settings. Google/Facebook sign-in and remote push require their provider credentials. Those features return an explicit configuration error until the corresponding service is configured.

For a local Android emulator, the emulator reaches the host machine at `10.0.2.2`. Keep cleartext traffic restricted to the debug manifest and use HTTPS for deployed builds.
