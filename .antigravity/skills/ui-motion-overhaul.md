# UI/UX & Motion Overhaul Skill
Одоо байгаа апп-ын дизайныг шинэчлэх эсвэл шинэ дэлгэц зурахдаа хуучин статик дизайныг халж, дараах токен ба физик хэмжээсийг ХАТУУ мөрд:

## 1. Scientific UI/UX Laws & Tokens (Material M3, Apple HIG, Refactoring UI, WCAG AA)
- **4px Grid System:** Дурын пиксел (`13px`, `19px`) ашиглахыг хориглоно. Зөвхөн `4px`-ийн үржвэр (`4, 8, 12, 16, 24, 32, 48px` буюу `p-1, p-2, p-3, p-4, p-6, p-8`) ашигла.
- **Touch Targets:** Бүх дарагддаг элемент хамгийн багадаа `44x44pt` (`48x48dp`) байна. Картын дугуйралт `16px` (`rounded-2xl`), товчлуур `12px` (`rounded-xl`).
- **Dynamic Color Palette & Contrast (> 4.5:1):**
  - Light Surface: Background `#F8FAFC`, Card `#FFFFFF`, Elevated Glass `rgba(255,255,255,0.85)` + blur.
  - Dark Surface: Background `#0F172A`, Card `#1E293B`, Border `#334155`.
  - Primary Brand: Default `#4F46E5`, Hover `#4338CA`, Active `#3730A3`, Disabled `#94A3B8` (`opacity-50`).
  - Text Hierarchy: Primary `#0F172A` (Dark: `#F8FAFC`), Secondary `#475569` (Dark: `#94A3B8`).
- **Complete Interactive States:** Бүх товч ба картууд заавал `Default`, `Hover`, `Active/Pressed`, `Focus`, `Disabled` гэсэн 5 төлөвтэй байна.

## 2. Physics-Based Motion Specs (NO Linear Easing on Movement)
Элементүүд гэнэт гарч ирэх (teleport) ёсгүй. Зөвхөн GPU-accelerated (`transform`, `opacity`) шинж чанарыг хөдөлгөнө:
| Элемент / Төлөв | Хугацаа (Duration) | Хурдатгал (Easing / Curve) | Өөрчлөгдөх шинж чанар (Properties) |
| :--- | :--- | :--- | :--- |
| Button / Card Tap | `150ms` | `cubic-bezier(0.2, 0, 0, 1)` | `transform: scale(0.96)`, `background-color` |
| Staggered List Enter | `250ms` (50ms delay) | `cubic-bezier(0.0, 0.0, 0.2, 1)` | `opacity: 0 -> 1`, `translateY(12px -> 0)` |
| Modal / Bottom Sheet | `280ms` | `cubic-bezier(0.32, 0.72, 0, 1)` | `translateY(100% -> 0)`, `opacity` |
| Skeleton Shimmer | `1600ms` (Infinite) | `linear` | `opacity: 0.4 -> 0.8` / shimmer gradient |

## 3. Overhaul Execution Steps (Хуучин апп шинэчлэх дараалал)
1. **Audit & Theme Setup:** Эхлээд прожектын одоогийн кодыг уншиж, нэгдсэн `theme` файл болон дахин ашиглагдах `AnimatedButton`, `AnimatedCard`, `SkeletonLoader` компонентуудыг үүсгэ.
2. **Screen-by-Screen Refactor:** Бизнес логик болон навигацийг эвдэлгүйгээр хуудас тус бүрийг шинэ өнгө, 4px grid, болон staggered анимаци руу нэг нэгээр нь хөрвүүл.
