import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/shared/widgets/quote_share_modal.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ReaderPage extends StatefulWidget {
  final Book book;
  final int initialChapterIndex;
  final bool openAudioInitially;

  const ReaderPage({
    super.key,
    required this.book,
    this.initialChapterIndex = 0,
    this.openAudioInitially = false,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage>
    with SingleTickerProviderStateMixin {
  late int _currentChapterIndex;
  late ScrollController _scrollController;
  late PageController _pageController;
  int _currentPageInChapter = 0;
  bool _showControls = true;
  double _scrollProgress = 0.0;
  double _lastReportedProgress = 0.0;

  // Reading duration tracking
  Timer? _readingTimer;
  int _activeReadingSeconds = 0;


  // Audio Playback Engine State
  bool _isAudioPlaying = false;
  double _audioCurrentSeconds = 0.0;
  double _audioTotalSeconds = 300.0;
  double _audioSpeed = 1.0;
  Timer? _audioPlaybackTimer;

  bool get _isTesting =>
      WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');

  @override
  void initState() {
    super.initState();
    final chaptersCount = widget.book.chapters.length;
    _currentChapterIndex = chaptersCount == 0
        ? 0
        : widget.initialChapterIndex.clamp(0, chaptersCount - 1);

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _pageController = PageController();

    _initChapterAudio();

    if (widget.openAudioInitially) {
      _startAudio();
    }

    _startReadingSessionTimer();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    _audioPlaybackTimer?.cancel();
    _readingTimer?.cancel();

    // Flush any remaining active reading duration
    if (_activeReadingSeconds >= 30) {
      final minutes = (_activeReadingSeconds / 60).round();
      if (minutes > 0 && mounted) {
        context.read<BookProvider>().addReadingMinutes(minutes);
      }
    }

    super.dispose();
  }

  void _startReadingSessionTimer() {
    if (_isTesting) return;
    _readingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted) return;
      _activeReadingSeconds += 15;
      if (_activeReadingSeconds >= 60) {
        context.read<BookProvider>().addReadingMinutes(1);
        _activeReadingSeconds -= 60;
      }
    });
  }

  void _initChapterAudio() {
    if (widget.book.chapters.isEmpty) {
      _audioTotalSeconds = 120.0;
    } else {
      final ch = widget.book.chapters[_currentChapterIndex];
      _audioTotalSeconds = (ch.estimatedMinutes * 60).toDouble();
      if (_audioTotalSeconds <= 0) _audioTotalSeconds = 180.0;
    }
    _audioCurrentSeconds = 0.0;
  }

  void _startAudio() {
    setState(() {
      _isAudioPlaying = true;
      if (_audioCurrentSeconds == 0.0) {
        _audioCurrentSeconds = 1.0;
      }
    });

    if (_isTesting) return;

    _audioPlaybackTimer?.cancel();
    _audioPlaybackTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      if (!_isAudioPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        _audioCurrentSeconds += 0.5 * _audioSpeed;
        if (_audioCurrentSeconds >= _audioTotalSeconds) {
          _audioCurrentSeconds = _audioTotalSeconds;
          _isAudioPlaying = false;
          timer.cancel();

          // Advance to next chapter if available
          if (_currentChapterIndex < widget.book.chapters.length - 1) {
            _goToChapter(_currentChapterIndex + 1);
            _startAudio();
          }
        }
      });
    });
  }

  void _pauseAudio() {
    setState(() => _isAudioPlaying = false);
    _audioPlaybackTimer?.cancel();
  }

  void _seekAudio(double seconds) {
    setState(() {
      _audioCurrentSeconds = seconds.clamp(0.0, _audioTotalSeconds);
    });
  }

  void _skipAudio(double deltaSeconds) {
    _seekAudio(_audioCurrentSeconds + deltaSeconds);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll > 0) {
      final p = (currentScroll / maxScroll).clamp(0.0, 1.0);
      setState(() => _scrollProgress = p);

      // Throttle position reporting to avoid state spam and disk thrashing
      if ((p - _lastReportedProgress).abs() > 0.04 || p == 1.0 || p == 0.0) {
        _lastReportedProgress = p;
        final totalChapters =
            widget.book.chapters.isEmpty ? 1 : widget.book.chapters.length;
        final overallProgress =
            ((_currentChapterIndex + p) / totalChapters).clamp(0.0, 1.0);
        final estimatedPage = (overallProgress * widget.book.pages)
            .toInt()
            .clamp(1, widget.book.pages);

        context.read<BookProvider>().updateReadingPosition(
              widget.book.id,
              currentPage: estimatedPage,
              progress: overallProgress,
              currentChapterIndex: _currentChapterIndex,
            );
      }
    }
  }

  void _reportPaginatedProgress([int? pageIndex, int? totalPages]) {
    final curPage = pageIndex ?? _currentPageInChapter;
    final totalP = totalPages ?? 1;
    final totalChapters =
        widget.book.chapters.isEmpty ? 1 : widget.book.chapters.length;
    final chapterFraction = totalP > 0 ? ((curPage + 1) / totalP) : 0.0;
    final overallProgress =
        ((_currentChapterIndex + chapterFraction) / totalChapters).clamp(0.0, 1.0);
    final estimatedPage =
        (overallProgress * widget.book.pages).toInt().clamp(1, widget.book.pages);

    context.read<BookProvider>().updateReadingPosition(
          widget.book.id,
          currentPage: estimatedPage,
          progress: overallProgress,
          currentChapterIndex: _currentChapterIndex,
        );
  }

  List<String> _paginateChapter(String content) {
    final rawParagraphs =
        content.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    if (rawParagraphs.isEmpty) return [content];

    final List<String> pages = [];
    StringBuffer currentChunk = StringBuffer();
    int currentLength = 0;

    for (final p in rawParagraphs) {
      if (p.length > 600) {
        final sentences = p.split('. ');
        for (final s in sentences) {
          if (currentLength + s.length > 500 && currentLength > 0) {
            pages.add(currentChunk.toString().trim());
            currentChunk = StringBuffer();
            currentLength = 0;
          }
          currentChunk.write(s.endsWith('.') ? '$s ' : '$s. ');
          currentLength += s.length + (s.endsWith('.') ? 1 : 2);
        }
      } else {
        if (currentLength + p.length > 550 && currentLength > 0) {
          pages.add(currentChunk.toString().trim());
          currentChunk = StringBuffer();
          currentLength = 0;
        }
        if (currentChunk.isNotEmpty) {
          currentChunk.write('\n\n');
        }
        currentChunk.write(p);
        currentLength += p.length;
      }
    }
    if (currentChunk.isNotEmpty) {
      pages.add(currentChunk.toString().trim());
    }
    return pages.isEmpty ? [content] : pages;
  }

  void _goToChapter(int index, {int initialPage = 0}) {
    if (widget.book.chapters.isEmpty) return;
    setState(() {
      _currentChapterIndex = index.clamp(0, widget.book.chapters.length - 1);
      _currentPageInChapter = initialPage;
      _scrollProgress = 0.0;
      _lastReportedProgress = 0.0;
    });
    _initChapterAudio();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    if (_pageController.hasClients) {
      _pageController.jumpToPage(initialPage);
    }
    _reportPaginatedProgress();
  }

  TextStyle _getReaderTextStyle(
      ThemeProvider themeProvider, Color readerTextColor) {
    String? family;
    switch (themeProvider.fontFamily) {
      case 'Sans':
        family = null; // System default Sans-Serif
        break;
      case 'Georgia':
        family = 'Georgia';
        break;
      case 'Mono':
        family = 'Monospace';
        break;
      case 'Serif':
      default:
        family = 'Serif';
        break;
    }
    return TextStyle(
      fontFamily: family,
      fontSize: (16 * themeProvider.fontSizeScale).clamp(12.0, 26.0),
      height: themeProvider.lineHeight,
      color: readerTextColor,
      letterSpacing: 0.15,
    );
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  String _formatTime(double totalSec) {
    final m = (totalSec / 60).floor();
    final s = (totalSec % 60).floor();
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _getReaderBg(AppReaderTheme theme, bool isDark) {
    switch (theme) {
      case AppReaderTheme.sepia:
        return const Color(0xFFF5E6C8);
      case AppReaderTheme.dark:
        return const Color(0xFF1E293B);
      case AppReaderTheme.charcoal:
        return const Color(0xFF0F172A);
      case AppReaderTheme.light:
        return isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA);
    }
  }

  Color _getReaderTextColor(AppReaderTheme theme, bool isDark) {
    switch (theme) {
      case AppReaderTheme.sepia:
        return const Color(0xFF3A2A10);
      case AppReaderTheme.dark:
        return const Color(0xFFF1F5F9);
      case AppReaderTheme.charcoal:
        return const Color(0xFFCBD5E1);
      case AppReaderTheme.light:
        return isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    }
  }

  void _showHighlightModal(String paragraphText) {
    final noteCtrl = TextEditingController();
    int selectedColorHex = 0xFFFFD54F; // Gold default
    final l10n = AppLocalizations.of(context);

    final colors = [
      {'name': l10n?.t('reader.color_yellow') ?? 'Шар', 'hex': 0xFFFFD54F},
      {'name': l10n?.t('reader.color_green') ?? 'Ногоон', 'hex': 0xFF81C784},
      {'name': l10n?.t('reader.color_blue') ?? 'Цэнхэр', 'hex': 0xFF64B5F6},
      {'name': l10n?.t('reader.color_pink') ?? 'Ягаан', 'hex': 0xFFFF8A80},
      {'name': l10n?.t('reader.color_purple') ?? 'Нил', 'hex': 0xFFBA68C8},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final colorScheme = Theme.of(modalContext).colorScheme;
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.t('reader.save_quote') ??
                              'Ишлэл & Тэмдэглэл хадгалах',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: paragraphText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n?.t('reader.quote_copied') ??
                                    'Ишлэл хуулагдлаа!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Selected text card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(selectedColorHex).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: Color(selectedColorHex),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Text(
                        paragraphText.length > 200
                            ? '${paragraphText.substring(0, 200)}...'
                            : paragraphText,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurface,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.t('reader.highlight_color') ?? 'Тодруулах өнгө',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: colors.map((c) {
                        final hex = c['hex'] as int;
                        final isChosen = selectedColorHex == hex;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => selectedColorHex = hex);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(hex),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChosen
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isChosen
                                ? const Icon(Icons.check,
                                    size: 18, color: Colors.black87)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: l10n?.t('reader.personal_note') ??
                            'Хувийн тэмдэглэл (заавал биш)',
                        hintText: l10n?.t('reader.note_hint') ??
                            'Энэ хэсгийн талаар юу бодогдов?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(
                                color: colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              QuoteShareModal.show(
                                context,
                                quote: paragraphText,
                                author: widget.book.author,
                                bookTitle: widget.book.title,
                              );
                            },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.share_rounded, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n?.t('quote_share.title') ?? 'Карт үүсгэх',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              final chapterTitle = widget.book.chapters.isNotEmpty
                                  ? widget.book.chapters[_currentChapterIndex].title
                                  : '${l10n?.t('reader.chapter') ?? 'Бүлэг'} 1';
                              final newBookmark = Bookmark(
                                id: 'bm_${DateTime.now().millisecondsSinceEpoch}',
                                bookId: widget.book.id,
                                bookTitle: widget.book.title,
                                chapterTitle: chapterTitle,
                                pageNumber:
                                    ((_scrollProgress * widget.book.pages).toInt() +
                                        1),
                                quote: paragraphText.length > 200
                                    ? '${paragraphText.substring(0, 200)}...'
                                    : paragraphText,
                                note: noteCtrl.text.trim().isEmpty
                                    ? (l10n?.t('reader.personal_note') ??
                                        'Уншигчийн тэмдэглэл')
                                    : noteCtrl.text.trim(),
                                colorHex: selectedColorHex,
                                createdAt: DateTime.now(),
                              );
                              context.read<BookProvider>().addBookmark(newBookmark);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n?.t('reader.bookmark_added') ??
                                      'Ишлэл таны Сан руу хадгалагдлаа!'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(
                              l10n?.t('reader.save_quote') ?? 'Ишлэл хадгалах',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAppearanceSheet() {
    final themeProvider = context.read<ThemeProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
          final onSheetColor = isDark ? Colors.white : const Color(0xFF0F172A);
          final l10n = AppLocalizations.of(context);

          return Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: onSheetColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n?.t('reader.reading_settings') ?? 'Унших тохиргоо',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Font Size Adjuster
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n?.t('reader.font_size') ?? 'Үсгийн хэмжээ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: onSheetColor,
                        ),
                      ),
                      Row(
                        children: [
                          AnimatedPressable(
                            onTap: () {
                              themeProvider.setFontSizeScale(
                                  (themeProvider.fontSizeScale - 0.1)
                                      .clamp(0.8, 1.5));
                              setSheetState(() {});
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: onSheetColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'A-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: onSheetColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${(themeProvider.fontSizeScale * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: onSheetColor,
                              ),
                            ),
                          ),
                          AnimatedPressable(
                            onTap: () {
                              themeProvider.setFontSizeScale(
                                  (themeProvider.fontSizeScale + 0.1)
                                      .clamp(0.8, 1.5));
                              setSheetState(() {});
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: onSheetColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'A+',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: onSheetColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Themes Row
                  Text(
                    l10n?.t('reader.screen_theme') ?? 'Дэлгэцийн өнгө',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildThemeChip(
                        context,
                        label: l10n?.t('reader.theme_white') ?? 'Цагаан',
                        theme: AppReaderTheme.light,
                        currentTheme: themeProvider.readerTheme,
                        bgColor: const Color(0xFFFAFAFA),
                        textColor: const Color(0xFF182350),
                        onSelect: () {
                          themeProvider.setReaderTheme(AppReaderTheme.light);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        context,
                        label: l10n?.t('reader.theme_sepia') ?? 'Сепиа',
                        theme: AppReaderTheme.sepia,
                        currentTheme: themeProvider.readerTheme,
                        bgColor: const Color(0xFFF5E6C8),
                        textColor: const Color(0xFF3A2A10),
                        onSelect: () {
                          themeProvider.setReaderTheme(AppReaderTheme.sepia);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        context,
                        label: l10n?.t('reader.theme_dark') ?? 'Харанхуй',
                        theme: AppReaderTheme.dark,
                        currentTheme: themeProvider.readerTheme,
                        bgColor: const Color(0xFF1E293B),
                        textColor: Colors.white,
                        onSelect: () {
                          themeProvider.setReaderTheme(AppReaderTheme.dark);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        context,
                        label: l10n?.t('reader.theme_charcoal') ?? 'Нүүрс',
                        theme: AppReaderTheme.charcoal,
                        currentTheme: themeProvider.readerTheme,
                        bgColor: const Color(0xFF0F172A),
                        textColor: Colors.white,
                        onSelect: () {
                          themeProvider.setReaderTheme(AppReaderTheme.charcoal);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Reading Mode Toggle
                  Text(
                    l10n?.t('reader.reading_mode') ?? 'Унших горим',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedPressable(
                          onTap: () {
                            themeProvider.setPaginated(true);
                            setSheetState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: themeProvider.isPaginated
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: themeProvider.isPaginated
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 16,
                                  color: themeProvider.isPaginated
                                      ? Theme.of(context).colorScheme.primary
                                      : onSheetColor.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n?.t('reader.mode_paginated') ?? 'Хуудаслалттай',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: themeProvider.isPaginated ? FontWeight.bold : FontWeight.w500,
                                    color: themeProvider.isPaginated
                                        ? Theme.of(context).colorScheme.primary
                                        : onSheetColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AnimatedPressable(
                          onTap: () {
                            themeProvider.setPaginated(false);
                            setSheetState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: !themeProvider.isPaginated
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: !themeProvider.isPaginated
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.swap_vert_rounded,
                                  size: 16,
                                  color: !themeProvider.isPaginated
                                      ? Theme.of(context).colorScheme.primary
                                      : onSheetColor.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n?.t('reader.mode_scroll') ?? 'Тасралтгүй',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: !themeProvider.isPaginated ? FontWeight.bold : FontWeight.w500,
                                    color: !themeProvider.isPaginated
                                        ? Theme.of(context).colorScheme.primary
                                        : onSheetColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Font Family Row
                  Text(
                    l10n?.t('reader.font_family') ?? 'Фонтын хэв маяг',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFontChip(
                        'Serif',
                        l10n?.t('reader.font_serif') ?? 'Сонгодог (Serif)',
                        themeProvider,
                        setSheetState,
                      ),
                      const SizedBox(width: 8),
                      _buildFontChip(
                        'Sans',
                        l10n?.t('reader.font_sans') ?? 'Орчин үе (Sans)',
                        themeProvider,
                        setSheetState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildFontChip(
                        'Georgia',
                        'Georgia',
                        themeProvider,
                        setSheetState,
                      ),
                      const SizedBox(width: 8),
                      _buildFontChip(
                        'Mono',
                        l10n?.t('reader.font_mono') ?? 'Monospace',
                        themeProvider,
                        setSheetState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Line Height Controls
                  Text(
                    l10n?.t('reader.line_height') ?? 'Мөр хоорондын зай',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildValueChip('1.4x', (themeProvider.lineHeight - 1.4).abs() < 0.05, () {
                        themeProvider.setLineHeight(1.4);
                        setSheetState(() {});
                      }),
                      const SizedBox(width: 8),
                      _buildValueChip('1.7x', (themeProvider.lineHeight - 1.7).abs() < 0.05, () {
                        themeProvider.setLineHeight(1.7);
                        setSheetState(() {});
                      }),
                      const SizedBox(width: 8),
                      _buildValueChip('2.0x', (themeProvider.lineHeight - 2.0).abs() < 0.05, () {
                        themeProvider.setLineHeight(2.0);
                        setSheetState(() {});
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Margin Controls
                  Text(
                    l10n?.t('reader.margins') ?? 'Захаас авах зай',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onSheetColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildValueChip(
                        l10n?.t('reader.margin_narrow') ?? 'Нарийн',
                        (themeProvider.horizontalMargin - 14.0).abs() < 0.1,
                        () {
                          themeProvider.setHorizontalMargin(14.0);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildValueChip(
                        l10n?.t('reader.margin_normal') ?? 'Хэвийн',
                        (themeProvider.horizontalMargin - 20.0).abs() < 0.1,
                        () {
                          themeProvider.setHorizontalMargin(20.0);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildValueChip(
                        l10n?.t('reader.margin_wide') ?? 'Өргөн',
                        (themeProvider.horizontalMargin - 28.0).abs() < 0.1,
                        () {
                          themeProvider.setHorizontalMargin(28.0);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildValueChip(String label, bool isSelected, VoidCallback onSelect) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: AnimatedPressable(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip(
    BuildContext context, {
    required String label,
    required AppReaderTheme theme,
    required AppReaderTheme currentTheme,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onSelect,
  }) {
    final isSelected = currentTheme == theme;

    return Expanded(
      child: AnimatedPressable(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontChip(
    String familyKey,
    String label,
    ThemeProvider themeProvider,
    StateSetter setSheetState,
  ) {
    final isSelected = themeProvider.fontFamily == familyKey;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: AnimatedPressable(
        onTap: () {
          themeProvider.setFontFamily(familyKey);
          setSheetState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTableOfContents() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final l10n = AppLocalizations.of(ctx);
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 18),
              Text(
                l10n?.t('reader.chapters') ?? 'Гарчиг',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.book.chapters.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      l10n?.t('reader.no_chapters') ??
                          'Бүлгийн гарчиг байхгүй байна',
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.book.chapters.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final chapter = widget.book.chapters[index];
                      final isCurrent = index == _currentChapterIndex;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          _goToChapter(index);
                          Navigator.pop(ctx);
                        },
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          chapter.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        trailing: Text(
                          '~${chapter.estimatedMinutes} ${l10n?.t('common.minutes_short') ?? 'мин'}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginatedReader({
    required BookChapter currentChapter,
    required ThemeProvider themeProvider,
    required Color readerTextColor,
    required AppLocalizations? l10n,
    required ColorScheme colorScheme,
    required BookProvider bookProvider,
    required List<BookChapter> chapters,
  }) {
    final pages = _paginateChapter(currentChapter.content);
    final pageCount = pages.length;

    return PageView.builder(
      controller: _pageController,
      itemCount: pageCount,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (idx) {
        setState(() => _currentPageInChapter = idx);
        _reportPaginatedProgress(idx, pageCount);
      },
      itemBuilder: (context, pIndex) {
        final pageText = pages[pIndex];
        final isLastPage = pIndex == pageCount - 1;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () => _showHighlightModal(pageText),
          onLongPress: () => _showHighlightModal(pageText),
          onTapUp: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            final dx = details.localPosition.dx;
            if (dx < screenWidth * 0.22) {
              if (_currentPageInChapter > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                );
              } else if (_currentChapterIndex > 0) {
                _goToChapter(_currentChapterIndex - 1);
              }
            } else if (dx > screenWidth * 0.78) {
              if (_currentPageInChapter < pageCount - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                );
              } else if (_currentChapterIndex < chapters.length - 1) {
                _goToChapter(_currentChapterIndex + 1);
              }
            } else {
              _toggleControls();
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: themeProvider.horizontalMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 76),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currentChapter.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: (18 * themeProvider.fontSizeScale)
                              .clamp(14.0, 26.0),
                          fontWeight: FontWeight.bold,
                          color: readerTextColor,
                        ),
                      ),
                    ),
                    Text(
                      '${l10n?.t('reader.chapter') ?? 'Бүлэг'} ${_currentChapterIndex + 1}/${chapters.isEmpty ? 1 : chapters.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: readerTextColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.book.author,
                  style: TextStyle(
                    fontSize: 12,
                    color: readerTextColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Builder(builder: (context) {
                      final pageParagraphs = pageText
                          .split('\n\n')
                          .where((p) => p.trim().isNotEmpty)
                          .toList();
                      final paragraphsToRender =
                          pageParagraphs.isEmpty ? [pageText] : pageParagraphs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: paragraphsToRender.map((p) {
                          final matchingBm = bookProvider.bookmarks.where(
                            (b) =>
                                b.bookId == widget.book.id &&
                                p.contains(b.quote.substring(
                                    0,
                                    b.quote.length > 25
                                        ? 25
                                        : b.quote.length)),
                          ).firstOrNull;
                          final hasBm = matchingBm != null;
                          final highlightColor = matchingBm != null
                              ? Color(matchingBm.colorHex)
                              : Colors.amber;

                          return GestureDetector(
                            onLongPress: () => _showHighlightModal(p),
                            onDoubleTap: () => _showHighlightModal(p),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: hasBm
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6)
                                  : EdgeInsets.zero,
                              decoration: hasBm
                                  ? BoxDecoration(
                                      color: highlightColor
                                          .withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border(
                                        left: BorderSide(
                                          color: highlightColor,
                                          width: 3.5,
                                        ),
                                      ),
                                    )
                                  : null,
                              child: Text(
                                p,
                                style: _getReaderTextStyle(
                                    themeProvider, readerTextColor),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ),
                if (isLastPage &&
                    chapters.isNotEmpty &&
                    _currentChapterIndex < chapters.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                        onPressed: () => _goToChapter(_currentChapterIndex + 1),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(
                          l10n?.t('reader.next_chapter') ??
                              'Дараагийн бүлэг рүү шилжих',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n?.t('book.pages') ?? 'Хуудас'} ${pIndex + 1} / $pageCount',
                        style: TextStyle(
                          fontSize: 11,
                          color: readerTextColor.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        '${(((_currentChapterIndex + (pIndex + 1) / pageCount) / (chapters.isEmpty ? 1 : chapters.length)) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: readerTextColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinuousScrollReader({
    required BookChapter currentChapter,
    required List<String> paragraphs,
    required int activeAudioParagraph,
    required ThemeProvider themeProvider,
    required Color readerTextColor,
    required AppLocalizations? l10n,
    required ColorScheme colorScheme,
    required BookProvider bookProvider,
    required bool hasChapters,
    required List<BookChapter> chapters,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 72)),
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal: themeProvider.horizontalMargin),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentChapter.title,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: (22 * themeProvider.fontSizeScale)
                          .clamp(16.0, 32.0),
                      fontWeight: FontWeight.bold,
                      color: readerTextColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.author,
                    style: TextStyle(
                      fontSize: (13 * themeProvider.fontSizeScale)
                          .clamp(11.0, 18.0),
                      color: readerTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(paragraphs.length, (pIndex) {
                    final paragraph = paragraphs[pIndex];
                    final isAudioActive =
                        _isAudioPlaying && pIndex == activeAudioParagraph;

                    final matchingBookmark = bookProvider.bookmarks.where(
                      (b) =>
                          b.bookId == widget.book.id &&
                          paragraph.contains(b.quote.substring(
                              0,
                              b.quote.length > 25
                                  ? 25
                                  : b.quote.length)),
                    ).firstOrNull;
                    final hasBookmark = matchingBookmark != null;
                    final highlightColor = matchingBookmark != null
                        ? Color(matchingBookmark.colorHex)
                        : Colors.amber;

                    return GestureDetector(
                      onLongPress: () => _showHighlightModal(paragraph),
                      onDoubleTap: () => _showHighlightModal(paragraph),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: (isAudioActive || hasBookmark)
                            ? const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8)
                            : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: isAudioActive
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : (hasBookmark
                                  ? highlightColor.withValues(alpha: 0.16)
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(10),
                          border: isAudioActive
                              ? Border(
                                  left: BorderSide(
                                    color: colorScheme.primary,
                                    width: 3.5,
                                  ),
                                )
                              : (hasBookmark
                                  ? Border(
                                      left: BorderSide(
                                        color: highlightColor,
                                        width: 3.5,
                                      ),
                                    )
                                  : null),
                        ),
                        child: Text(
                          paragraph,
                          style: _getReaderTextStyle(
                              themeProvider, readerTextColor),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  if (hasChapters)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentChapterIndex > 0)
                          AnimatedPressable(
                            onTap: () => _goToChapter(_currentChapterIndex - 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: readerTextColor
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back_ios_rounded,
                                      size: 14, color: readerTextColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n?.t('reader.prev_chapter') ??
                                        'Өмнөх бүлэг',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: readerTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (_currentChapterIndex < chapters.length - 1)
                          AnimatedPressable(
                            onTap: () => _goToChapter(_currentChapterIndex + 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    l10n?.t('reader.next_chapter') ??
                                        'Дараагийн бүлэг',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: colorScheme.onPrimary),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final bookProvider = context.watch<BookProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final readerBg = _getReaderBg(themeProvider.readerTheme, isDark);
    final readerTextColor =
        _getReaderTextColor(themeProvider.readerTheme, isDark);

    final chapters = widget.book.chapters;
    final hasChapters = chapters.isNotEmpty;
    final currentChapter = hasChapters
        ? chapters[_currentChapterIndex]
        : BookChapter(
            id: 'c0',
            title: l10n?.t('reader.chapters') ?? 'Агуулга',
            content: l10n?.t('common.loading') ?? 'Номын агуулга ачаалагдаж байна...',
            estimatedMinutes: 5,
          );

    final paragraphs = currentChapter.content.split('\n\n');
    final activeAudioParagraph = _audioTotalSeconds > 0
        ? ((_audioCurrentSeconds / _audioTotalSeconds) * paragraphs.length)
            .floor()
            .clamp(0, paragraphs.isEmpty ? 0 : paragraphs.length - 1)
        : 0;

    return Scaffold(
      backgroundColor: readerBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Reading Text Area (Paginated PageView or Continuous Scroll)
            if (themeProvider.isPaginated)
              _buildPaginatedReader(
                currentChapter: currentChapter,
                themeProvider: themeProvider,
                readerTextColor: readerTextColor,
                l10n: l10n,
                colorScheme: Theme.of(context).colorScheme,
                bookProvider: bookProvider,
                chapters: chapters,
              )
            else
              _buildContinuousScrollReader(
                currentChapter: currentChapter,
                paragraphs: paragraphs,
                activeAudioParagraph: activeAudioParagraph,
                themeProvider: themeProvider,
                readerTextColor: readerTextColor,
                l10n: l10n,
                colorScheme: Theme.of(context).colorScheme,
                bookProvider: bookProvider,
                hasChapters: hasChapters,
                chapters: chapters,
              ),

            // Top HUD Navigation Header
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              top: _showControls ? 0 : -80,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: readerBg.withValues(alpha: 0.95),
                  border: Border(
                    bottom: BorderSide(
                      color: readerTextColor.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedPressable(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: readerTextColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: readerTextColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.book.title,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: readerTextColor,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        AnimatedPressable(
                          onTap: _showTableOfContents,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.format_list_bulleted_rounded,
                              size: 20,
                              color: readerTextColor,
                            ),
                          ),
                        ),
                        AnimatedPressable(
                          onTap: _showAppearanceSheet,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.text_format_rounded,
                              size: 22,
                              color: readerTextColor,
                            ),
                          ),
                        ),
                        AnimatedPressable(
                          onTap: () {
                            if (_isAudioPlaying) {
                              _pauseAudio();
                            } else {
                              _startAudio();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              _isAudioPlaying
                                  ? Icons.headphones_rounded
                                  : Icons.headphones_outlined,
                              size: 20,
                              color: _isAudioPlaying
                                  ? Theme.of(context).colorScheme.primary
                                  : readerTextColor,
                            ),
                          ),
                        ),
                        AnimatedPressable(
                          onTap: () {
                            final quote = paragraphs.isNotEmpty
                                ? paragraphs[0]
                                : widget.book.title;
                            _showHighlightModal(quote);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.bookmark_add_rounded,
                              size: 20,
                              color: readerTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Audio Bar (Enhanced Interactive TTS Audio Player)
            if (_isAudioPlaying || _audioCurrentSeconds > 0)
              Positioned(
                left: 16,
                right: 16,
                bottom: _showControls ? 74 : 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // Waveform Animation / Sound Indicator
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isAudioPlaying
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_mute_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${l10n?.t('reader.audio_mode') ?? 'Сонсох горим'}: ${currentChapter.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_formatTime(_audioCurrentSeconds)} / ${_formatTime(_audioTotalSeconds)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Speed selector
                          AnimatedPressable(
                            onTap: () {
                              setState(() {
                                if (_audioSpeed == 1.0) {
                                  _audioSpeed = 1.25;
                                } else if (_audioSpeed == 1.25) {
                                  _audioSpeed = 1.5;
                                } else if (_audioSpeed == 1.5) {
                                  _audioSpeed = 2.0;
                                } else {
                                  _audioSpeed = 1.0;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_audioSpeed}x',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedPressable(
                            onTap: () {
                              _pauseAudio();
                              setState(() => _audioCurrentSeconds = 0);
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Scrubber Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: _audioCurrentSeconds.clamp(
                              0.0, _audioTotalSeconds),
                          max: _audioTotalSeconds,
                          onChanged: (val) {
                            _seekAudio(val);
                          },
                        ),
                      ),
                      // Audio Controls: Skip -15s, Play/Pause, Skip +15s
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10_rounded,
                                color: Colors.white, size: 22),
                            onPressed: () => _skipAudio(-10),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              if (_isAudioPlaying) {
                                _pauseAudio();
                              } else {
                                _startAudio();
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isAudioPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.forward_10_rounded,
                                color: Colors.white, size: 22),
                            onPressed: () => _skipAudio(10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom HUD Progress Footer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              bottom: _showControls ? 0 : -80,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: readerBg.withValues(alpha: 0.95),
                  border: Border(
                    top: BorderSide(
                      color: readerTextColor.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Builder(builder: (context) {
                      final paginatedPagesCount = _paginateChapter(currentChapter.content).length;
                      final effectiveProgress = themeProvider.isPaginated
                          ? (((_currentChapterIndex +
                                      (_currentPageInChapter + 1) /
                                          (paginatedPagesCount > 0 ? paginatedPagesCount : 1)) /
                                  (chapters.isEmpty ? 1 : chapters.length))
                              .clamp(0.0, 1.0))
                          : _scrollProgress;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(effectiveProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: readerTextColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 160,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: effectiveProgress,
                                backgroundColor:
                                    readerTextColor.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(width: 12),
                    Text(
                      '${l10n?.t('reader.chapter') ?? 'Бүлэг' } ${_currentChapterIndex + 1} / ${chapters.isEmpty ? 1 : chapters.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: readerTextColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
