# Flutter Online Book Reader — Implementation Plan

## Context

Энэхүү plan нь React/Web дээр хийгдсэн "Online Book Reader" аппын дизайныг Flutter mobile апп болгон хөрвүүлэх гарын авлага юм. Гол зорилго: web preview-тэй яг ижил visual fidelity (өнгө, font, layout, animation) Flutter дээр хэрэгжүүлэх.

---

## 1. Project Setup

```
flutter create book_reader
cd book_reader
```

### pubspec.yaml dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1          # Playfair Display, DM Sans, DM Mono
  provider: ^6.1.2              # ThemeProvider state management
  go_router: ^13.2.0            # Declarative routing
  cached_network_image: ^3.3.1  # Book cover image caching
  percent_indicator: ^4.2.3     # Circular + linear progress
  shared_preferences: ^2.2.3    # Theme preference persistence

dev_dependencies:
  flutter_lints: ^4.0.0
```

---

## 2. Project Structure

```
lib/
├── main.dart
├── app.dart                    # MaterialApp + ThemeProvider wrapper
├── core/
│   ├── theme/
│   │   ├── app_colors.dart     # All color tokens (dark + light)
│   │   ├── app_text_styles.dart
│   │   └── theme_provider.dart # ChangeNotifier, toggleTheme()
│   └── models/
│       ├── book.dart
│       └── bookmark.dart
├── data/
│   └── sample_data.dart        # books[], bookmarkedPages[] lists
├── screens/
│   ├── home/
│   │   └── home_screen.dart
│   ├── library/
│   │   └── library_screen.dart
│   ├── reading/
│   │   └── reading_screen.dart
│   ├── bookmarks/
│   │   └── bookmarks_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── search/
│   │   └── search_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── widgets/
    ├── phone_frame.dart          # Декоратив phone frame (web demo үед)
    ├── status_bar.dart
    ├── bottom_nav_bar.dart
    ├── book_card.dart
    ├── book_list_tile.dart
    ├── progress_ring.dart
    ├── genre_filter_chips.dart
    ├── continue_reading_card.dart
    └── reading_settings_sheet.dart
```

---

## 3. Color Tokens — `app_colors.dart`

```dart
class AppColorsDark {
  static const bgApp       = Color(0xFF050C1E);
  static const bgPhone     = Color(0xFF0D1530);
  static const bgCard      = Color(0xFF182350);
  static const bgCardAlt   = Color(0xFF1E2B55);
  static const textPrimary = Color(0xFFF4F0E8);
  static const textSecond  = Color(0xFF8B9DC3);
  static const textReader  = Color(0xFFD4CEBC);
  static const accent      = Color(0xFFC8A84B);
  static const border      = Color(0x0FFFFFFF);   // rgba white 6%
  static const highlight   = Color(0x33C8A84B);   // accent 20%
}

class AppColorsLight {
  static const bgApp       = Color(0xFFE5E7EB);
  static const bgPhone     = Color(0xFFF8F9FA);
  static const bgCard      = Color(0xFFFFFFFF);
  static const bgCardAlt   = Color(0xFFF0F2F5);
  static const textPrimary = Color(0xFF111827);
  static const textSecond  = Color(0xFF6B7280);
  static const textReader  = Color(0xFF374151);
  static const accent      = Color(0xFFB3913A);
  static const border      = Color(0x0F000000);
  static const highlight   = Color(0x4DC8A84B);
}
```

---

## 4. Typography — `app_text_styles.dart`

Google Fonts ашиглан:
```dart
// Playfair Display — заголвал, ном нэр
static TextStyle playfair({double size = 16, FontWeight weight = FontWeight.w600, Color? color}) =>
  GoogleFonts.playfairDisplay(fontSize: size, fontWeight: weight, color: color);

// DM Sans — UI label, body
static TextStyle dmSans({double size = 14, FontWeight weight = FontWeight.w400, Color? color}) =>
  GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color);

// DM Mono — тоо, хуудасны дугаар, статус
static TextStyle dmMono({double size = 11, Color? color}) =>
  GoogleFonts.dmMono(fontSize: size, color: color);
```

---

## 5. Navigation — `app.dart` + `go_router`

**Route структур:**
```dart
// Гол tab route-ууд
/home         → HomeScreen
/library      → LibraryScreen
/bookmarks    → BookmarksScreen
/profile      → ProfileScreen

// Full-screen overlay route-ууд
/search       → SearchScreen  (SlideTransition дээрээс)
/settings     → SettingsScreen
/reading/:id  → ReadingScreen (fade + slide transition)
```

**Bottom Nav** — `StatefulShellRoute` ашиглан tab state хадгалах.

`readingBookId` state-ийг `GoRouter` push-аар `/reading/:id` руу явуулна — tab nav харагдахгүй болно.

---

## 6. Screens Дэлгэрэнгүй

### 6.1 HomeScreen
**Widgets:**
- `StatusBar` (custom, цаг/battery/signal)
- `ContinueReadingCard` — gradient container, cover image, progress bar
- `GenreFilterChips` — horizontal scroll, active/inactive state
- Discover horizontal scroll list → `BookCard` (110px wide, 154px cover)
- "In Your Library" vertical list → `BookListTile`

**ContinueReadingCard:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [book.color, theme.bgCard],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: theme.highlight, width: 1),
  ),
)
```

