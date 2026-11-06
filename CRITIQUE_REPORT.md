# 🚨 BRUTAL CODE, UI DESIGN & FINISH-GATE CRITIQUE REPORT (v5.0)
**App Name:** ReadPack (Mobile Reading App, Audio Narration & Reading Community)  
**Evaluators:** 
- `/agency-code-reviewer` (Principal Systems & Code Quality Engineer)
- `/agency-ui-designer` (Senior Visual Design Systems & Token Architect)
- `/agency-ui-finish-gate-reviewer` (Pre-Ship Finish-Gate & Product Specificity Owner)  
**Audit Date:** 2026-11-07  
**Audit Mode:** UNRESTRICTED FULL AUDIT (100% Comprehensive Issue Coverage)

---

## 1. Ерөнхий Дүн (Brutal Reality Check)

> **Finish-Gate Decision:** 🛑 **HOLD** (Ship Prohibited Until Critical Issues Are Fixed)  
> **Code Correctness & Stability:** **6.5 / 10**  
> **UI Visual Hierarchy & Platform Polish:** **6.8 / 10**  
> **Mobile User Experience & Finish Quality:** **6.0 / 10**

ReadPack нь өмнөх шатанд олон функц (аудио уншигч, 2 баганатай SliverGrid, 4 төрлийн хадгалах таб, MongoDB Express backend) амжилттай нэмэгдсэн боловч бодит хэрэглээний гүнзгий тестээр дараах **ноцтой алдаанууд (Blockers & Code Flaws)** илэрлээ:
1. **Зургийн системийн эмх замбараагүй байдал (Image Asset vs. Network URL Crash Risk):** Апп дотор зургийг нэгдсэн системгүйгээр хаа сайгүй `Image.asset(book.image!)` эсвэл `CachedNetworkImage(book.image!)` гэж дур зоргоороо ашигласнаас болж, гадны OpenLibrary/Gutendex-ийн сүлжээний номууд `Image.asset`-ээр нээгдэх үед Bundle Exception шидэх, эсрэгээрээ локал номууд `CachedNetworkImage`-ээр нээгдэхэд алдаа зааж эвдрэх аюултай байна.
2. **Зочин хэрэглэгчийг Тохиргооноос тусгаарласан (Guest Locked Out of Settings):** Профайл дээрх Тохиргооны товч `if (!profile.isGuest)` нөхцөлөөр бүрэн хаагдсан тул Зочин хүн Харанхуй/Цайвар горим солих, Хэл солих (Монгол/Англи), Оффлайн сан цэвэрлэх ямар ч боломжгүй түгжигдсэн байна.
3. **Дүрс ба Үйлдлийн логикийн зөрчил (Icon Mismatch):** Профайл дээр Тохиргоо (`Routes.settings`) нээдэг товч нь араа (Settings gear) биш харандаа (`Icons.edit_outlined`) дүрс тавьсан нь хэрэглэгчийг "Нэрээ засах нь" гэж андуурч төөрөлдүүлдэг.
4. **Уншигчийн HUD Ишлэл хадгалах логик гажиг (Reader HUD Bookmark Bug):** Уншигч дэлгэцийн дээд HUD дээрх Ишлэл хадгалах товч дарахад тухайн хэрэглэгчийн уншиж буй хэсгийг биш, тухайн бүлгийн хамгийн эхний догол мөрийг (`paragraphs[0]`) үргэлж авдаг алдаатай байна.
5. **Аудиогүй ном дээр Сөрөг Badge наасан (Negative "No Audio" Badge):** Номын дэлгэрэнгүй хуудсанд `#Аудиогүй` (`Icons.headset_off_rounded`) гэсэн сөрөг шошгыг голд нь байрлуулсан нь сөрөг сэтгэгдэл төрүүлж дизайны чанарыг унагааж байна.
6. **Уншигчийн хуудасласан горимын зай ашиглалт муу (Wasted Reading Viewport):** Хуудаслах горимд хуудас бүрийн дээр 76px зай + Бүлгийн гарчиг + Зохиолчийг давтан харуулж, утасны дэлгэцийн 25%-ийг дэмий үрж байна.
7. **Хөвөгч Үргэлжлүүлэн унших карт бусад цонхыг хаадаг (Obtrusive Floating Modal):** Үргэлжлүүлэн унших карт нь зөвхөн Нүүр хуудас биш, Хайлт, Миний Сан, Профайл дээр ч доороос нь хөвж навигаци болон контентыг таглаж байна.
8. **Орчуулгын системээс гадуур үлдсэн 25+ хатуу бичигдсэн текстүүд (Hardcoded Strings):** `ReadingSchedulePage`, `LibraryCollectionDialogs`, `HomeQuoteBanner` зэрэгт 20 гаруй текст шууд кодон дотор бичигдсэн тул Англи хэл дээр солигдохгүй байна.

