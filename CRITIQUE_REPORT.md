# ReadPack — Brutal Product, UI/UX, Finish-Gate, Data QA & 6-Pillar Visual Audit Report (v6.0)

**Огноо:** 2026-11-08  
**Горим:** MODE C — Brutal Product & Feature Critic (Read-Only Code + 23 Real Device Screenshot Evidence Audit)  
**Аудитын бүрэлдэхүүн (5 Agent Role):**
1. **`/agency-ui-designer`** — Visual Design System, Hierarchy, Token Consistency & Component Polish
2. **`/agency-ui-finish-gate-reviewer`** — Design Contract, Anti-Slop Finish Gate & Ship/Hold Decision
3. **`/agency-gis-qa-engineer`** — Cross-Screen Data Integrity, Schema/State Consistency, Localization Completeness & Metadata QA
4. **`/gsd-ui-review`** — 6-Pillar Visual & Experience Audit (Copywriting, Visuals, Color, Typography, Spacing, Experience Design)
5. **`/agency-product-manager`** — Product Strategy, Core Value Loop, Retention Mechanics & Benchmark Comparison (*Apple Books, Kindle, Readwise Reader, Literal.club, Duolingo, Headspace*)

**Шалгасан бодит дэлгэцийн зургууд (`assets/App-images/`):** `photo_1_2026-11-08_17-17-44.jpg` — `photo_23_2026-11-08_17-17-44.jpg` (Нийт 23 бодит скриншот + эх код тулгалт).

---

## 1. 5 Агентын Нэгдсэн Үнэлгээ & Finish-Gate Шийдвэр

### 1.1 `/agency-ui-finish-gate-reviewer` — Шийдвэр: **HOLD (БҮТЭЭГДЭХҮҮНИЙГ ГАРГАХЫГ ТҮР ЗОГСООХ)**
* **Шалтгаан:** Апп нь өнгөц харахад олон дэлгэц, карт, графиктай мэт боловч бодит скриншотууд (`photo_1`–`photo_23`) болон эх кодыг тулгаж шалгахад **4 ноцтой Finish-Gate зөрчил** илэрсэн:
  1. **Cross-Screen Data Contradiction (Дэлгэц хоорондын тоон зөрүү):** Профайл дээрх `Уншлагын хэмнэл` (`photo_6`) болон `Уншлагын хуваарь` (`photo_2`, `photo_9`) хоёр өөр тоо харуулдаг (`Өглөө 35%` vs `14%`, `Орой 40%` vs `52%`, `225 мин` vs `285 мин`). Профайл дээрх `Алмазан лиг` (`photo_6`) болон `Сарын Лидерборд` (`photo_1`, `photo_11`) хоёр өөр өрсөлдөгчийн жагсаалт болон өөр байр (`#3` vs `#8`) харуулдаг.
  2. **Broken Localization in English Mode (`photo_1`, `photo_2`, `photo_3`, `photo_4`, `photo_6`, `photo_7`):** Англи хэл дээр шилжүүлэхэд `SettingsPage` (`photo_3`, `photo_7`), `PhoneWidgetSheet` (`photo_4`), `ProfileXpCard` (`photo_6`), `LeaderboardPage` (`photo_1`), `ReadingSchedulePage` (`photo_2`) дэлгэцүүдийн 50%–90% нь Монгол хэлээрээ үлддэг (`en.json`-д түлхүүр нь байхгүй эсвэл код дотор шууд Монгол текст хатуу бичсэн).
  3. **Severe Viewport Occlusion (Контент халхлалт):** `AppShell` (`photo_5`, `photo_21`) дээрх том улбар шар `ContinueReadingCard` нь Нүүр хуудасны номын жагсаалтын эхний эгнээг таглаж дардаг; `ReaderPage` (`photo_19`) дээрх `ReaderAudioBar` нь яг уншигдаж буй шар тодруулгатай өгүүлбэрийг дарж тагладаг; `SavedPage -> Ишлэлүүд` (`photo_14`) дээрх `[Утасны дэлгэцийн виджет]` товч нь `[Таалагдсан ❤️ (3)]` шүүлтүүрийг `"Т..."` болтол нь шахаж тасалдаг.
  4. **Simulated / Cheat Mechanics (Хуурамч функцууд):** Уншихгүйгээр товч дараад streak нэмдэг `"🔥 Өнөөдрийн цуврал +1"` (`photo_12`), дуу гаргадаггүй хиймэл секунд гүйлгэгч `Timer.periodic` аудио тоглуулагч (`photo_19`), татаж шинэчлэх бүрд хуурамч оноо (`+5 XP`) нэмдэг Лидерборд (`photo_1` vs `photo_11`), нэвтрэх талбарт бэлэн бичигдсэн `enkush@readpack.app` / `readpack123` (`photo_23`).

### 1.2 `/gsd-ui-review` — 6-Pillar Visual Audit Scorecard

| Багана (Pillar) | Оноо | Дүгнэлт ба Бодит Нотолгоо (`assets/App-images/`) |
| :--- | :---: | :--- |
| **1. Copywriting (Текст ба Орчуулга)** | **1.5 / 4** | Англи горимд `photo_1`, `photo_3`, `photo_4`, `photo_6`, `photo_7` дээр Монгол-Англи хэл холилдсон. Лидербордын шинэчлэгдэх хугацаа `00:00` болон `23:59` гэж зөрүүтэй. |
| **2. Visuals (Дүрслэл ба Зураг)** | **2.0 / 4** | `photo_5`, `photo_21` дээр `Deep Work` номын хавтас `"DEE / WOR"` болж тасарсан; `photo_20` дээр `The Hobbit` хавтасны нэр `"HOBBI"` болж одны (`⭐ 4.3`) доор дарагдсан; `photo_16` дээр ижил төстэй номууд зураггүй үсгэн дөрвөлжин (`D`, `T`, `1`, `S`) болсон. |
| **3. Color (Өнгө ба Контраст)** | **2.5 / 4** | Light/Dark суурь палитр аятайхан боловч `photo_5`, `photo_21` дээрх `ContinueReadingCard`-ын хурц улбар шар дэвсгэр болон `photo_16` дээрх `BookDetailAppBar`-ын цул улбар шар өнгө нь Dark/Light горимын аль алинтай нь зөрчилддөг. |
| **4. Typography (Типографик)** | **2.5 / 4** | `ReaderPage` (`photo_17`, `photo_19`) дээрх текст уншигдац сайн боловч `photo_14` дээр шүүлтүүр чип `"Т..."` болж тасарсан, `photo_2` дээр баганан графикийн оройн тоонууд (`45м`, `50м`, `60м`) AppBar-т хагас тайрагдсан. |
| **5. Spacing (Зай авалт ба Бүтэц)** | **2.0 / 4** | `photo_20` (`SearchPage`) дээр дэлгэцийн дээд 45%-ийг 2 давхар шүүлтүүр + хайлтын түүх эзэлдэг; `photo_7`, `photo_8` (`SettingsPage`) дээр Өдрийн зорилго 2 дараалсан картанд давхардсан; `photo_1`, `photo_2`, `photo_9`, `photo_11`, `photo_12` дээр бүтэн хуудасны AppBar доор илүүц bottom-sheet чирэх зураас (`drag pill`) орсон. |
| **6. Experience Design (UX ба Логик)** | **1.5 / 4** | Зочин хэрэглэгч (`photo_22`) Settings рүү орох товчгүй тул хэл/тема солих боломжгүй; Профайлын баруун дээд буланд Settings-ийн оронд харандаа (`Icons.edit_outlined`, `photo_6`) тавьсан; `SavedPage` толгой дээр `"8 ном"` гэхэд доод цэс дээр `"7"` гэж зөрдөг (`photo_14`, `photo_15`). |
| **НИЙТ ОНОО** | **12.0 / 24** | **Төлөв: NEEDS WORK / HOLD** |