### 6.2 LibraryScreen
- `GridView.builder` — crossAxisCount: 2, childAspectRatio: ~0.55
- Ном бүрт `ProgressRing` overlay (top-right), progress bar (bottom)
- `CachedNetworkImage` cover

### 6.3 ReadingScreen
**Layout:**
```
Column:
  ├── TopBar (back, title, bookmark + more buttons)
  ├── Expanded(ScrollView → reading text)
  └── ProgressBar footer
```

**Font size adjustment:** `setState` → `_fontSize` variable (12–24)

**Highlight text:** Custom `TextSpan` builder — `recognizer` + background color highlight on matching substring.

**BottomSheet (settings):** `showModalBottomSheet` with `DraggableScrollableSheet` —
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  builder: (_) => ReadingSettingsSheet(...),
);
```
`ReadingSettingsSheet` агуулна:
- Drag handle
- Font size +/- buttons
- 4-column grid: Justify / Dark / Light / Audio buttons
- Theme toggle → `context.read<ThemeProvider>().toggle()`

### 6.4 BookmarksScreen
- ListView → bookmark card:
  - Book cover (40×54) + title + chapter/page
  - Quote block with left gold border (`BorderSide(color: accent, width: 2)`)

### 6.5 ProfileScreen
- Avatar + name + 5-star row
- Reading goal progress bar
- `GridView` 2×2 stats
- Achievements list (earned/locked opacity)

### 6.6 SearchScreen
- `TextField` autofocus, custom decoration (rounded, bgCardAlt)
- `books.where(...)` live filter
- `BookListTile` results

### 6.7 SettingsScreen
- Dark theme toggle (`Switch` widget, custom colored)
- Account info rows

---

## 7. Key Widgets

### ProgressRing
```dart
// percent_indicator package ашиглах
CircularPercentIndicator(
  radius: 18.0,
  lineWidth: 3.0,
  percent: book.progress / 100,
  backgroundColor: theme.border,
  progressColor: theme.accent,
  circularStrokeCap: CircularStrokeCap.round,
)
```

### BottomNavBar
```dart
// Custom floating pill style
Container(
  margin: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: theme.bgCard,
    borderRadius: BorderRadius.circular(32),
    border: Border.all(color: theme.border),
    boxShadow: [BoxShadow(color: theme.highlight, blurRadius: 20)],
  ),
  child: Row(children: tabs.map(...).toList()),
)
```

---

## 8. Animations

| Web (Framer Motion) | Flutter эквивалент |
|---|---|
| Bottom sheet spring animation | `showModalBottomSheet` + `CurvedAnimation(Curves.easeOutBack)` |
| Theme 500ms transition | `AnimatedContainer` + `AnimatedDefaultTextStyle` |
| Progress bar width | `AnimatedContainer(duration: 600ms)` |
| Progress ring stroke | `TweenAnimationBuilder` |
| Tab switch | `AnimatedSwitcher` |

---

## 9. Data Layer

`lib/data/sample_data.dart` — JS-ийн `books[]` болон `bookmarkedPages[]` массивыг Dart `List<Book>` болгон хөрвүүлнэ. Production дээр `Hive` эсвэл `SQLite` ашиглаж local persistence нэмнэ.

---

## 10. ThemeProvider

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    // SharedPreferences-д хадгалах
  }
}
```

`MaterialApp.router` дээр:
```dart
themeMode: themeProvider.mode,
theme: _buildLightTheme(),
darkTheme: _buildDarkTheme(),
```

---

## 11. Verification (Шалгах аргачлал)

1. `flutter run` — debug build iOS Simulator / Android Emulator
2. Dark/light theme toggle ажиллах эсэх
3. Bottom nav бүх tab-д зөв navigate хийх эсэх
4. Reading screen нээгдэх, font size өөрчлөгдөх
5. Bottom sheet spring animation smooth эсэх
6. Search live filter ажиллах
7. Progress ring/bar утгаа зөв харуулах
8. `flutter build apk --release` алдаагүй compile болох

---

## 12. Хэрэгжүүлэх дараалал (Sprint дарааллаар)

1. **Project setup** — pubspec, folder structure, color tokens, text styles
2. **ThemeProvider + MaterialApp** — dark/light theme switch
3. **Data models + sample data**
4. **Bottom nav + routing** — tab shell
5. **HomeScreen** — ContinueReadingCard, GenreChips, Discover, Library list
6. **LibraryScreen** — grid view
7. **ReadingScreen** — text render, font controls, progress, bookmark
8. **ReadingSettingsSheet** — bottom sheet modal
9. **BookmarksScreen**
10. **ProfileScreen + SettingsScreen**
11. **SearchScreen**
12. **Polish** — animations, transitions, edge cases