---

## 2. Гурван Мэргэшсэн Өнцгийн Шүүмж

### А. `/agency-code-reviewer` Шүүмж (Code Correctness & Architecture)

1. 🔴 **Blocker: Unsafe Image Handling in Multiple Screens**
   - `book_detail_app_bar.dart:175`: `Image.asset(currentBook.image!)`
   - `continue_reading_card.dart:60`: `Image.asset(book.image!)`
   - `library_reading_card.dart:45`: `Image.asset(book.image!)`
   - `library_saved_card.dart:48`: `Image.asset(book.image!)`
   - `read_books_sheet.dart:148`: `CachedNetworkImage(imageUrl: book.image!)`
   - **Аюул:** Нэгдсэн абстракцгүйгээс болж сүлжээний URL бүхий ном орж ирэх үед `AssetBundle` ажиллахгүй Crash үүсгэнэ. Нэгдсэн `BookCoverImage` виджетээр шийдвэрлэх ёстой.
2. 🔴 **Blocker: Faulty Bookmark Extraction in Reader HUD (`reader_page.dart:366-371`)**
   - `onAddBookmark` дуудагдах үед:
     ```dart
     final quote = paragraphs.isNotEmpty ? paragraphs[0] : widget.book.title;
     _showHighlightModal(quote);
     ```
   - 20-р догол мөр дээр явж байгаад HUD дээрх Bookmark дарахад 1-р догол мөр хадгалагддаг. Одоогийн гүйлгэсэн байрлал эсвэл харагдаж буй догол мөрийг зөв тооцож авах ёстой.
3. 🟡 **Suggestion: Layout Overflow in Reader Bottom HUD (`reader_hud_bars.dart:213`)**
   - `SizedBox(width: 160)` бүхий `LinearProgressIndicator` нь жижиг утас (320-360dp) эсвэл Text Scale өндөр үед Row overflow үүсгэдэг. `Expanded` болгох шаардлагатай.
4. 🟡 **Suggestion: Dead / Orphaned Code Removal**
   - `lib/features/profile/widgets/profile_settings_card.dart` болон `profile_retake_card.dart` файлууд төслийн хаана ч ашиглагдахгүй орхигдсон байна.
5. 🟡 **Suggestion: Untranslated Hardcoded Strings**
   - Олон дэлгэц дээр локализацийн түлхүүр ашиглалгүй шууд монгол текст бичсэн.

---

### Б. `/agency-ui-designer` Шүүмж (Design Systems & Tokens)

1. 🔴 **Blocker: Guest Accessibility to App-Level Settings**
   - Профайлын тохиргоо товч нь `!profile.isGuest` гэсэн нөхцөлөөр бүрэн нуугдсан. Зочин уншигч харанхуй өрөөнд уншиж байгаад Dark mode асаах, эсвэл хэл солих боломжийг хаасан нь UI/UX зарчмын том алдаа.
   - Дүрс нь харандаа биш `Icons.settings_outlined` байх ёстой.
2. 🟡 **Suggestion: Elimination of Anti-Pattern Negative Badges**
   - `#Аудиогүй` гэж улаан/саарал хасах тэмдэгтэй badge байрлуулах нь бүтээгдэхүүний өнгө төрхийг гутаадаг. Аудио байгаа номонд тод badge тавих нь зөв боловч аудиогүй номонд сөрөг тэмдэг тавихгүй байх нь Benchmark аппуудын (Apple Books, Audible) алтан стандарт юм.
3. 🟡 **Suggestion: Typography & Space Efficiency in Paginated Reader**
   - Ном унших үед хэрэглэгчийн анхаарал зөвхөн текстийн агуулгад төвлөрөх ёстой. Хуудас бүр дээр 76px хоосон зай, Бүлгийн нэр, Зохиолчийн нэрийг ахин дахин чихэх нь дэлгэцийн унших талбайг хулгайлж байна.
4. 🟡 **Suggestion: Floating Modal Isolation to Home Feed**
   - `app_shell.dart`-д байгаа `ContinueReadingCard` нь бүх 4 таб дээр гарч ирж байгаа нь `SavedPage` (Миний сан)-ийн "Уншиж буй" табтай давхардаж дэлгэцийг чихэлдүүлж байна.
5. 🟡 **Suggestion: Tappable Author Bibliography in Details Overview**
   - Номын тухай хэсэгт "Зохиогчийн бусад бүтээл" гэсэн жагсаалт харагддаг боловч дээр нь дарахад юу ч болдоггүй статик шошго байна. Дээр нь дарж тухайн ном руу үсрэх харилцан үйлдэл (interaction) нэмэх хэрэгтэй.

