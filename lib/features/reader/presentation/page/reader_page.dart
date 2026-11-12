import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/reader/widgets/reader_appearance_sheet.dart';
import 'package:readpack/features/reader/widgets/reader_audio_bar.dart';
import 'package:readpack/features/reader/widgets/reader_bookmark_modal.dart';
import 'package:readpack/features/reader/widgets/reader_hud_bars.dart';
import 'package:readpack/features/reader/widgets/reader_page_view.dart';
import 'package:readpack/features/reader/widgets/reader_scroll_view.dart';
import 'package:readpack/features/reader/widgets/reader_search_sheet.dart';
import 'package:readpack/features/reader/widgets/reader_session_tracker.dart';
import 'package:readpack/features/reader/widgets/reader_theme_helpers.dart';
import 'package:readpack/features/reader/widgets/reader_toc_sheet.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

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
  late ReaderSessionTracker _sessionTracker;
  int _currentPageInChapter = 0;
  bool _showControls = true;
  double _scrollProgress = 0.0;
  double _lastReportedProgress = 0.0;

  // Audio Playback Engine State
  bool _isAudioPlaying = false;
  double _audioCurrentSeconds = 0.0;
  double _audioTotalSeconds = 300.0;
  double _audioSpeed = 1.0;
  final FlutterTts _tts = FlutterTts();
  int _audioCharacterPosition = 0;
  Timer? _ttsSeekDebounce;
  int? _sleepTimerMinutes;
  Timer? _sleepCountdownTimer;

  bool get _isTesting => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  Book get _activeBook {
    final provider = context.read<BookProvider>();
    return provider.books.firstWhere(
      (book) => book.id == widget.book.id,
      orElse: () => widget.book,
    );
  }

  int _chapterIndexFor(Book book) => book.chapters.isEmpty
      ? 0
      : _currentChapterIndex.clamp(0, book.chapters.length - 1);

  int _progressPageCount(Book book) => book.pages > 0 ? book.pages : 1;

  @override
  void initState() {
    super.initState();
    final chaptersCount = widget.book.chapters.length;
    _currentChapterIndex = chaptersCount == 0
        ? 0
        : (widget.initialChapterIndex > 0
                  ? widget.initialChapterIndex
                  : widget.book.currentChapterIndex)
              .clamp(0, chaptersCount - 1);

    _scrollProgress = widget.book.progress;
    _lastReportedProgress = widget.book.progress;

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _pageController = PageController();
    _sessionTracker = ReaderSessionTracker(context, bookId: widget.book.id);

    _initChapterAudio();

    if (widget.openAudioInitially && _canReadCurrentChapter) {
      _startAudio();
    }

    _sessionTracker.start();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    _ttsSeekDebounce?.cancel();
    _tts.stop();
    _sleepCountdownTimer?.cancel();
    _sessionTracker.dispose();
    super.dispose();
  }

  void _initChapterAudio() {
    final book = _activeBook;
    if (book.chapters.isEmpty) return;
    final currentCh = book.chapters[_chapterIndexFor(book)];
    final wordCount = currentCh.content
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    setState(() {
      _audioTotalSeconds = math
          .max(1, (wordCount / 180 * 60).round())
          .toDouble();
      _audioCurrentSeconds = 0.0;
      _audioCharacterPosition = 0;
    });
  }

  bool get _canReadCurrentChapter {
    final book = _activeBook;
    final chapters = book.chapters;
    return chapters.isNotEmpty &&
        chapters[_chapterIndexFor(book)].content.trim().isNotEmpty;
  }

  Future<void> _startAudio() async {
    if (!_canReadCurrentChapter) return;
    final book = _activeBook;
    final chapterIndex = _chapterIndexFor(book);
    setState(() => _isAudioPlaying = true);
    if (_isTesting) return;

    final currentChapter = book.chapters[chapterIndex];
    final text = currentChapter.content;
    var start = _audioCharacterPosition.clamp(0, text.length).toInt();
    if (start >= text.length) {
      setState(() {
        _audioCurrentSeconds = 0;
        _audioCharacterPosition = 0;
      });
      start = 0;
    }

    try {
      final locale = Localizations.localeOf(context).languageCode;
      await _tts.setLanguage(locale == 'mn' ? 'mn-MN' : 'en-US');
      await _tts.setSpeechRate(_audioSpeed);
      final baseOffset = start;
      _tts.setProgressHandler((spokenText, startOffset, endOffset, word) {
        if (!mounted) return;
        final position = (baseOffset + endOffset).clamp(0, text.length).toInt();
        setState(() {
          _audioCharacterPosition = position;
          _audioCurrentSeconds =
              _audioTotalSeconds * position / math.max(1, text.length);
        });
        _syncAudioWithText();
      });
      _tts.setCompletionHandler(() {
        if (!mounted) return;
        if (chapterIndex < book.chapters.length - 1) {
          _goToChapter(_currentChapterIndex + 1);
        } else {
          setState(() => _isAudioPlaying = false);
        }
      });
      _tts.setErrorHandler((message) {
        if (!mounted) return;
        setState(() => _isAudioPlaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Text to speech could not start: $message')),
        );
      });
      await _tts.speak(text.substring(start));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isAudioPlaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text to speech is unavailable: $error')),
      );
    }
  }

  Future<void> _pauseAudio() async {
    if (!_isTesting) await _tts.stop();
    if (!mounted) return;
    setState(() => _isAudioPlaying = false);
  }

  void _syncAudioWithText() {
    final book = _activeBook;
    if (book.chapters.isEmpty) return;
    final currentChapter = book.chapters[_chapterIndexFor(book)];
    final paragraphs = currentChapter.content.split('\n\n');
    final paragraphSentences = paragraphs.map((p) {
      final matches = RegExp(r'[^.!?]+[.!?]*\s*').allMatches(p);
      final list = matches
          .map((m) => m.group(0) ?? '')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      return list.isEmpty ? [p] : list;
    }).toList();
    final totalSentences = paragraphSentences.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final globalSentenceIndex = (_audioTotalSeconds > 0 && totalSentences > 0)
        ? ((_audioCurrentSeconds / _audioTotalSeconds) * totalSentences)
              .floor()
              .clamp(0, totalSentences - 1)
        : 0;

    int activeAudioParagraph = 0;
    int runningCount = 0;
    for (int i = 0; i < paragraphSentences.length; i++) {
      final count = paragraphSentences[i].length;
      if (globalSentenceIndex < runningCount + count) {
        activeAudioParagraph = i;
        break;
      }
      runningCount += count;
    }

    final themeProvider = context.read<ThemeProvider>();
    if (themeProvider.isPaginated && _pageController.hasClients) {
      final pages = ReaderThemeHelpers.paginateChapter(currentChapter.content);
      if (activeAudioParagraph < paragraphs.length) {
        final targetPage = ReaderThemeHelpers.getPageIndexForParagraph(
          pages,
          paragraphs[activeAudioParagraph],
        );
        if (_currentPageInChapter != targetPage) {
          _currentPageInChapter = targetPage;
          _pageController.jumpToPage(targetPage);
        }
      }
    }
  }

  void _seekAudio(double seconds) {
    final wasPlaying = _isAudioPlaying;
    final progress = _audioTotalSeconds <= 0
        ? 0.0
        : (seconds / _audioTotalSeconds).clamp(0.0, 1.0);
    final book = _activeBook;
    final currentText = book.chapters.isEmpty
        ? ''
        : book.chapters[_chapterIndexFor(book)].content;
    setState(() {
      _audioCurrentSeconds = progress * _audioTotalSeconds;
      _audioCharacterPosition = (progress * currentText.length).round();
      if (wasPlaying) _isAudioPlaying = false;
    });
    _syncAudioWithText();
    if (wasPlaying) {
      _ttsSeekDebounce?.cancel();
      _tts.stop().then((_) {
        _ttsSeekDebounce = Timer(const Duration(milliseconds: 250), () {
          if (mounted) _startAudio();
        });
      });
    }
  }

  void _setSleepTimer(int? minutes) {
    _sleepCountdownTimer?.cancel();
    setState(() {
      _sleepTimerMinutes = minutes;
    });
    if (minutes == null || minutes <= 0) return;
    _sleepCountdownTimer = Timer(Duration(minutes: minutes), () {
      if (!mounted) return;
      _pauseAudio();
      setState(() {
        _sleepTimerMinutes = null;
      });
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.t('audio_ext.sleep_ended_toast') ??
                'Унтах цаг боллоо. Аудио автоматаар зогслоо 🌙',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  void _showSleepTimerSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final options = [
          {
            'title': l10n?.t('audio_ext.sleep_off') ?? 'Унтраах (Off)',
            'val': null,
          },
          {'title': l10n?.t('audio_ext.sleep_15') ?? '15 минут', 'val': 15},
          {'title': l10n?.t('audio_ext.sleep_30') ?? '30 минут', 'val': 30},
          {'title': l10n?.t('audio_ext.sleep_45') ?? '45 минут', 'val': 45},
          {
            'title': '60 ${l10n?.t('common.minutes_short') ?? 'минут'}',
            'val': 60,
          },
        ];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.bedtime_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.t('audio_ext.sleep_timer') ??
                            'Унтах таймер (Sleep Timer)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...options.map((opt) {
                    final val = opt['val'] as int?;
                    final isSelected = _sleepTimerMinutes == val;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        opt['title'] as String,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _setSleepTimer(val);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSearchSheet() {
    ReaderSearchSheet.show(
      context: context,
      book: _activeBook,
      onSelectChapter: (cIdx) => _goToChapter(cIdx),
    );
  }

  void _skipAudio(double deltaSeconds) {
    _seekAudio(_audioCurrentSeconds + deltaSeconds);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final book = _activeBook;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final curScroll = _scrollController.offset;
    final totalChapters = book.chapters.isEmpty ? 1 : book.chapters.length;

    if (maxScroll <= 0) return;
    final chapterFraction = (curScroll / maxScroll).clamp(0.0, 1.0);
    final overallProgress =
        ((_currentChapterIndex + chapterFraction) / totalChapters).clamp(
          0.0,
          1.0,
        );

    setState(() {
      _scrollProgress = overallProgress;
    });

    if ((overallProgress - _lastReportedProgress).abs() > 0.04) {
      _lastReportedProgress = overallProgress;
      final estimatedPage = (overallProgress * book.pages).toInt().clamp(
        1,
        _progressPageCount(book),
      );
      context.read<BookProvider>().updateReadingPosition(
        book.id,
        currentPage: estimatedPage,
        progress: overallProgress,
        currentChapterIndex: _currentChapterIndex,
      );
    }
  }

  void _reportPaginatedProgress([int? pageIndex, int? totalPages]) {
    final book = _activeBook;
    final curPage = pageIndex ?? _currentPageInChapter;
    final totalP =
        totalPages ??
        (book.chapters.isEmpty
            ? 1
            : ReaderThemeHelpers.paginateChapter(
                book.chapters[_chapterIndexFor(book)].content,
              ).length);
    final totalChapters = book.chapters.isEmpty ? 1 : book.chapters.length;
    final chapterFraction = totalP > 0 ? ((curPage + 1) / totalP) : 0.0;
    final overallProgress =
        ((_currentChapterIndex + chapterFraction) / totalChapters).clamp(
          0.0,
          1.0,
        );
    final estimatedPage = (overallProgress * book.pages).toInt().clamp(
      1,
      _progressPageCount(book),
    );

    setState(() {
      _scrollProgress = overallProgress;
    });

    if ((overallProgress - _lastReportedProgress).abs() > 0.02) {
      _lastReportedProgress = overallProgress;
      context.read<BookProvider>().updateReadingPosition(
        book.id,
        currentPage: estimatedPage,
        progress: overallProgress,
        currentChapterIndex: _currentChapterIndex,
      );
    }
  }

  void _goToChapter(int index, {int initialPage = 0}) {
    final book = _activeBook;
    if (book.chapters.isEmpty) return;
    final wasPlaying = _isAudioPlaying;
    final stopped = _isTesting ? Future<void>.value() : _tts.stop();
    setState(() {
      _currentChapterIndex = index.clamp(0, book.chapters.length - 1);
      _currentPageInChapter = initialPage;
    });
    _initChapterAudio();
    if (wasPlaying) {
      stopped.then((_) {
        if (mounted) _startAudio();
      });
    }
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    if (_pageController.hasClients) {
      _pageController.jumpToPage(initialPage);
    }
    _reportPaginatedProgress(initialPage);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _showHighlightModal(String paragraphText) {
    ReaderBookmarkModal.show(
      context: context,
      paragraphText: paragraphText,
      book: _activeBook,
      currentChapterIndex: _currentChapterIndex,
      scrollProgress: _scrollProgress,
    );
  }

  void _showAppearanceSheet() {
    final themeProvider = context.read<ThemeProvider>();
    ReaderAppearanceSheet.show(context, themeProvider);
  }

  void _showTableOfContents() {
    ReaderTocSheet.show(
      context: context,
      book: _activeBook,
      currentChapterIndex: _currentChapterIndex,
      onSelectChapter: (idx) => _goToChapter(idx),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final currentBook = _activeBook;

    final readerBg = ReaderThemeHelpers.getReaderBg(
      themeProvider.readerTheme,
      isDark,
    );
    final readerTextColor = ReaderThemeHelpers.getReaderTextColor(
      themeProvider.readerTheme,
      isDark,
    );

    final chapters = currentBook.chapters;
    final hasChapters = chapters.isNotEmpty;
    final currentChapterIndex = _chapterIndexFor(currentBook);
    final currentChapter = hasChapters ? chapters[currentChapterIndex] : null;
    final canReadCurrentChapter =
        currentChapter?.content.trim().isNotEmpty ?? false;

    final paragraphs =
        currentChapter?.content.split('\n\n') ?? const <String>[];
    final paragraphSentences = paragraphs.map((p) {
      final matches = RegExp(r'[^.!?]+[.!?]*\s*').allMatches(p);
      final list = matches
          .map((m) => m.group(0) ?? '')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      return list.isEmpty ? [p] : list;
    }).toList();
    final totalSentences = paragraphSentences.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final globalSentenceIndex = (_audioTotalSeconds > 0 && totalSentences > 0)
        ? ((_audioCurrentSeconds / _audioTotalSeconds) * totalSentences)
              .floor()
              .clamp(0, totalSentences - 1)
        : 0;

    int activeAudioParagraph = 0;
    int activeAudioSentence = 0;
    int runningCount = 0;
    for (int i = 0; i < paragraphSentences.length; i++) {
      final count = paragraphSentences[i].length;
      if (globalSentenceIndex < runningCount + count) {
        activeAudioParagraph = i;
        activeAudioSentence = globalSentenceIndex - runningCount;
        break;
      }
      runningCount += count;
    }

    return Scaffold(
      backgroundColor: readerBg,
      body: SafeArea(
        child: Stack(
          children: [
            if (!canReadCurrentChapter && bookProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkeletonLoader(width: 220, height: 28),
                      SizedBox(height: 16),
                      SkeletonLoader(width: double.infinity, height: 18),
                      SizedBox(height: 8),
                      SkeletonLoader(width: double.infinity, height: 18),
                      SizedBox(height: 8),
                      SkeletonLoader(width: 260, height: 18),
                    ],
                  ),
                ),
              )
            else if (!canReadCurrentChapter &&
                bookProvider.errorMessage != null)
              ErrorStateView(
                errorMessage: bookProvider.errorMessage!,
                onRetry: bookProvider.retryInitialization,
              )
            else if (!canReadCurrentChapter)
              EmptyStateView(
                icon: Icons.menu_book_rounded,
                title:
                    l10n?.t('reader.no_chapters') ?? 'Унших бүлэг алга байна',
                message:
                    l10n?.t('reader.no_chapters_desc') ??
                    'Энэ номын бүрэн текст уншигчид байхгүй байна.',
              )
            else if (themeProvider.isPaginated)
              ReaderPageView(
                book: currentBook,
                currentChapter: currentChapter!,
                currentChapterIndex: currentChapterIndex,
                currentPageInChapter: _currentPageInChapter,
                chapters: chapters,
                pageController: _pageController,
                themeProvider: themeProvider,
                readerTextColor: readerTextColor,
                isAudioPlaying: _isAudioPlaying,
                activeAudioParagraph: activeAudioParagraph,
                activeAudioSentence: activeAudioSentence,
                onPageChanged: (idx) {
                  setState(() => _currentPageInChapter = idx);
                  _reportPaginatedProgress(
                    idx,
                    ReaderThemeHelpers.paginateChapter(
                      currentChapter.content,
                    ).length,
                  );
                },
                onGoToChapter: (idx) => _goToChapter(idx),
                onToggleControls: _toggleControls,
                onShowHighlight: (text) => _showHighlightModal(text),
                l10n: l10n,
              )
            else
              ReaderScrollView(
                book: currentBook,
                currentChapter: currentChapter!,
                currentChapterIndex: currentChapterIndex,
                paragraphs: paragraphs,
                activeAudioParagraph: activeAudioParagraph,
                activeAudioSentence: activeAudioSentence,
                isAudioPlaying: _isAudioPlaying,
                scrollController: _scrollController,
                themeProvider: themeProvider,
                readerTextColor: readerTextColor,
                onToggleControls: _toggleControls,
                onShowHighlight: (text) => _showHighlightModal(text),
                onGoToChapter: (idx) => _goToChapter(idx),
                l10n: l10n,
              ),
            ReaderTopHud(
              showControls: _showControls,
              readerBg: readerBg,
              readerTextColor: readerTextColor,
              book: currentBook,
              isAudioPlaying: _isAudioPlaying,
              onBack: () => Navigator.of(context).pop(),
              onOpenSearch: _showSearchSheet,
              onOpenToc: _showTableOfContents,
              onOpenAppearance: _showAppearanceSheet,
              canReadCurrentChapter: canReadCurrentChapter,
              onToggleAudio: () {
                if (!canReadCurrentChapter) return;
                if (_isAudioPlaying) {
                  _pauseAudio();
                } else {
                  _startAudio();
                }
              },
              onAddBookmark: () {
                if (currentChapter == null ||
                    currentChapter.content.trim().isEmpty) {
                  return;
                }
                String quote;
                if (themeProvider.isPaginated) {
                  final pages = ReaderThemeHelpers.paginateChapter(
                    currentChapter.content,
                  );
                  final curPageText =
                      (pages.isNotEmpty && _currentPageInChapter < pages.length)
                      ? pages[_currentPageInChapter]
                      : currentChapter.content;
                  final pageParas = curPageText
                      .split('\n\n')
                      .where((p) => p.trim().isNotEmpty)
                      .toList();
                  quote = pageParas.isNotEmpty ? pageParas.first : curPageText;
                } else {
                  if (paragraphs.isNotEmpty) {
                    final targetIndex = (_scrollProgress * paragraphs.length)
                        .floor()
                        .clamp(0, paragraphs.length - 1);
                    quote = paragraphs[targetIndex];
                  } else {
                    quote = currentBook.title;
                  }
                }
                _showHighlightModal(quote);
              },
            ),
            if (currentChapter != null &&
                canReadCurrentChapter &&
                (_isAudioPlaying || _audioCurrentSeconds > 0))
              ReaderAudioBar(
                currentChapter: currentChapter,
                isAudioPlaying: _isAudioPlaying,
                audioCurrentSeconds: _audioCurrentSeconds,
                audioTotalSeconds: _audioTotalSeconds,
                audioSpeed: _audioSpeed,
                showControls: _showControls,
                onTogglePlay: () {
                  if (_isAudioPlaying) {
                    _pauseAudio();
                  } else {
                    _startAudio();
                  }
                },
                onSeek: (val) => _seekAudio(val),
                onSkip: (delta) => _skipAudio(delta),
                onChangeSpeed: () {
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
                  if (_isAudioPlaying) _seekAudio(_audioCurrentSeconds);
                },
                sleepTimerMinutes: _sleepTimerMinutes,
                onOpenSleepTimer: _showSleepTimerSheet,
                onClose: () {
                  _pauseAudio();
                  setState(() {
                    _audioCurrentSeconds = 0;
                    _audioCharacterPosition = 0;
                  });
                },
                l10n: l10n,
              ),
            if (currentChapter != null && canReadCurrentChapter)
              ReaderBottomHud(
                showControls: _showControls,
                readerBg: readerBg,
                readerTextColor: readerTextColor,
                isPaginated: themeProvider.isPaginated,
                scrollProgress: _scrollProgress,
                currentChapterIndex: currentChapterIndex,
                currentPageInChapter: _currentPageInChapter,
                currentChapter: currentChapter,
                chapters: chapters,
                l10n: l10n,
              ),
          ],
        ),
      ),
    );
  }
}
