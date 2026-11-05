import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class PhoneWidgetSheet extends StatefulWidget {
  const PhoneWidgetSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PhoneWidgetSheet(),
    );
  }

  @override
  State<PhoneWidgetSheet> createState() => _PhoneWidgetSheetState();
}

class _PhoneWidgetSheetState extends State<PhoneWidgetSheet> {
  // 0: Quote of the Day, 1: Random Saved, 2: Specific Quote
  int _selectedSource = 0;
  // 0: Small (2x2), 1: Medium (4x2), 2: Large (4x4)
  int _selectedSize = 1;
  // 0: Amber Paper, 1: OLED Dark, 2: Deep Blue
  int _selectedTheme = 0;
  Bookmark? _selectedCustomBookmark;

  @override
  void initState() {
    super.initState();
    _loadSavedWidgetSettings();
  }

  Future<void> _loadSavedWidgetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSource = prefs.getInt('widget_quote_mode') ?? 0;
      _selectedSize = prefs.getInt('widget_quote_size') ?? 1;
      _selectedTheme = prefs.getInt('widget_quote_theme') ?? 0;
    });
  }

  Future<void> _saveWidgetSettings(String quoteText, String quoteAuthor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('widget_quote_mode', _selectedSource);
    await prefs.setInt('widget_quote_size', _selectedSize);
    await prefs.setInt('widget_quote_theme', _selectedTheme);
    await prefs.setString('widget_quote_text', quoteText);
    await prefs.setString('widget_quote_author', quoteAuthor);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Утасны дэлгэцийн виджет амжилттай тохируулагдлаа! 📱'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 2),
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

    if (_selectedSource == 1) {
      if (bookProvider.bookmarks.isNotEmpty) {
        previewQuote = bookProvider.bookmarks.first.quote;
        previewAuthor = bookProvider.bookmarks.first.bookTitle.isNotEmpty
            ? bookProvider.bookmarks.first.bookTitle
            : 'Хадгалсан ишлэл';
      } else {
        previewQuote = 'Та одоогоор өөрийн ишлэл хадгалаагүй байна.';
        previewAuthor = 'ReadPack';
      }
    } else if (_selectedSource == 2 && _selectedCustomBookmark != null) {
      previewQuote = _selectedCustomBookmark!.quote;
      previewAuthor = _selectedCustomBookmark!.bookTitle;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
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
                      'Утасны виджет',
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
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Live Phone Mockup with Widget Preview
                  Text(
                    'Утасны дэлгэц дээр харагдах байдал:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPhoneMockup(previewQuote, previewAuthor, colorScheme),

                  const SizedBox(height: 22),

                  // 2. Select Quote Source
                  Text(
                    'Виджетэд гаргах ишлэл:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSourceChip(0, 'Өдрийн ишлэл', Icons.wb_sunny_outlined, colorScheme),
                      const SizedBox(width: 8),
                      _buildSourceChip(1, 'Хадгалсан (${bookProvider.bookmarks.length})', Icons.bookmark_added_outlined, colorScheme),
                    ],
                  ),
                  if (bookProvider.bookmarks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSourceChip(2, 'Сонгосон ишлэл', Icons.touch_app_outlined, colorScheme),
                    if (_selectedSource == 2) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Bookmark>(
                            isExpanded: true,
                            hint: const Text('Ишлэлээс сонгоно уу'),
                            value: _selectedCustomBookmark ?? bookProvider.bookmarks.first,
                            items: bookProvider.bookmarks.map((bm) {
                              return DropdownMenuItem<Bookmark>(
                                value: bm,
                                child: Text(
                                  bm.quote,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (bm) {
                              setState(() {
                                _selectedSource = 2;
                                _selectedCustomBookmark = bm;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 22),

                  // 3. Widget Size Choice
                  Text(
                    'Виджетийн хэмжээ:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSizeOption(0, 'Жижиг (2x2)', colorScheme),
                      const SizedBox(width: 8),
                      _buildSizeOption(1, 'Дунд (4x2)', colorScheme),
                      const SizedBox(width: 8),
                      _buildSizeOption(2, 'Том (4x4)', colorScheme),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 4. Widget Color Theme
                  Text(
                    'Өнгөний сэдэв:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildThemeOption(0, 'Амбер цаас', const Color(0xFFFFF8E7), Colors.brown, colorScheme),
                      const SizedBox(width: 8),
                      _buildThemeOption(1, 'OLED Хар', const Color(0xFF121212), Colors.white, colorScheme),
                      const SizedBox(width: 8),
                      _buildThemeOption(2, 'Шөнийн хөх', const Color(0xFF1A237E), Colors.white, colorScheme),
                    ],
                  ),

                  const SizedBox(height: 28),

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
                      onPressed: () => _saveWidgetSettings(previewQuote, previewAuthor),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text(
                        'Утасны виджетэд тохируулах',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _buildPhoneMockup(String quote, String author, ColorScheme colorScheme) {
    Color widgetBg;
    Color widgetText;
    Color widgetAccent;

    if (_selectedTheme == 1) {
      widgetBg = const Color(0xFF1E1E1E);
      widgetText = Colors.white;
      widgetAccent = Colors.amber;
    } else if (_selectedTheme == 2) {
      widgetBg = const Color(0xFF1A237E);
      widgetText = Colors.white;
      widgetAccent = const Color(0xFF80D8FF);
    } else {
      widgetBg = const Color(0xFFFFF8E1);
      widgetText = const Color(0xFF3E2723);
      widgetAccent = const Color(0xFFFF8F00);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 2),
      ),
      child: Column(
        children: [
          // Simulated phone status bar
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '20:45',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(Icons.wifi, size: 14, color: Colors.white70),
                  SizedBox(width: 4),
                  Icon(Icons.battery_full, size: 14, color: Colors.white70),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Widget Card on Phone
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widgetBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_quote_rounded, size: 16, color: widgetAccent),
                        const SizedBox(width: 4),
                        Text(
                          'ReadPack',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: widgetAccent,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Өнөөдөр',
                      style: TextStyle(
                        fontSize: 10,
                        color: widgetText.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '"$quote"',
                  maxLines: _selectedSize == 0 ? 2 : (_selectedSize == 1 ? 3 : 5),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: _selectedSize == 0 ? 12 : 13.5,
                    fontStyle: FontStyle.italic,
                    color: widgetText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '— $author',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widgetAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChip(int index, String label, IconData icon, ColorScheme colorScheme) {
    final isSel = _selectedSource == index;
    return Expanded(
      child: AnimatedPressable(
        onTap: () => setState(() => _selectedSource = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: isSel ? colorScheme.primary : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSel ? colorScheme.onPrimary : colorScheme.onSurface),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    color: isSel ? colorScheme.onPrimary : colorScheme.onSurface,
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? colorScheme.primary : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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

  Widget _buildThemeOption(int index, String label, Color bgColor, Color textColor, ColorScheme colorScheme) {
    final isSel = _selectedTheme == index;
    return Expanded(
      child: AnimatedPressable(
        onTap: () => setState(() => _selectedTheme = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSel ? colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
              width: isSel ? 2.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
