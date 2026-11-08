# ReadPack Mobile Backend Architecture & API Contract
**Хувилбар:** 1.0.0  
**Өгөгдлийн сан:** MongoDB (Document Tree Architecture)  
**Протокол:** RESTful JSON API + JWT Authentication  
**Офлайн зааг:** Татсан номууд (Downloaded Books) нь 100% төхөөрөмж дээр (SQLite/Hive/File Cache) офлайн хадгалагдах бөгөөд сервер рүү хадгалахгүй. Бусад бүх дата сервертэй синк хийгдэнэ.

---

## 1. MongoDB Document Tree (Модон шаталсан) загварчлал

MongoDB-ийн хамгийн том давуу тал бол реляцийн SQL шиг олон `JOIN` хийхгүйгээр хэрэглэгчийн датаг нэг үндсэн баримт (Document Tree) дотор nested объектуудаар хурдан бөгөөд оновчтой хадгалах боломж юм.

```
users (Collection)
└── User Document Tree
    ├── _id: ObjectId
    ├── identity: { username, fullName, email, phoneNumber, avatarUrl, isGuest, ... }
    ├── auth: { passwordHash, otpCode, otpExpiresAt, isVerified, refreshToken }
    ├── gamification: {
    │   ├── xp, level, title
    │   ├── streak: { current, longest, lastActiveDate, freezesRemaining }
    │   ├── league: { tier, rank, weeklyXp, seasonId }
    │   └── achievements: [ { id, title, icon, unlockedAt, progress } ]
    │   }
    ├── readingGoals: {
    │   ├── dailyMinutesGoal
    │   ├── yearlyBooksGoal
    │   ├── currentYearCompleted
    │   └── favoriteGenres: [ "Бизнес", "Хувь хүний хөгжил", ... ]
    │   }
    ├── habitsAndTelemetry: {
    │   ├── totalReadingMinutes
    │   ├── totalBooksCompleted
    │   ├── readingByHour: { "06": 12, "07": 45, "21": 60, ... }
    │   └── preferredTimeSlot: "morning" | "evening" | "night"
    │   }
    └── preferences: {
        ├── themeMode: "system" | "light" | "dark"
        ├── locale: "mn" | "en"
        └── notifications: { dailyReminder: bool, bookRecommendations: bool }
        }
```

### 1.1 `users` Document Tree Schema (JSON жишээ)
```json
{
  "_id": "672e185c8f8b394018d9e111",
  "username": "@enkush_reader",
  "fullName": "Энхтүвшин Б.",
  "email": "enkush@readpack.app",
  "phoneNumber": "+97699112233",
  "avatarUrl": "https://cdn.readpack.app/avatars/user123.jpg",
  "isGuest": false,
  "createdAt": "2026-01-15T08:00:00.000Z",
  "updatedAt": "2026-11-08T18:30:00.000Z",
  "auth": {
    "isVerified": true,
    "otpCode": null,
    "otpExpiresAt": null
  },
  "gamification": {
    "xp": 540,
    "level": 2,
    "title": "Хичээнгүй уншигч",
    "streak": {
      "current": 4,
      "longest": 12,
      "lastActiveDate": "2026-11-08",
      "freezesRemaining": 1
    },
    "league": {
      "tier": "Алмазан Лиг",
      "rank": 3,
      "weeklyXp": 240,
      "seasonId": "2026-11"
    },
    "achievements": [
      {
        "id": "ach_first_book",
        "title": "Анхны ном",
        "icon": "auto_stories",
        "unlockedAt": "2026-01-16T10:00:00.000Z",
        "progress": 1.0
      }
    ]
  },
  "readingGoals": {
    "dailyMinutesGoal": 20,
    "yearlyBooksGoal": 24,
    "currentYearCompleted": 8,
    "favoriteGenres": ["Бизнес", "Хувь хүний хөгжил", "Сэтгэл зүй"]
  },
  "habitsAndTelemetry": {
    "totalReadingMinutes": 680,
    "totalBooksCompleted": 8,
    "readingByHour": {
      "07": 45,
      "08": 60,
      "12": 25,
      "21": 120,
      "22": 90
    },
    "preferredTimeSlot": "evening"
  },
  "preferences": {
    "themeMode": "dark",
    "locale": "mn",
    "notifications": {
      "dailyReminder": true,
      "bookRecommendations": true
    }
  }
}
```