---

### В. `/agency-ui-finish-gate-reviewer` Шүүмж (Design Contract & Gate)

#### Screen Design Contracts & Criteria:
- **Reader Screen:**
  - *First-read:* Номын уншигдахуйц цэвэр фонт ба зай.
  - *Primary action:* Саадгүй унших, аудио тоглуулах, сонгосон хэсгээ дарж ишлэл хадгалах.
  - *Forbidden defaults:* Хуудас болгоны толгойд том гарчиг давтах, HUD-аас буруу ишлэл хадгалах, overflow үүсгэх.
- **Book Detail Screen:**
  - *First-read:* Номын албан ёсны хавтас зураг, үнэлгээ, тойм.
  - *Primary action:* Уншиж эхлэх / Үргэлжлүүлэн унших.
  - *Forbidden defaults:* Сөрөг `#Аудиогүй` шошго наах, сүлжээний зураг дээр Bundle crash өгөх, холбоотой номууд дарагдахгүй байх.
- **Profile & Settings:**
  - *First-read:* Зочин ба Нэвтэрсэн хэрэглэгчийн ялгаатай тодорхой картууд.
  - *Primary action:* Зочин үед нэвтрэх, бүртгэлтэй үед уншлагын ахицаа хянах; аль ч үед тохиргоо руу орох.
  - *Forbidden defaults:* Буруу харандаа дүрсээр тохиргоо нээх, зочны тохиргоог түгжих.

---

## 3. Бүрэн Шийдвэрлэх Ажлын Төлөвлөгөө (Unrestricted Action Plan)

Дараах 8 багц засварыг нэг бүрчлэн 100% гүйцэтгэнэ:

| # | Төрөл | Байршил | Согог | Шийдэл |
|---|---|---|---|---|
| 1 | **Image Robustness** | `lib/shared/widgets/book_cover_image.dart` | `Image.asset` нь сүлжээний зургийг дэмждэггүй, `CachedNetworkImage` нь asset зургийг дэмждэггүй | Нэгдсэн `BookCoverImage` виджет үүсгэж, `http` бол сүлжээнээс кэшлэх, `assets/` бол asset-аас унших, бусад үед загварлаг өнгөт ковер харуулах логикийг нэгтгэнэ. |
| 2 | **Settings Access** | `profile_header_card.dart` | Зочин үед тохиргоо бүрэн хаалттай, товчны дүрс харандаа байгаа | Тохиргооны товчийг бүх хэрэглэгчид (Зочин ба Нэвтэрсэн) нээлттэй болгож, дүрсийг `Icons.settings_outlined` болгоно. |
| 3 | **Reader HUD Logic** | `reader_page.dart` | HUD дээрх Ишлэл хадгалах товч үргэлж 1-р догол мөрийг авдаг | Одоогийн уншиж буй бодит байрлалын догол мөр/текстийг ухаалгаар тооцоолж хадгална. |
| 4 | **Reader Layout** | `reader_hud_bars.dart` | `SizedBox(width: 160)` дээр жижиг дэлгэц дээр overflow үүсдэг | Progress bar-ийг `Expanded(child: LinearProgressIndicator)` болгож уян хатан болгоно. |
| 5 | **Detail Polish** | `book_detail.dart`, `book_detail_overview_tab.dart` | Сөрөг `#Аудиогүй` badge, холбоотой номууд дарагддаггүй | Сөрөг `#Аудиогүй` шошгыг авч хаяна. Холбоотой номын шошгон дээр дарахад тухайн номын дэлгэрэнгүй хуудас руу шилждэг болгоно. |
| 6 | **Paginated Viewport** | `reader_page_view.dart` | Хуудас бүр дээр том толгой гарчиг давтагддаг | Хуудасласан горимд бүлгийн эхний хуудаснаас бусад хуудсын толгойн давхардлыг цэгцэлж унших зайг 25% нэмэгдүүлнэ. |
| 7 | **Floating Card Scope**| `app_shell.dart` | Үргэлжлүүлэн унших карт бүх 4 таб дээр гарч дэлгэц тагладаг | Зөвхөн Нүүр хуудас (`_selectedIndex == 0`) дээр л хөвж харагддаг болгоно. |
| 8 | **Localization 100%** | `assets/locales/mn.json`, `en.json`, `reading_schedule_page.dart` г.м | Хатуу бичигдсэн монгол текстүүд | Бүх дутуу текстийг монгол, англи хэл дээр нэмж, 100% `l10n?.t(...)` болгоно. |
