# ReadPack

ReadPack is a Flutter reading app with a bundled book catalog, a local library, reading progress, bookmarks, collections, search, profiles, reminders, and an optional account-backed API.

## Architecture

- The Flutter client is in **lib/**. It supports Mongolian and English, light and dark themes, and local guest use.
- Bundled book records and covers are in **assets/** and **lib/data/raw_data/**. Search can also use Open Library, Gutendex, and the configured backend catalog.
- The Node.js API is in **backend/**. It stores shared catalog and account data in MongoDB. Local development can explicitly enable the JSON fallback with **ALLOW_JSON_FALLBACK=true**; production always requires MongoDB.
- Reading state and preferences are persisted on the device. Session tokens use secure storage.

Use MongoDB for deployments that need durable shared data. The JSON fallback is intended for local development, not multi-instance production use.

## Requirements

- Flutter with Dart 3.12 or newer
- Node.js 20.12 or newer and npm
- Docker Compose, if you want the backend and MongoDB started as containers

## Run locally

### Start the backend

From the repository root:

~~~sh
cd backend
npm ci
cp .env.example .env
~~~

Edit **backend/.env** and set independent values for **JWT_ACCESS_SECRET**, **JWT_REFRESH_SECRET**, and **OTP_HASH_SECRET**. For local use, each can be generated with **openssl rand -base64 32**. Configure SMTP or Twilio as needed for account verification and password recovery. Provider setup is described in [docs/INTEGRATION_SETUP.md](docs/INTEGRATION_SETUP.md).

Start the API:

~~~sh
npm start
~~~

The API listens on port 4000 by default. Check it at **http://localhost:4000/api/v1/health**.

To start the backend with MongoDB in Docker instead, run this from **backend/**:

~~~sh
docker compose up --build
~~~

### Start the Flutter app

In a second terminal, from the repository root:

~~~sh
flutter pub get
flutter run --dart-define=READPACK_API_BASE_URL=http://10.0.2.2:4000/api/v1
~~~

**10.0.2.2** is the host machine address from an Android emulator. For an iOS simulator or desktop app, use **http://localhost:4000/api/v1**. A physical phone needs an API URL reachable on the local network. Deployed builds should use HTTPS.

Guest reading and the bundled catalog are available without an account. Account signup, sign-in, and cross-device sync need the backend; email, phone, social sign-in, and push delivery also need their provider credentials and platform configuration.

## Checks and Android build

~~~sh
flutter analyze
flutter test
flutter build apk --release --dart-define=READPACK_API_BASE_URL=https://api.example.com/api/v1
~~~

Backend tests run after backend dependencies are installed:

~~~sh
cd backend
npm test
~~~

## API and service setup

- [Backend API contract](docs/API_CONTRACT.md)
- [Provider credentials and platform setup](docs/INTEGRATION_SETUP.md)

SMTP enables email verification and password recovery; Twilio Verify enables phone verification. Google and Facebook sign-in require native client configuration as well as backend verification credentials. Push notifications require Firebase client configuration and a Firebase Admin service account. Local scheduled reminders do not require Firebase.

The reader uses device text-to-speech for text that is available in a book. Catalog metadata from external providers does not guarantee that the full book text or a prerecorded audiobook is available.