---

### 1.2 `user_reading_progress` Document Tree (Уншлагын явц ба Тэмдэглэлүүд)
Хэрэглэгчийн уншиж буй ном бүрийн явц, бүлгийн байршил, хавчуурга, онцолсон ишлэлүүдийг модон хэлбэрээр хадгална:

```json
{
  "_id": "672e185c8f8b394018d9e222",
  "userId": "672e185c8f8b394018d9e111",
  "bookId": "b_atomic_habits",
  "currentChapterIndex": 3,
  "scrollOffset": 420.5,
  "progressPercent": 0.45,
  "lastReadAt": "2026-11-08T18:45:00.000Z",
  "chaptersRead": [0, 1, 2],
  "bookmarks": [
    {
      "id": "bm_1700000001",
      "chapterIndex": 1,
      "quote": "Таны дадал зуршил бол таны хувь тавилангийн жижиг хэсгүүд юм.",
      "note": "Өдөр тутмын хэв маягтаа тусгах",
      "colorHex": "0xFFFFD54F",
      "createdAt": "2026-02-01T14:20:00.000Z"
    }
  ]
}
```

---

### 1.3 `user_collections` Document Tree (Хэрэглэгчийн сан ба тавиурууд)
```json
{
  "_id": "672e185c8f8b394018d9e333",
  "userId": "672e185c8f8b394018d9e111",
  "collections": [
    {
      "id": "c_saved",
      "name": "Хадгалсан номууд",
      "description": "Дараа уншихаар хадгалсан",
      "isDefault": true,
      "icon": "bookmark",
      "bookIds": ["b_atomic_habits", "b_deep_work", "b_psychology_money"],
      "updatedAt": "2026-11-08T18:00:00.000Z"
    },
    {
      "id": "c_favorites",
      "name": "Дуртай номууд",
      "description": "Хамгийн их таалагдсан",
      "isDefault": true,
      "icon": "favorite",
      "bookIds": ["b_atomic_habits"],
      "updatedAt": "2026-11-08T18:00:00.000Z"
    },
    {
      "id": "c_custom_business",
      "name": "Бизнес 2026",
      "description": "2026 онд хэрэгжүүлэх менежмент",
      "isDefault": false,
      "icon": "folder",
      "bookIds": ["b_good_to_great", "b_zero_to_one"],
      "updatedAt": "2026-11-05T12:00:00.000Z"
    }
  ]
}
```

> **Анхаарах дүрэм:**  
> `c_downloaded` (Татсан номууд) цуглуулга нь **Сервер рүү илгээгдэхгүй**. Мобайл төхөөрөмж өөрөө офлайн сандаа хадгалж, офлайн үед файл системээсээ шууд уншина.

---

### 1.4 `books` Catalog Tree (Серверээс түгээх номын сан)
```json
{
  "_id": "b_atomic_habits",
  "title": "Атомик дадлууд",
  "author": "Жэймс Клир",
  "category": "Хувь хүний хөгжил",
  "coverUrl": "https://cdn.readpack.app/covers/atomic_habits.jpg",
  "rating": 4.9,
  "reviewsCount": 128,
  "pages": 320,
  "hasAudio": true,
  "audioDurationMinutes": 45,
  "audioUrl": "https://cdn.readpack.app/audio/atomic_habits.mp3",
  "summary": "Өчүүхэн өөрчлөлтөөс гайхалтай үр дүн",
  "keyTakeaways": [
    "Өдөр бүр 1% сайжрах нь 1 жилийн дараа 37 дахин сайжирна",
    "Зорилгодоо бус өөрийн системдээ төвлөр"
  ],
  "chapters": [
    {
      "index": 0,
      "title": "Оршил: Миний түүх",
      "wordCount": 1450,
      "content": "Бүх зүйл нэгэн ахлах сургуулийн бейсболын бэлтгэл дээр эхэлсэн юм..."
    },
    {
      "index": 1,
      "title": "1-р бүлэг: Өчүүхэн зуршлын гайхамшигт хүч",
      "wordCount": 2100,
      "content": "Британийн дугуйн спортын холбоо 110 жилийн турш амжилт гаргаагүй байлаа..."
    }
  ],
  "reviews": [
    {
      "id": "rev_001",
      "userId": "672e185c8f8b394018d9e111",
      "userName": "Энхтүвшин Б.",
      "avatarUrl": "https://cdn.readpack.app/avatars/user123.jpg",
      "rating": 5.0,
      "comment": "Амьдралд маш ойрхон бодитой зөвлөмжүүдтэй ном байна.",
      "createdAt": "2026-10-12T11:20:00.000Z"
    }
  ]
}
```