---

## 2. `assets/App-images/` доторх 23 Screenshot тус бүрийн нарийвчилсан задлан шинжилгээ

### Бүлэг А: Лидерборд ба Gamification (`photo_1`, `photo_11`, `photo_12`)
* **`photo_1` (Dark Mode — Monthly Leaderboard in English) & `photo_11` (Light Mode — Сарын Лидерборд):**
  * **Хэлний холилдол (`photo_1`):** Дэлгэцийн гарчиг `"Monthly Leaderboard"`, `"Diamond League"`, `"Monthly Rankings"` гэж Англиар гарсан хэрнээ баруун дээд бейж нь `"22 өдөр үлдсэн"`, жагсаалтын баруун дээд тайлбар нь `"Доош татаж шинэчлэх"` гэж Монголоор гарсан. Шалтгаан: [`leaderboard_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/leaderboard/presentation/page/leaderboard_page.dart#L123) нь `gamification.days_remaining_month` болон [`L217`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/leaderboard/presentation/page/leaderboard_page.dart#L217) нь `gamification.pull_to_refresh_hint` түлхүүрийг хайдаг боловч [`en.json`](file:///home/enkush-3/Desktop/Git/ReadPack/assets/locales/en.json#L380-L398) дотор `days_left` гэж өөр нэрээр бичигдсэн, `pull_to_refresh_hint` огт байхгүй.
  * **Хуурамч Pull-to-Refresh оноо нэмэгдэл (`photo_1` vs `photo_11`):** `photo_11` дээр 1-р байр `Номин-Эрдэнэ 4820 XP`, 2-р байр `Тэмүүлэн Б. 4150 XP` байснаа `photo_1` дээр `4830 XP`, `4160 XP` болсон. Энэ нь серверээс шинэчлэгдсэн бус, [`leaderboard_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/leaderboard/presentation/page/leaderboard_page.dart#L46) дахь `final bonus = (_refreshSeed % 3) * 5;` гэх хуурамч томьёогоор татах бүрд +5 XP нэмдэг код юм.
  * **Профайл карт ба Лидерборд хуудасны өгөгдлийн зөрчил (`photo_6` vs `photo_1`/`photo_11`):** `photo_6` (`ProfileLeagueCard`, [`profile_league_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_league_card.dart#L36-L74)) дээр Алмазан лигийн эхний 3 байранд `1. Төмөрөө (1820 XP)`, `2. Ану-Үжин (1610 XP)`, `3. Enkush (1650 XP)` гэж (`1650 > 1610` байхад эрэмбэлээгүй!) харуулдаг бол, "Бүтэн жагсаалт харах" дараад ороход (`photo_1`, `photo_11`) огт өөр хүмүүс (`Номин-Эрдэнэ 4820 XP`, `Тэмүүлэн Б. 4150 XP` г.м.) гарч ирээд `Enkush (1650 XP)` **#8-р байр** руу унадаг!
  * **Илүүц Drag Handle (`photo_1`, `photo_11`):** Бүтэн `Scaffold` + `AppBar`-тай хуудас атлаа `AppBar`-ын яг доор bottom-sheet-ийн саарал зураас ([`leaderboard_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/leaderboard/presentation/page/leaderboard_page.dart#L168-L176)) зурсан.
* **`photo_12` (Light Mode — Цуврал өдөр / Streak Detail Page):**
  * **Хуурамч "+1 Streak" товч (`photo_12`):** `"🔥 Өнөөдрийн цуврал +1"` товч ([`streak_detail_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/streak_detail_page.dart#L324-L361)) нь ном огт уншаагүй байсан ч дарахад л `bookProvider.incrementStreak()` дуудаж, цувралыг +1 болгоод, өнөөдөр уншсан минутыг хуурамчаар дүүргэж (`_minutesReadToday = _dailyGoalMinutes`), +50 XP бэлэглэдэг! (`photo_21` дээр `0 хоног` байснаа 1 минутын дараа `photo_12` дээр `4 ӨДӨР` болсон).
  * **Бодит хуанли бус 28 нүд (`photo_12`):** `"Сүүлийн 4 долоо хоног"` ([`streak_detail_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/streak_detail_page.dart#L540)) нь тухайн сарын бодит өдөр, гарагийг огт тооцдоггүй — үргэлж `1..28` гэсэн тоог Даваа гарагаас эхлэн тавиад, эхний `currentStreak` ширхэг нүдийг (`1, 2, 3, 4`) улбар шараар буддаг.

### Бүлэг Б: Уншлагын хуваарь ба Профайл (`photo_2`, `photo_6`, `photo_9`, `photo_22`)
* **`photo_2` (Dark Mode — Reading Schedule) & `photo_9` (Light Mode — Уншлагын хуваарь):**
  * **Графикийн оройн текст тайрагдсан ба Кирилл `"м"` үлдсэн (`photo_2`):** `photo_2` дээр долоо хоногийн баганан графикийн орой дээрх `35м`, `45м`, `50м`, `60м` гэсэн тоонууд `AppBar`-ын доогуур ороод тал нь тайрагдсан харагдаж байна. Мөн Англи хэл дээр байхад `"min"` биш Кирилл `"м"` гарсан нь [`reading_schedule_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/reading_schedule_page.dart#L214) дотор `l10n?.t('book.minutes_short') ?? 'м'` гэж буруу түлхүүр (`common.minutes_short`-ийн оронд) дуудсантай холбоотой.
  * **Профайл болон Хуваарь хуудасны тоон зөрчил (`photo_6` vs `photo_2`/`photo_9`):**
    * `photo_6` (`ProfileHabitsCard`, [`profile_habits_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_habits_card.dart#L69-L99)): `Morning 35%`, `Afternoon 25%`, `Evening 40%`; Долоо хоногийн багана: `30, 25, 40, 20, 35, 45, 30` (Нийт 225 мин).
    * `photo_2` & `photo_9` (`ReadingSchedulePage`, [`reading_schedule_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/reading_schedule_page.dart#L18-L26)): `Орой 52%`, `Өдөр 26%`, `Өглөө 14%`, `Шөнө 8%`; Долоо хоногийн багана: `35, 45, 25, 40, 50, 60, 30` (Нийт 285 мин).
    * Хоёулаа `BookProvider`-ын бодит уншлагаас огт хамааралгүй, код дотор гараар бичсэн хоёр өөр хуурамч тоо!
  * **Хадгалагддаггүй Сануулга (`photo_2`, `photo_9`):** `Уншлагын сануулга` (`20:00`) болон Switch нь зөвхөн `ReadingSchedulePage`-ийн локал хувьсагч (`_selectedHour = 20`, `_remindersEnabled = true`) тул хуудаснаас гараад ороход буцаад анхны утгандаа ордог, ямар ч локал нотификаци үүсгэдэггүй.
* **`photo_6` (Dark Mode — Profile Page in English) & `photo_22` (Light Mode — Зочин Профайл):**
  * **Зочин хэрэглэгч Тохиргоо (Settings) руу орох эрхгүй (`photo_22`):** [`profile_header_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_header_card.dart#L99) дээр `if (!profile.isGuest)` гээд Settings товчийг нуучихсан! Үүний улмаас Зочин хэрэглэгч (`photo_22`) харанхуй/цайвар горим солих, хэл солих, өдрийн зорилго өөрчлөх ямар ч боломжгүй мухардалд орсон.
  * **Буруу آйкон (`photo_6`):** `ProfileHeaderCard`-ын баруун дээд товч нь `SettingsPage` рүү үсэрдэг хэрнээ `Icons.edit_outlined` (харандаа) айконтой ([`profile_header_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_header_card.dart#L110)). Харин аватар дээр дарахад `ProfileEditDialog` нээгддэг.
  * **Англи горим дахь Монгол текстүүд (`photo_6`):** `ProfileXpCard` дээр `"Номын хорхойтон (Lv. 3)"` болон `"Дараагийн цолд 1350 XP дутуу"` ([`profile_xp_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_xp_card.dart#L158)) гэж Монголоор хэвээрээ байна.
  * **Мэдрэмжгүй хурууны айкон (`photo_6`):** `Books Read` болон `Day Streak` картууд дээр `Icons.touch_app_rounded` ([`profile_achievements_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_achievements_card.dart#L340)) гэсэн хурууны дүрс тавьсан нь орчин үеийн цэвэрхэн UI стандарттай нийцэхгүй.

### Бүлэг В: Тохиргоо ба Утасны Виджет (`photo_3`, `photo_4`, `photo_7`, `photo_8`, `photo_10`, `photo_13`)
* **`photo_3` (Dark Mode — Settings + Edit Profile Modal), `photo_7` (Light Mode — Settings in English), `photo_8` & `photo_10` (Light Mode — Settings in Mongolian):**
  * **Settings хуудасны Англи орчуулга бүрэн эвдэрсэн (`photo_3`, `photo_7`):** Хэлийг `English` болгосон (`photo_7` дээр `Language -> English` идэвхтэй харагдаж байна) ч `SettingsPage` дээрх бараг бүх карт Монголоороо байна:
    * `"Профайл & Бүртгэл"`, `"Бүртгэлтэй"`, `"Профайл зураг & мэдээлэл засах"`, `"Зорилго & Сонирхол шинэчлэх"`, `"30 минут/өдөр"`, `"15 мин / 30 мин / 45 мин / 60 мин"`, `"Сонирхсон төрлүүд: Бизнес, Хувь хүний хөгжил..."`, `"Өнгөний горим (Theme)"`, `"Утасны дэлгэцийн виджет"`, `"Ишлэлийн виджет тохируулах"`.
    * **Шалтгаан:** [`settings_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/settings/presentation/page/settings_page.dart) доторх `settings.profile_account`, `settings.registered_badge`, `settings.edit_profile_title`, `settings.update_goals_interests`, `settings.theme_mode_title`, `settings.phone_widget_section`, `settings.configure_widget` гэх мэт түлхүүрүүд `en.json` болон `mn.json` дотор **огт үүсээгүй**! Мөн жанрын чипүүд ([`settings_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/settings/presentation/page/settings_page.dart#L369-L375)) шууд Монгол текстээр хатуу бичигдсэн.
  * **Өдрийн зорилго (Daily Goal) тохируулагч 3 газар давхардсан (`photo_3`, `photo_7`, `photo_8`, `photo_10`):**
    1. `SettingsPage` дээрх `ProfileChallengeCard` (`Өдрийн зорилго 30/30 минут` -> дарахад диалог нээгдэнэ).
    2. Яг түүний доорх `Зорилго & Сонирхол шинэчлэх` карт доторх `[15 мин] [30 мин] [45 мин] [60 мин]` чипүүд.
    3. `Edit Profile` модал (`photo_3`) доторх `Daily Goal [15 мин] [30 мин] [45 мин] [60 мин]` чипүүд.
* **`photo_4` (Dark Mode — Home Screen Quote Widget in English) & `photo_13` (Light Mode — Утасны дэлгэцийн виджет):**
  * **Англи орчуулга огт ажиллахгүй (`photo_4`):** Гарчиг нь `"Home Screen Quote Widget"` боловч доторх бүх текст (`"Утасны дэлгэц дээр харагдах байдал:"`, `"📌 ХАДГАЛСАН ИШЛЭЛ"`, `"Виджетэд гаргах ишлэл:"`, `"Өдрийн ишлэл"`, `"Хадгалсан (5)"`, `"Виджетийн хэмжээ:"`, `"Жижиг (2x2)"`, `"Дунд (4x2)"`, `"Том (4x4)"`, `"Утасны виджетэд тохируулах"`) Монголоороо үлдсэн. Шалтгаан: [`phone_widget_sheet.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/quotes/presentation/phone_widget_sheet.dart) нь `en.json`-д байгаа түлхүүрүүдийг (`widget.subtitle`, `widget.daily_quote`, `widget.my_quotes`, `widget.apply_btn`) бус, огт байхгүй түлхүүрүүдийг (`widget.preview_label`, `widget.source_daily`, `widget.size_small`, `widget.apply_button`) дуудсан!
  * **Хэмжээ (`2x2`, `4x2`, `4x4`) сонгоход Preview хэлбэр өөрчлөгддөггүй (`photo_4`, `photo_13`):** `Том (4x4)` эсвэл `Жижиг (2x2)` сонгоход виджетийн хайрцаг яг ижилхэн хэвтээ гонзгой хэлбэртэй үлддэг (`maxLines` л өөрчлөгддөг).

### Бүлэг Г: Нүүр хуудас ба Хайлт (`photo_5`, `photo_20`, `photo_21`)
* **`photo_5` (Dark Mode — Home Page in English) & `photo_21` (Light Mode — Home Page in Mongolian):**
  * **`ContinueReadingCard` номын жагсаалтыг тагласан (`photo_5`, `photo_21`):** [`app_shell.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/app_shell.dart#L103-L121) дотор `bottomNavigationBar` хэсэгт `BottomNavBar`-ын дээр 100px гаруй өндөртэй хурц улбар шар `ContinueReadingCard`-ыг давхарлаж тавьснаас болж `"All (20 books)"` / `"Бүгд (20 ном)"` хэсгийн эхний эгнээний номуудын зөвхөн оройн 15px хэсэг цухуйж харагдаж байна!
  * **`Featured Books` карт дээрх номын хавтас эвдэрсэн (`photo_5`, `photo_21`):** `Deep Work` номын хавтасны зураг хэт томруулж тайрагдсанаас (`BoxFit.cover`) `"DEE / WOR"` болж хоёр талаасаа тасарсан; `Atomic Habits` хавтасны дээд текст `"Business"` / `"Бизнес"` бейжтэй давхцсан.
* **`photo_20` (Light Mode — Хайх / Search Page):**
  * **Дэлгэцийн 45%-ийг эзэлсэн давхар шүүлтүүр ба Хайлтын түүх (`photo_20`):** Хэрэглэгч хайлтын талбар дээр огт дараагүй, зүгээр л ном үзэх гээд ороход: (1) Толгой хэсэг, (2) Хайлтын мөр, (3) Категорийн чип мөр, (4) Уншлагын хэмнэл (`Mood`) чип мөр, (5) `"Саяхан хайсан"` (`Atomic Habits X`, `1984 X`, `Clear Thinking X`, `Sapiens X`) бүгд зэрэг гарч ирээд дэлгэцийн бараг талыг дүүргэчихсэн.
  * **Хайлтын грид дэх номын хавтас тайрагдсан (`photo_20`):** Баруун дээд талын `The Hobbit` номын хавтасны `"THE HOBBIT"` бичиг дээрээсээ тал нь тайрагдаад `"HOBBI"` болчихсон, дээр нь `⭐ 4.3` бейж дарж суусан. Баруун доод талын номын хавтас ямар ч нэргүй улаан дэвсгэр харагдаж байна.

### Бүлэг Д: Миний Сан (`photo_14`, `photo_15`)
* **`photo_14` (Light Mode — Миний Сан -> Ишлэлүүд):**
  * **Шүүлтүүр чип шахагдаж тасарсан (`photo_14`):** `[Бүгд (5)] [Тэмдэглэсэн (2)] [Т...]` — 3 дахь шүүлтүүр болох `"Таалагдсан ❤️ (3)"` нь баруун талын `[Утасны дэлгэцийн виджет]` товчинд шахагдаад `"Т..."` болж унших боломжгүй болсон ([`saved_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/library/presentation/page/saved_page.dart#L354-L419)).
  * **Ишлэлийн тэмдэглэл (`note`) талбарын согог (`photo_14`):** Ишлэлүүд дээр `= Хувийн тэмдэглэл (заавал биш)` гэсэн текст жинхэнэ тэмдэглэл мэт хадгалагдчихсан эсвэл засах боломжгүй хуурамч input шиг харагдаж байна.
  * **Тооны зөрүү (`photo_14`, `photo_15`):** Дэлгэцийн баруун дээд буланд `"8 ном"` (`savedBooks.length + continueReadingBooks.length`) гэж байхад доод `BottomNavBar` дээрх `Хадгалсан` бейж `"7"` (`savedBooks.length`) гэж өөр тоо харуулж байна!
* **`photo_15` (Light Mode — Миний Сан -> Цуглуулгууд):**
  * **100% Хатуу кодлогдсон Монгол текст ([`library_shelves_view.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/library/widgets/library_shelves_view.dart)):** `'Татсан'`, `'Офлайн уншихаар татаж авсан номууд'`, `'+ Шинэ цуглуулга үүсгэх'`, `'Офлайн'`, `'ном татсан'`, `'ном агуулсан'` гээд нэг ч `l10n` орчуулгын түлхүүр ашиглаагүй.

### Бүлэг Е: Номын Дэлгэрэнгүй, Уншигч ба Нэвтрэх (`photo_16`, `photo_17`, `photo_18`, `photo_19`, `photo_23`)
* **`photo_16` (Light Mode — Book Detail -> Ижил төстэй):**
  * **Ижил төстэй номуудын зураг бүгд алга (`photo_16`):** `Deep Work`, `Thinking, Fast and Slow`, `The Art of War`, `1984`, `Steve Jobs`, `Meditations`, `Guns, Germs, and Steel`, `Sapiens` номуудын хавтасны зураг ачаалагдаагүйгээс бүгд `D`, `T`, `T`, `1`, `S`, `M`, `G`, `S` гэсэн үсэгтэй цул хайрцаг болсон.
  * **Доош гүйлгэхэд AppBar гарчиггүй ба Таб мөр алга болдог (`photo_16`):** Доош гүйлгэхэд дээд улбар шар `SliverAppBar` дээр номын нэр гарахгүй, мөн 4 таб (`Ерөнхий`, `Агуулга`, `Ишлэл`, `Ижил төстэй`) наалдаж үлдэхгүй (`SliverPersistentHeader` биш) дээшээ гүйгээд орчихдог.
* **`photo_17` (Reader Settings Sheet), `photo_18` (Reader Chapters Sheet), `photo_19` (Reader Audio Mode):**
  * **Аудио тоглуулагч нь уншиж буй өгүүлбэрийг дарж тагладаг (`photo_19`):** `ReaderAudioBar` нээлттэй үед шар тодруулгатай өгүүлбэр (`"make them more comfortable and rubbed alcohol"`) яг аудио тоглуулагчийн доор орж таглагддаг!
  * **Аудио тоглуулагчийн `10` vs `15` секундийн зөрүү ба Дуугүй Таймер (`photo_19`):** `photo_19` дээрх ухраах/урагшлуулах товчнууд нь `10` секундийн сумтай (`replay_10` / `forward_10`) эсвэл код дотор `15` секунд ([`reader_audio_bar.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/reader/widgets/reader_audio_bar.dart#L206-L263)) гээд зөрүүтэй, хамгийн гол нь **ямар ч бодит TTS эсвэл аудио дуу гардаггүй** (`Timer.periodic`-оор секунд гүйлгэдэг).
* **`photo_23` (Light Mode — Нэвтрэх / Sign In Page):**
  * **Бэлэн бичээстэй Имэйл ба Нууц үг (`photo_23`):** [`signin.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/auth/widgets/signin.dart#L25-L26) дотор `enkush@readpack.app` болон `readpack123` гэж шууд `TextEditingController(text: ...)` утга оноосон.
  * **"Нууц үг мартсан?" холбоос байхгүй (`photo_23`):** Орчуулгын файлд (`en.json:460`, `mn.json:460`) бэлэн байгаа ч UI дээр огт тавиагүй.

---

## 3. ЗАСАХ ШААРДЛАГАТАЙ ЗҮЙЛСИЙН ЖАГСААЛТ (Bugs, Visual Flaws, Localization & Data Contradictions)

1. **`SettingsPage` Англи орчуулгын дутуу түлхүүрүүд ба хатуу Монгол текстүүд (`photo_3`, `photo_7`):**
   - [`settings_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/settings/presentation/page/settings_page.dart) доторх бүх `settings.*` түлхүүрүүдийг [`en.json`](file:///home/enkush-3/Desktop/Git/ReadPack/assets/locales/en.json) болон [`mn.json`](file:///home/enkush-3/Desktop/Git/ReadPack/assets/locales/mn.json) файлд нэмэх, жанрын чипүүдийг (`Бизнес`, `Хувь хүний хөгжил` г.м.) локалчлах.
2. **`PhoneWidgetSheet` Англи орчуулгын түлхүүр зөрүү ба Preview хэмжээ (`photo_4`, `photo_13`):**
   - [`phone_widget_sheet.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/quotes/presentation/phone_widget_sheet.dart) доторх `widget.*` түлхүүрүүдийг `en.json`/`mn.json`-той нийцүүлэх, мөн `2x2` (квадрат), `4x2` (хэвтээ), `4x4` (том квадрат) сонгоход `_buildPhoneMockup` доторх виджетийн хэмжээ/харьцааг бодитоор өөрчилдөг болгох.
3. **`LeaderboardPage` ба `ProfileLeagueCard` хоорондын өгөгдөл ба орчуулгын зөрүү (`photo_1`, `photo_6`, `photo_11`):**
   - Нэгдсэн нэг өгөгдлийн эх сурвалж (`BookGamificationManager` эсвэл `BookProvider`) ашиглаж, оноогоор нь буурахаар (`b.xp.compareTo(a.xp)`) зөв эрэмбэлэх; `en.json` дотор `days_remaining_month` болон `pull_to_refresh_hint` түлхүүрүүдийг нэмэх; шинэчлэгдэх цагийг (`00:00` vs `23:59`) нэг мөр болгох.
4. **`ProfileHabitsCard` ба `ReadingSchedulePage` хоорондын статистик зөрүү (`photo_2`, `photo_6`, `photo_9`):**
   - Хоёр өөр хуурамч массив ашиглахыг болиулж, `BookProvider` дахь бодит уншсан минутын түүхээс тооцоолдог болгох; `ReadingSchedulePage` дээрх баганан графикийн дээд зайг (`padding`) нэмж `45м`, `50м`, `60м` тоонууд `AppBar`-т тайрагдахаас сэргийлэх; `book.minutes_short`-ийг `common.minutes_short` болгож засах.
5. **Зочин хэрэглэгчийн Settings товч нуугдсан ба Буруу харандаа айкон (`photo_6`, `photo_22`):**
   - [`profile_header_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_header_card.dart#L99-L115) дээрх `if (!profile.isGuest)` нөхцөлийг авч хаяж, Зочин хэрэглэгч ч Settings рүү орж хэл/тема солих боломжтой болгох; `Icons.edit_outlined` харандаа айконыг `Icons.settings_outlined` (араа) болгож засах.
6. **`ProfileXpCard` ба `ProfileGuestCard` дээрх хатуу Монгол текстүүд (`photo_6`):**
   - [`profile_xp_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_xp_card.dart#L158) болон [`profile_guest_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_guest_card.dart#L36-L43), мөн цолны нэршлийг (`Номын хорхойтон` г.м.) `l10n` түлхүүрт холбох.
7. **`SavedPage` (Миний Сан) дээрх шүүлтүүр тасарсан, тоо зөрсөн, орчуулга орхигдсон (`photo_14`, `photo_15`):**
   - `photo_14` дээрх `[Бүгд] [Тэмдэглэсэн] [Таалагдсан ❤️]` мөрнөөс `[Утасны дэлгэцийн виджет]` товчийг салгаж `"Т..."` тасралтыг засах.
   - `SavedPage` толгой дээрх `"8 ном"` болон `BottomNavBar` дээрх `"7"` бейжийн зөрүүг (`savedBooks` ба `continueReadingBooks`-ийн давхцлыг `Set`-ээр нэгтгэх эсвэл ижил тооцоолол ашиглах) засах.
   - [`library_shelves_view.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/library/widgets/library_shelves_view.dart) доторх бүх Монгол текстийг `l10n`-д холбох.
8. **Номын хавтасны зургууд тайрагдсан ба Ижил төстэй номуудын зураг алга болсон (`photo_5`, `photo_16`, `photo_20`, `photo_21`):**
   - `Featured Books` (`photo_5`, `photo_21`) болон `SearchPage` (`photo_20`) дээр хавтасны зургийг 2:3 харьцаатай харуулах, дээр нь давхарласан од/категори бейжийг хавтасны гарчиг таглахгүй байрлалд шилжүүлэх; `default_provider_data.dart` дахь 20 номын зургийн зам/URL-ыг шалгаж `photo_16` дээрх үсгэн placeholder-үүдийг бодит хавтастай болгох.
9. **`ReaderPage` дээрх `ReaderAudioBar` текстийг тагладаг ба Sleep Timer орчуулгагүй (`photo_19`):**
   - Аудио тоглуулагч нээлттэй үед `ReaderScrollView` болон `ReaderPageView`-ийн доод `padding`-ийг динамикаар нэмэгдүүлж (`_showAudioBar ? 220 : 100`), шар тодруулгатай өгүүлбэрийг дэлгэцийн төв рүү автоматаар гүйлгэх (`Scrollable.ensureVisible`); Sleep Timer-ийн текстийг `audio_ext.*` орчуулгын түлхүүрт холбох.

---

## 4. НЭМЖ САЙЖРУУЛАХ ЗҮЙЛС БА ХЭРХЭН САЙЖРУУЛАХ НАРИЙН САНАЛ (Enhancements & Architecture Blueprint)

1. **`ContinueReadingCard`-ыг `AppShell`-ээс салгаж, ухаалаг `Collapsible Mini-Player / Inline Shelf` болгох (`photo_5`, `photo_21`):**
   - **Одоогийн асуудал:** Доод цэсний дээр 100px өндөр хурц улбар шар карт байнга хадаас мэт тогтож, Нүүр хуудасны номуудыг тагладаг.
   - **Хэрхэн сайжруулах (Apple Books / Spotify загвар):**
     - Хувилбар А (Санал болгох): `ContinueReadingCard`-ыг `AppShell.bottomNavigationBar`-аас бүрэн аваад, `HomePage`-ийн `Featured Books` болон `Категори` хооронд цэвэрхэн `Glassmorphic / Surface` карт болгон байрлуулах.
     - Хувилбар Б: Хэрэв доод талд байлгах бол зөвхөн `52px` өндөртэй нимгэн `Mini-Bar` (`surfaceContainerHigh` өнгөтэй, зүүн талд жижиг `32x44` номын хавтас, голд номын нэр + нимгэн `LinearProgressIndicator`, баруун талд `Үргэлжлүүлэх` сум) болгож, хэрэглэгч доош гүйлгэхэд автоматаар нуугддаг (`AnimatedSlide`) болгох.
2. **`BookDetailPage` дээр `SliverPersistentHeader` (Наалддаг Таб Мөр) + Collapsed Title нэмэх (`photo_16`):**
   - Хэрэглэгч доош гүйлгэхэд `SliverAppBar` хураагдах үед номын нэр болон жижиг `Унших` товч `AppBar` дээр тодорч гарч ирдэг байх; `Ерөнхий | Агуулга | Ишлэл | Ижил төстэй` 4 таб нь `SliverPersistentHeader(pinned: true)` дотор байрлаж, доош гүйлгэсэн ч дээд талд наалдаж үлддэг байх.
3. **`SearchPage` (Хайлт) хуудсыг "Focused Search State" ба "Browse Catalog State" гэж 2 төлөвт хуваах (`photo_20`):**
   - Хэрэглэгч хайлтын талбар дээр дараагүй (Browse) үед `"Саяхан хайсан"` чипүүдийг нууж, Категори болон Хэмнэл (`Mood`) шүүлтүүрийг нэг мөрөнд (`FilterChip` + `Хэмнэл` dropdown/sheet) нэгтгэснээр номын жагсаалтад дэлгэцийн **80%+** зай чөлөөлөгдөнө.
   - Зөвхөн хайлтын `TextField` фокус авсан үед `"Саяхан хайсан"` болон `"Эрэлттэй хайлтууд"` жагсаалтыг харуулах.
4. **Ишлэлийн карт (`LibraryQuoteCard`) дээрх Тэмдэглэл засах ба Action товчнуудыг цэгцлэх (`photo_14`):**
   - Карт бүр дээр 4–5 товч (`Утасны виджет`, `Story карт`, `Хуулах`, `Ном үзэх`) 2 мөр болж задарч байгааг болиулж: үндсэн 2 товч (`Story карт`, `Ном руу очих`) үлдээгээд бусдыг (`Виджетэд тавих`, `Тэмдэглэл засах`, `Хуулах`, `Устгах`) цэвэрхэн `PopupMenuButton` (`...`) эсвэл доод sheet рүү оруулах.

---

## 5. ХИЙГДЭЭГҮЙ БОЛОВЧ ЗААВАЛ ХИЙГДЭХ ШААРДЛАГАТАЙ ЗҮЙЛС (Missing / Simulated Core Features)

1. **Бодит Text-to-Speech (TTS) / Аудио Тоглуулагч (`flutter_tts` эсвэл `just_audio`):**
   - Одоогийн [`reader_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/reader/presentation/page/reader_page.dart#L114-L132) болон [`book_detail.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/details/presentation/page/book_detail.dart#L59-L83) дахь `Timer.periodic` нь зөвхөн секунд гүйлгэдэг, ямар ч дуу гаргадаггүй. `flutter_tts` багцыг холбож өгүүлбэр бүрээр нь бодитоор уншуулах, уншиж буй өгүүлбэрийг (`_activeAudioSentenceIndex`) бодит TTS-ийн `onProgress` callback-аар тодруулах.
2. **Бодит Уншлагын Телеметри ба Өдрийн/Долоо хоногийн Статистик (`BookProvider`):**
   - Хэрэглэгч `ReaderPage` дотор унших үед зарцуулсан бодит минут болон цагийн бүсийг (`Өглөө 06-12`, `Өдөр 12-18`, `Орой 18-24`, `Шөнө 00-06`) огноотой нь (`Map<String, int> dailyReadingMinutesByDate`) `SharedPreferences` болон Backend-д хадгалах.
   - `ProfileHabitsCard` болон `ReadingSchedulePage` хоёулаа энэхүү бодит өгөгдлөөс графикаа зурдаг байх.
3. **Бодит Огноотой Хуанли ба Автомат Streak Систем (`StreakDetailPage`):**
   - `DateTime.now()` ашиглан сүүлийн 28 өдрийн бодит огноо, гарагийг тооцоолох; хэрэглэгч тухайн өдрийн уншлагын зорилгоо (`minutesReadToday >= dailyGoalMinutes`) эсвэл доод тал нь 5 минут бодитоор уншсан үед л тухайн өдрийн streak автоматаар идэвхждэг болгох.
4. **Уншлагын Сануулгын Хэлбэлзэлгүй Хадгалалт ба Локал Нотификаци (`ReadingSchedulePage`):**
   - Сонгосон цаг (`reminderHour`) болон идэвхтэй эсэхийг (`remindersEnabled`) `BookProvider` + `SharedPreferences`-д хадгалдаг болгох.
5. **Хадгалах сан ба Кэш цэвэрлэх хэсэг (`SettingsPage`):**
   - `BookProvider.clearCache()` болон офлайн татсан номуудын хэмжээг (`89.5 MB` г.м.) `SettingsPage` дээр харуулж, кэш болон татсан файлуудыг удирдах цэс нэмэх.
6. **Нууц үг сэргээх (`Forgot Password`) урсгал (`SignInPage`):**
   - `signin.dart` дээр "Нууц үг мартсан?" товч нэмж, имэйлээр сэргээх диалог/хуудас холбох.
7. **Ишлэл дээрх хувийн тэмдэглэлийг (`Bookmark.note`) засах/нэмэх боломж (`LibraryQuoteCard`):**
   - Хадгалсан ишлэл дээр дараад тэмдэглэл нэмэх, засах (`updateBookmarkNote`) функц нэмэх; хоосон үед placeholder текстийг өгөгдөл мэт харуулахгүй байх.

---

## 6. ХАСАХ ЗҮЙЛС БА ЯГ ЯАЖ, ХЭРХЭН ХАСАХ НАРИЙН ЗАДАРГАА (Surgical Code Removal Guide)

Доорх 11 элемент нь аппын UX-ийг эвдэж, давхардал үүсгэж, эсвэл хуурамч (cheat/slop) мэдрэмж төрүүлж байгаа тул кодоос **яг заасан файл, мөрөөр нь** мэс заслын аргаар хасна:

### Хасах зүйл 1: Уншихгүйгээр Streak нэмдэг `"🔥 Өнөөдрийн цуврал +1"` хуурамч товч (`photo_12`)
* **Яагаад хасах вэ:** Хэрэглэгч ном огт нээгээгүй байж товч дараад л өдрийн зорилгоо 100% биелүүлсэн болгож, +50 XP болон Streak авдаг нь уншлагын аппын үндсэн утгыг үгүй хийж байна.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/profile/presentation/page/streak_detail_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/streak_detail_page.dart#L194-L196) файлын `194–196`-р мөр дэх `_buildBoostStreakButton(context, colorScheme, isDark, bookProvider)` дуудлагыг болон [`322–363`-р мөр](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/streak_detail_page.dart#L322-L363) дэх `_buildBoostStreakButton` методыг бүхэлд нь устгана.
  2. Мөн файлын [`48–103`-р мөр](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/streak_detail_page.dart#L48-L103) дэх `_triggerStreakCelebration` функц дотроос `bookProvider.incrementStreak();` дуудлагыг хасаж, оронд нь `"Өнөөдрийн цувралаа хадгалахын тулд номоо үргэлжлүүлэн уншаарай"` гэсэн `"Ном унших"` CTA товч (дарахад `ReaderPage` рүү үсэрдэг) тавина.
  3. [`lib/core/providers/book_provider.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/core/providers/book_provider.dart#L240-L256) файлын `240–256`-р мөр дэх гараар streak нэмдэг `incrementStreak()` методыг устгаж, зөвхөн `addReadingMinutes(int minutes)` дотор өдрийн зорилго биелэхэд автоматаар streak нэмэгддэг логик үлдээнэ.

### Хасах зүйл 2: `AppShell.bottomNavigationBar` дотор хадагдсан аварга улбар шар `ContinueReadingCard` (`photo_5`, `photo_21`)
* **Яагаад хасах вэ:** Нүүр хуудасны номын жагсаалтын эхний эгнээг байнга таглаж дардаг, мөн хурц улбар шар өнгө нь Dark/Light горимтой зөрчилддөг.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/app_shell.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/app_shell.dart#L103-L121) файлын `28`-р мөр (`bool _showContinueReadingModal = true;`), `57–59`-р мөр, болон `103–121`-р мөр дэх `if (_selectedIndex == 0 && _showContinueReadingModal && continueReadingBook != null) Padding(child: ContinueReadingCard(...))` хэсгийг `bottomNavigationBar` Column-оос бүрэн хасна (`bottomNavigationBar: BottomNavBar(...)` л үлдэнэ).
  2. Оронд нь [`lib/features/home/presentation/page/home.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/home/presentation/page/home.dart) дотор `Featured Books` хэсгийн доор (эсвэл дээр) жагсаалтын нэг хэсэг (`SliverToBoxAdapter`) болгож оруулснаар ямар ч номыг таглахгүй, доош гүйлгэхэд хамт гүйдэг болно.

### Хасах зүйл 3: Бүтэн хуудаснууд (`Scaffold`) дээрх илүүц Bottom-Sheet Drag Pill болон `OverscrollNotification` pop listener (`photo_1`, `photo_2`, `photo_9`, `photo_11`, `photo_12`)
* **Яагаад хасах вэ:** `AppBar`-тай бүтэн хуудас хэрнээ bottom sheet шиг саарал чирэх зураастай, дээр нь хуудсыг дээш гүйлгээд тулгахад (`OverscrollNotification`) санамсаргүй хуудаснаас гарчихдаг (`Navigator.pop`).
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/leaderboard/presentation/page/leaderboard_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/leaderboard/presentation/page/leaderboard_page.dart#L163-L180): `163–180`-р мөр дэх `GestureDetector` + `Container(width: 42, height: 4)` хэсгийг устгах.
  2. [`lib/features/profile/presentation/page/reading_schedule_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/reading_schedule_page.dart#L59-L92): `59–66`-р мөр дэх `NotificationListener<OverscrollNotification>` wrapper болон `70–92`-р мөр дэх `GestureDetector` чирэх зураасыг устгах.
  3. [`lib/features/profile/presentation/page/streak_detail_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/streak_detail_page.dart#L132-L166): `132–139`-р мөр дэх `NotificationListener<OverscrollNotification>` болон `143–166`-р мөр дэх чирэх зураасыг устгах.
  4. [`lib/features/profile/presentation/page/user_level_detail_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/presentation/page/user_level_detail_page.dart#L57-L90): `57–64`-р мөр дэх `NotificationListener<OverscrollNotification>` болон `68–90`-р мөр дэх чирэх зураасыг устгах.

### Хасах зүйл 4: `SettingsPage` болон `ProfileEditDialog` доторх давхардсан "Өдрийн зорилго" (`Daily Goal`) сонгогчууд (`photo_3`, `photo_7`, `photo_8`, `photo_10`)
* **Яагаад хасах вэ:** Нэг ижил тохиргоо (`15 / 30 / 45 / 60 мин`) яг нэг дэлгэц дээр дараалсан 2 картанд + Edit Profile модал дотор нийт 3 удаа давтагдсан.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/profile/widgets/profile_edit_dialog.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_edit_dialog.dart#L196-L245) файлын `196–245`-р мөр дэх `Daily Goal` чип сонгогчийг болон `30`-р мөр дэх `_selectedGoal` хувьсагчийг устгана (`ProfileEditDialog` нь зөвхөн Нэр, Хэрэглэгчийн нэр, Төрсөн өдөр, Хүйс, Аватар засна).
  2. [`lib/features/settings/presentation/page/settings_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/settings/presentation/page/settings_page.dart#L298-L350) доторх `298–350`-р мөр (давхардсан `Өдрийн зорилго: 30 минут/өдөр [15 мин] [30 мин] [45 мин] [60 мин]`) хэсгийг хасаж, өдрийн болон жилийн зорилгыг яг дээр нь байгаа `ProfileChallengeCard` (`261`-р мөр) дотор нэгтгэж үлдээнэ; харин хоёр дахь картыг зөвхөн `"Сонирхсон төрлүүд (Favorite Genres)"` карт болгоно.

### Хасах зүйл 5: `BookDetailPage` дээрх тусдаа хуурамч `BookDetailAudioPlayer` (`lib/features/details/`)
* **Яагаад хасах вэ:** `BookDetailPage` болон `ReaderPage` хоёр тусдаа, хоорондоо синк хийдэггүй хуурамч таймер тоглуулагчтай байгаа нь архитектур болон UX-ийн хувьд буруу.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/details/presentation/page/book_detail.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/details/presentation/page/book_detail.dart) файлаас `14`-р мөр (`import book_detail_audio_player.dart`), `28–36`-р мөр (`_isListening`, `_isPlaying`, `_playbackSpeed`, `_currentSeconds`, `_totalSeconds`, `_audioTimer`), `53–84`-р мөр (`_toggleListenMode`, `_togglePlayPause`, `_startAudioTimer`), болон `241–276`-р мөр (`AnimatedCrossFade` -> `BookDetailAudioPlayer`) хэсгүүдийг бүхэлд нь устгана.
  2. `BookDetailHero` дээрх `"Сонсох"` (`onListenTap`) товчийг дарахад шууд `ReaderPage(book: widget.book, openAudioInitially: true)` рүү үсэрдэг болгоно.
  3. [`lib/features/details/widgets/book_detail_audio_player.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/details/widgets/book_detail_audio_player.dart) файлыг устгана.

### Хасах зүйл 6: `ProfileHeaderCard` дээрх `!profile.isGuest` хориг болон `Icons.edit_outlined` харандаа айкон (`photo_6`, `photo_22`)
* **Яагаад хасах вэ:** Зочин хэрэглэгчийг Settings рүү орох боломжгүй болгож, бүртгэлтэй хэрэглэгчид Settings товчийг "Засах" (харандаа) мэт буруу ойлгуулж байна.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/profile/widgets/profile_header_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_header_card.dart#L99-L115) файлын `99`-р мөр дэх `if (!profile.isGuest)` нөхцөлийг устгаж, бүх хэрэглэгчид Settings товчийг харуулна.
  2. Мөн `110`-р мөр дэх `Icons.edit_outlined`-ийг `Icons.settings_outlined` болгож солино.

### Хасах зүйл 7: `SignInPage` дээрх бэлэн бичигдсэн `enkush@readpack.app` / `readpack123` болон хуурамч Social Login (`photo_23`)
* **Яагаад хасах вэ:** Логин хуудсанд имэйл, нууц үгийг урьдчилан бөглөж гаргах нь бодит бүтээгдэхүүнд байж боломгүй согог.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/auth/widgets/signin.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/auth/widgets/signin.dart#L25-L26) файлын `25–26`-р мөрийг:
     ```dart
     final _emailController = TextEditingController();
     final _passwordController = TextEditingController();
     ```
     болгож цэвэрлэнэ (хэрэв туршилтын товч хэрэгтэй бол зөвхөн `kDebugMode` үед жижиг `"Demo Fill"` товч тавьж болно).

### Хасах зүйл 8: `SavedPage -> Ишлэлүүд` шүүлтүүрийн мөрөн дэх чихэлдсэн `[Утасны дэлгэцийн виджет]` товч ба карт бүрийн давхардсан товч (`photo_14`)
* **Яагаад хасах вэ:** Шүүлтүүр чипүүдийг шахаж `"Т..."` болгож тасалсан, мөн карт бүр дээр болон толгой дээр давхардсан.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/library/presentation/page/saved_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/library/presentation/page/saved_page.dart#L387-L417) файлын `387–417`-р мөр дэх `GestureDetector` (`Утасны дэлгэцийн виджет` товч)-ийг шүүлтүүрийн `Row`-оос хасна (эсвэл зөвхөн `Icons.widgets_outlined` айкон товч болгоно).
  2. [`lib/features/library/widgets/library_quote_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/library/widgets/library_quote_card.dart#L190-L225) файлын `190–225`-р мөр дэх `Wrap` дотроос илүүц товчнуудыг цөөлж, нэг мөрөнд багтах цэвэрхэн бүтэц рүү шилжүүлнэ.

### Хасах зүйл 9: `SearchPage` дээр хайлт хийгээгүй үед байнга харагддаг `"Саяхан хайсан"` (`SearchHistory`) хэсэг (`photo_20`)
* **Яагаад хасах вэ:** Ном үзэх орон зайг дээрээс нь шахаж 45% эзэлдэг.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/search/presentation/page/search.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/search/presentation/page/search.dart#L208-L241) файлын `208–241`-р мөр дэх `if (searchHistory.isNotEmpty && _searchQuery.isEmpty)` нөхцөлийг `if (_searchFocusNode.hasFocus && searchHistory.isNotEmpty && _searchQuery.isEmpty)` болгож өөрчлөөд, зөвхөн хайлтын мөр дээр дарсан үед л хайлтын түүхийг харуулна.

### Хасах зүйл 10: `LeaderboardPage` дээрх хуурамч `(_refreshSeed % 3) * 5` онооны инфляци болон `ProfileLeagueCard`-ын зөрүүтэй жагсаалт (`photo_1`, `photo_11`)
* **Яагаад хасах вэ:** Татах бүрд хуурамчаар оноо нэмдэг, Профайл дээр өөр хүмүүс харуулдаг.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/leaderboard/presentation/page/leaderboard_page.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/leaderboard/presentation/page/leaderboard_page.dart#L42-L46) файлын `42`-р мөр (`int _refreshSeed = 0;`) болон `46`-р мөр (`final bonus = (_refreshSeed % 3) * 5;`) хэсгийг устгана.
  2. [`lib/features/profile/widgets/profile_league_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_league_card.dart#L36-L74) доторх `36–74`-р мөр дэх тусдаа хуурамч жагсаалтыг устгаж, `LeaderboardPage`-тэй яг ижилхэн эрэмбэлэгдсэн жагсаалтын эхний 3 болон хэрэглэгчийн бодит байрыг харуулдаг болгоно.

### Хасах зүйл 11: `ProfileAchievementsCard` дээрх `Icons.touch_app_rounded` хурууны айкон (`photo_6`)
* **Яагаад хасах вэ:** Статистик карт дээр хурууны дүрс тавих нь хуучинсаг, бохир харагддаг.
* **Яг хаанаас, хэрхэн хасах вэ:**
  1. [`lib/features/profile/widgets/profile_achievements_card.dart`](file:///home/enkush-3/Desktop/Git/ReadPack/lib/features/profile/widgets/profile_achievements_card.dart#L338-L343) файлын `338–343`-р мөр дэх `Icons.touch_app_rounded`-ийг устгаж, оронд нь `Icons.chevron_right_rounded` (`size: 16`) болгоно.
