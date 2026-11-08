import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class PhoneWidgetSheet extends StatefulWidget {
  final Bookmark? initialBookmark;

  const PhoneWidgetSheet({
    super.key,
    this.initialBookmark,
  });

  static void show(BuildContext context, {Bookmark? initialBookmark}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PhoneWidgetSheet(initialBookmark: initialBookmark),
    );
  }

  @override
  State<PhoneWidgetSheet> createState() => _PhoneWidgetSheetState();
}

class _PhoneWidgetSheetState extends State<PhoneWidgetSheet> {
  static const MethodChannel _widgetChannel =
      MethodChannel('com.example.readpact/widget');

  // 0: Quote of the Day, 1: Saved Quotes, 2: Specific Chosen Quote
  int _selectedSource = 0;
  // 0: Small (2x2), 1: Medium (4x2), 2: Large (4x4)
  int _selectedSize = 1;
  // 'system', 'light', 'dark'
  String _selectedThemeMode = 'system';
  Bookmark? _selectedCustomBookmark;

  @override
  void initState() {
    super.initState();
    if (widget.initialBookmark != null) {
      _selectedSource = 2;
      _selectedCustomBookmark = widget.initialBookmark;
    }
    _loadSavedWidgetSettings();
  }

  Future<void> _loadSavedWidgetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      if (widget.initialBookmark == null) {
        _selectedSource = prefs.getInt('widget_quote_mode') ?? 0;
      }
      _selectedSize = prefs.getInt('widget_quote_size') ?? 1;
      _selectedThemeMode =
          prefs.getString('widget_quote_theme_mode') ?? 'system';
      final savedBmId = prefs.getString('widget_quote_bookmark_id');
      if (widget.initialBookmark == null && savedBmId != null) {
        final provider = context.read<BookProvider>();
        final found =
            provider.bookmarks.where((b) => b.id == savedBmId).firstOrNull;
        if (found != null) {
          _selectedCustomBookmark = found;
        }
      }
    });
  }

  Future<void> _saveWidgetSettings({
    required String quoteText,
    required String quoteAuthor,
    required String quoteBook,
  }) async {
    final l10n = AppLocalizations.of(context);
    final prefs = await SharedPreferences.getInstance();
    final sourceStr = _selectedSource == 0
        ? 'daily'
        : (_selectedSource == 1 ? 'saved' : 'custom');

    await prefs.setInt('widget_quote_mode', _selectedSource);
    await prefs.setInt('widget_quote_size', _selectedSize);
    await prefs.setString('widget_quote_theme_mode', _selectedThemeMode);
    await prefs.setString('widget_quote_source', sourceStr);
    await prefs.setString('widget_quote_text', quoteText);
    await prefs.setString('widget_quote_author', quoteAuthor);
    await prefs.setString('widget_quote_book', quoteBook);

    // Also write legacy keys so any existing native reader stays in sync
    await prefs.setString('phone_widget_source', sourceStr);
    await prefs.setString('phone_widget_quote_text', quoteText);
    await prefs.setString('phone_widget_author', quoteAuthor);
    await prefs.setString('phone_widget_book', quoteBook);

    if (_selectedCustomBookmark != null) {
      await prefs.setString(
          'widget_quote_bookmark_id', _selectedCustomBookmark!.id);
    }

    try {
      await _widgetChannel.invokeMethod('updateWidget');
    } catch (_) {
      // Ignore on web/unit tests where native Android AppWidgetManager is absent
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.t('widget.saved_toast') ??
                'Утасны дэлгэцийн виджет амжилттай шинэчлэгдлээ! 📱',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);

    final dailyQuote = l10n?.t('home.daily_quote') ??
        'Ном уншдаг хүн үхэхээсээ өмнө мянган амьдралаар амьдардаг.';
    final dailyAuthor =
        l10n?.t('home.daily_quote_author') ?? 'Жорж Р.Р. Мартин';

    String previewQuote = dailyQuote;
    String previewAuthor = dailyAuthor;
    String previewBook = 'ReadPack';

    if (_selectedSource == 1) {
      if (bookProvider.bookmarks.isNotEmpty) {
        final bm = _selectedCustomBookmark ?? bookProvider.bookmarks.first;
        previewQuote = bm.quote;
        previewBook = bm.bookTitle.isNotEmpty ? bm.bookTitle : 'ReadPack';
        final matchingBook =
            bookProvider.books.where((b) => b.id == bm.bookId).firstOrNull;
        previewAuthor = matchingBook?.author ??
            (bm.chapterTitle.isNotEmpty ? bm.chapterTitle : previewBook);
      } else {
        previewQuote = l10n?.t('widget.no_saved_quotes') ??
            'Та одоогоор өөрийн ишлэл хадгалаагүй байна.';
        previewAuthor = 'ReadPack';
        previewBook = '';
      }
    } else if (_selectedSource == 2) {
      final bm = _selectedCustomBookmark ??
          (bookProvider.bookmarks.isNotEmpty
              ? bookProvider.bookmarks.first
              : null);
      if (bm != null) {
        previewQuote = bm.quote;
        previewBook = bm.bookTitle.isNotEmpty ? bm.bookTitle : 'ReadPack';
        final matchingBook =
            bookProvider.books.where((b) => b.id == bm.bookId).firstOrNull;
        previewAuthor = matchingBook?.author ??
            (bm.chapterTitle.isNotEmpty ? bm.chapterTitle : previewBook);
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.widgets_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n?.t('widget.title') ?? 'Утасны виджет',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Live Phone Mockup with Widget Preview
                  Text(
                    l10n?.t('widget.preview_label') ??
                        'Утасны дэлгэц дээр харагдах байдал:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPhoneMockup(
                    context: context,
                    quote: previewQuote,
                    author: previewAuthor,
                    book: previewBook,
                    colorScheme: colorScheme,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 22),

                  // 2. Select Quote Source
                  Text(
                    l10n?.t('widget.source_label') ?? 'Виджетэд гаргах ишлэл:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSourceChip(
                        0,
                        l10n?.t('widget.source_daily') ?? 'Өдрийн ишлэл',
                        Icons.wb_sunny_outlined,
                        colorScheme,
                      ),
                      const SizedBox(width: 8),
                      _buildSourceChip(
                        1,
                        '${l10n?.t('widget.source_saved') ?? 'Хадгалсан'} (${bookProvider.bookmarks.length})',
                        Icons.bookmark_added_outlined,
                        colorScheme,
                      ),
                    ],
                  ),
                  if (bookProvider.bookmarks.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n?.t('widget.choose_specific_quote') ??
                          'Хадгалсан ишлэлээс сонгох:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: (_selectedCustomBookmark ??
                                  bookProvider.bookmarks.first)
                              .id,
                          items: bookProvider.bookmarks.map((bm) {
                            return DropdownMenuItem<String>(
                              value: bm.id,
                              child: Text(
                                '${bm.bookTitle}: “${bm.quote}”',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (bmId) {
                            if (bmId == null) return;
                            final chosen = bookProvider.bookmarks
                                .where((b) => b.id == bmId)
                                .firstOrNull;
                            if (chosen != null) {
                              setState(() {
                                _selectedSource = 1;
                                _selectedCustomBookmark = chosen;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // 3. Widget Theme (System / Light / Dark)
                  Text(
                    l10n?.t('widget.theme_label') ??
                        'Өнгөний загвар (Систем / Цайвар / Харанхуй):',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildThemeOption(
                        mode: 'system',
                        label: l10n?.t('settings.theme_system') ?? 'Систем',
                        icon: Icons.brightness_auto_rounded,
                        bgColor: colorScheme.surfaceContainerHighest,
                        textColor: colorScheme.onSurface,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        mode: 'light',
                        label: l10n?.t('settings.theme_light') ?? 'Цайвар',
                        icon: Icons.light_mode_rounded,
                        bgColor: const Color(0xFFFAF7F2),
                        textColor: const Color(0xFF1E293B),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        mode: 'dark',
                        label: l10n?.t('settings.theme_dark') ?? 'Харанхуй',
                        icon: Icons.dark_mode_rounded,
                        bgColor: const Color(0xFF0F172A),
                        textColor: const Color(0xFFF8FAFC),
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. Widget Size Choice
                  Text(
                    l10n?.t('widget.size_label') ?? 'Виджетийн хэмжээ:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSizeOption(
                          0,
                          l10n?.t('widget.size_small') ?? 'Жижиг (2x2)',
                          colorScheme),
                      const SizedBox(width: 8),
                      _buildSizeOption(
                          1,
                          l10n?.t('widget.size_medium') ?? 'Дунд (4x2)',
                          colorScheme),
                      const SizedBox(width: 8),
                      _buildSizeOption(
                          2,
                          l10n?.t('widget.size_large') ?? 'Том (4x4)',
                          colorScheme),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // 5. Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _saveWidgetSettings(
                        quoteText: previewQuote,
                        quoteAuthor: previewAuthor,
                        quoteBook: previewBook,
                      ),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text(
                        l10n?.t('widget.apply_button') ??
                            'Утасны виджетэд тохируулах',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneMockup({
    required BuildContext context,
    required String quote,
    required String author,
    required String book,
    required ColorScheme colorScheme,
    required AppLocalizations? l10n,
  }) {
    final systemIsDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final useDark = _selectedThemeMode == 'dark'
        ? true
        : (_selectedThemeMode == 'light' ? false : systemIsDark);

    final Color widgetBg =
        useDark ? const Color(0xFF0F172A) : const Color(0xFFFAF7F2);
    final Color widgetBorder =
        useDark ? const Color(0xFF334155) : const Color(0xFFE2D9C8);
    final Color widgetText =
        useDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    final Color widgetSubText =
        useDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final Color widgetAccent =
        useDark ? const Color(0xFFFBBF24) : const Color(0xFF9A6B26);

    final badgeText = _selectedSource == 0
        ? (l10n?.t('widget.badge_daily') ?? '📖 ӨДРИЙН ЭШЛЭЛ')
        : (l10n?.t('widget.badge_saved') ?? '📌 ХАДГАЛСАН ИШЛЭЛ');

    final footerText = (book.isNotEmpty && book != author)
        ? '— $author · $book'
        : '— $author';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: useDark
              ? [const Color(0xFF1E293B), const Color(0xFF090D16)]
              : [const Color(0xFFDCEBFA), const Color(0xFFC3DDFD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '21:20',
                style: TextStyle(
                  color: useDark ? Colors.white70 : const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.wifi,
                    size: 14,
                    color: useDark ? Colors.white70 : const Color(0xFF334155),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.battery_full,
                    size: 14,
                    color: useDark ? Colors.white70 : const Color(0xFF334155),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_selectedSize == 0)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    constraints: const BoxConstraints(minHeight: 150),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: widgetBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widgetBorder, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: useDark ? 0.35 : 0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          badgeText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: widgetAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '“$quote”',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: widgetText,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: widgetSubText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMockAppIcon(Icons.auto_stories_rounded,
                              const Color(0xFFE07A5F), useDark),
                          _buildMockAppIcon(Icons.calendar_month_rounded,
                              const Color(0xFF3B82F6), useDark),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMockAppIcon(Icons.headphones_rounded,
                              const Color(0xFF10B981), useDark),
                          _buildMockAppIcon(Icons.bookmark_rounded,
                              const Color(0xFF8B5CF6), useDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: _selectedSize == 2 ? 210 : 120,
              ),
              padding: EdgeInsets.all(_selectedSize == 2 ? 20 : 16),
              decoration: BoxDecoration(
                color: widgetBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widgetBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: useDark ? 0.35 : 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: _selectedSize == 2
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: widgetAccent,
                        ),
                      ),
                      Text(
                        'ReadPack',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widgetSubText.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '“$quote”',
                    maxLines: _selectedSize == 1 ? 3 : 6,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: _selectedSize == 2 ? 15.5 : 13.5,
                      fontStyle: FontStyle.italic,
                      color: widgetText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    footerText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: widgetSubText,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMockAppIcon(IconData icon, Color color, bool useDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: useDark ? 0.25 : 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildSourceChip(
      int index, String label, IconData icon, ColorScheme colorScheme) {
    final isSel = (_selectedSource == index) ||
        (index == 1 && _selectedSource == 2);
    return Expanded(
      child: AnimatedPressable(
        onTap: () => setState(() => _selectedSource = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: isSel
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSel ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    color:
                        isSel ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeOption(int size, String label, ColorScheme colorScheme) {
    final isSel = _selectedSize == size;
    return Expanded(
      child: AnimatedPressable(
        onTap: () => setState(() => _selectedSize = size),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSel
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                color: isSel ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String mode,
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required ColorScheme colorScheme,
  }) {
    final isSel = _selectedThemeMode == mode;
    return Expanded(
      child: AnimatedPressable(
        onTap: () => setState(() => _selectedThemeMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: isSel ? 2.2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