---

## 2. REST API Endpoints Specification

Бүх хамгаалагдсан хүсэлтэд дараах HTTP Header шаардагдана:
`Authorization: Bearer <jwt_access_token>`

### 2.1 Баталгаажуулалт ба Бүртгэл (Authentication & OTP)

#### 1. Бүртгүүлэх (Sign Up)
- **POST** `/api/v1/auth/signup`
- **Request Body:**
```json
{
  "name": "Шинэ Уншигч",
  "contact": "newreader@readpack.app", // эсвэл "+97699112233"
  "password": "SecurePassword123!",
  "isPhone": false
}
```
- **Response `200 OK`:**
```json
{
  "status": "success",
  "message": "OTP баталгаажуулах код илгээгдлээ",
  "data": {
    "target": "newreader@readpack.app",
    "expiresInSeconds": 60
  }
}
```

#### 2. OTP Код баталгаажуулах (Verify OTP)
- **POST** `/api/v1/auth/verify-otp`
- **Request Body:**
```json
{
  "target": "newreader@readpack.app",
  "code": "123456",
  "purpose": "signup" // эсвэл "forgot_password"
}
```
- **Response `200 OK`:**
```json
{
  "status": "success",
  "message": "Баталгаажилт амжилттай",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "_id": "672e185c8f8b394018d9e111",
      "username": "@shine_unshigch",
      "fullName": "Шинэ Уншигч",
      "email": "newreader@readpack.app",
      "phoneNumber": "",
      "isGuest": false,
      "gamification": {
        "xp": 0,
        "level": 1,
        "title": "Эхлэн уншигч",
        "streak": { "current": 0, "longest": 0 }
      }
    }
  }
}
```

#### 3. OTP Дахин илгээх (Resend OTP)
- **POST** `/api/v1/auth/resend-otp`
- **Request Body:**
```json
{
  "target": "newreader@readpack.app"
}
```
- **Response `200 OK`:**
```json
{
  "status": "success",
  "message": "Шинэ код илгээгдлээ",
  "data": { "expiresInSeconds": 60 }
}
```

#### 4. Нэвтрэх (Sign In)
- **POST** `/api/v1/auth/signin`
- **Request Body:**
```json
{
  "login": "newreader@readpack.app", // email эсвэл phone
  "password": "SecurePassword123!"
}
```
- **Response `200 OK`:** JWT Tokens + User Document Tree.

#### 5. Нууц үг сэргээх хүсэлт (Forgot Password)
- **POST** `/api/v1/auth/forgot-password`
- **Request Body:** `{ "target": "newreader@readpack.app" }`
- **Response `200 OK`:** `{ "message": "Сэргээх код илгээгдлээ" }`

#### 6. Шинэ нууц үг тохируулах (Reset Password)
- **POST** `/api/v1/auth/reset-password`
- **Request Body:**
```json
{
  "target": "newreader@readpack.app",
  "otpCode": "123456",
  "newPassword": "NewSecurePassword456!"
}
```

---

### 2.2 Хэрэглэгчийн мэдээлэл ба Профайл (User Profile & Sync)

#### 1. Өөрийн мэдээллийг татах (Get My Profile)
- **GET** `/api/v1/users/me`
- **Response `200 OK`:** Бүх модон бүтцийн мэдээлэл (Gamification, Goals, Habits, Preferences).

#### 2. Профайл шинэчлэх (Update Profile)
- **PATCH** `/api/v1/users/me/profile`
- **Request Body:**
```json
{
  "fullName": "Энхтүвшин Бат",
  "username": "@enkush",
  "phoneNumber": "+97699112233",
  "avatarUrl": "https://..."
}
```

#### 3. Тохиргоо ба Мэдэгдэл шинэчлэх (Update Preferences)
- **PATCH** `/api/v1/users/me/preferences`
- **Request Body:**
```json
{
  "themeMode": "dark",
  "locale": "mn",
  "dailyReminder": true,
  "bookRecommendations": false,
  "favoriteGenres": ["Бизнес", "Түүх"]
}
```

---

### 2.3 Уншлагын явц ба Геймификаци (Reading & Gamification)

#### 1. Номын уншлагын явц хадгалах (Sync Reading Progress)
- **PUT** `/api/v1/users/me/progress/:bookId`
- **Request Body:**
```json
{
  "currentChapterIndex": 3,
  "scrollOffset": 450.0,
  "progressPercent": 0.45,
  "addedReadingMinutes": 15
}
```
- **Response `200 OK`:**
```json
{
  "status": "success",
  "data": {
    "xpEarned": 15,
    "currentXp": 555,
    "streak": 4,
    "dailyGoalCompleted": true
  }
}
```

#### 2. Сарын Лидерборд татах (Get Leaderboard)
- **GET** `/api/v1/gamification/leaderboard?league=diamond&limit=30`
- **Response `200 OK`:**
```json
{
  "status": "success",
  "data": {
    "myRank": 3,
    "league": "Алмазан Лиг",
    "daysRemaining": 18,
    "competitors": [
      { "rank": 1, "name": "Болдбаатар Т.", "xp": 1420, "avatarUrl": "..." },
      { "rank": 2, "name": "Анударь С.", "xp": 1180, "avatarUrl": "..." },
      { "rank": 3, "name": "Энхтүвшин Б.", "xp": 940, "avatarUrl": "..." }
    ]
  }
}
```

---

### 2.4 Номын сан ба Хайлт (Books Discovery & Search)

#### 1. Шилдэг ба Онцлох номууд (Featured Books)
- **GET** `/api/v1/books/featured`

#### 2. Номын нэгдсэн хайлт & Шүүлтүүр (Search & Filter)
- **GET** `/api/v1/books/search?q=зуршил&category=Бизнес&minRating=4.5&sortBy=rating`

#### 3. Номын дэлгэрэнгүй ба Бүлгүүд (Book Details with Chapters)
- **GET** `/api/v1/books/:id`

#### 4. Сэтгэгдэл / Үнэлгээ нэмэх (Add Book Review)
- **POST** `/api/v1/books/:id/reviews`
- **Request Body:**
```json
{
  "rating": 5.0,
  "comment": "Энэ номыг хүн бүр уншаасай гэж хүсэж байна!"
}
```

---

### 2.5 Мэдэгдлүүд (Notifications)

#### 1. Мэдэгдлийн жагсаалт (Get Notifications)
- **GET** `/api/v1/notifications?status=all` (status: `all` | `unread` | `archived`)

#### 2. Нэг мэдэгдлийг уншсанаар тэмдэглэх
- **PATCH** `/api/v1/notifications/:id/read`

#### 3. Бүх мэдэгдлийг уншсанаар тэмдэглэх
- **POST** `/api/v1/notifications/mark-all-read`

---

## 3. Мобайл апп (Frontend) болон Сервер (Backend) холболтын дүрмүүд

1. **Офлайн анхдагч зарчим (Offline First for Downloads):**
   - Номыг татаж авах үед (`provider.toggleDownloadBook(id)`) номын бүх текстийг SQLite/файлд бичнэ.
   - Сүлжээгүй үед мобайл апп ямар ч сервер хүсэлтгүйгээр номоо шууд уншина.
2. **Арын синк (Background Sync):**
   - Уншсан минут, нэмсэн хавчуурга, авсан XP-г сүлжээтэй болох үед `PUT /api/v1/users/me/progress/:bookId` руу batch байдлаар илгээнэ.
3. **Зочин горим (Guest Mode):**
   - Зочин хэрэглэгчийн дата локал SharedPreferences / Hive дээр хадгалагдана.
   - Зочин хэрэглэгч бүртгүүлэх үед (`POST /api/v1/auth/signup`) локал өгөгдлийг серверийн Document Tree-тэй нэгтгэнэ (Merge on SignUp).
