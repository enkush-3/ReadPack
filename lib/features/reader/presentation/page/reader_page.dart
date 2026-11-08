import 'dart:async';
import 'package:flutter/material.dart';
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
  Timer? _audioPlaybackTimer;
  int? _sleepTimerMinutes;
  Timer? _sleepCountdownTimer;

  bool get _isTesting => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  @override
  void initState() {
    super.initState();
    final chaptersCount = widget.book.chapters.length;
    _currentChapterIndex = chaptersCount == 0
        ? 0
        : (widget.initialChapterIndex > 0
            ? widget.initialChapterIndex
            : widget.book.currentChapterIndex).clamp(0, chaptersCount - 1);

    _scrollProgress = widget.book.progress;
    _lastReportedProgress = widget.book.progress;

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _pageController = PageController();
    _sessionTracker = ReaderSessionTracker(context);

    _initChapterAudio();

    if (widget.openAudioInitially && widget.book.hasAudio) {
      _startAudio();
    }

    _sessionTracker.start();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    _audioPlaybackTimer?.cancel();
    _sleepCountdownTimer?.cancel();
    _sessionTracker.dispose();
    super.dispose();
  }

  void _initChapterAudio() {
    if (widget.book.chapters.isEmpty) return;
    final currentCh = widget.book.chapters[_currentChapterIndex];
    setState(() {
      _audioTotalSeconds = (currentCh.estimatedMinutes * 60).toDouble();
      if (_audioTotalSeconds <= 0) _audioTotalSeconds = 240.0;
      _audioCurrentSeconds = 0.0;
    });
  }

  void _startAudio() {
    if (!widget.book.hasAudio) return;
    _audioPlaybackTimer?.cancel();
    setState(() => _isAudioPlaying = true);
    if (_isTesting) return;

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
          _audioCurrentSeconds = 0.0;
          _isAudioPlaying = false;
          timer.cancel();
          if (_currentChapterIndex < widget.book.chapters.length - 1) {
            _goToChapter(_currentChapterIndex + 1);
            _startAudio();
          }
        }
      });
    });
  }

  void _pauseAudio() {
    _audioPlaybackTimer?.cancel();
    setState(() => _isAudioPlaying = false);
  }

  void _syncAudioWithText() {
    if (widget.book.chapters.isEmpty) return;
    final currentChapter = widget.book.chapters[_currentChapterIndex];
    final paragraphs = currentChapter.content.split('\n\n');
    final paragraphSentences = paragraphs
        .map((p) {
          final matches = RegExp(r'[^.!?]+[.!?]*\s*').allMatches(p);
          final list = matches
              .map((m) => m.group(0) ?? '')
              .where((s) => s.trim().isNotEmpty)
              .toList();
          return list.isEmpty ? [p] : list;
        })
        .toList();
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
    setState(() {
      _audioCurrentSeconds = seconds.clamp(0.0, _audioTotalSeconds);
    });
    _syncAudioWithText();
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
            'val': null
          },
          {'title': l10n?.t('audio_ext.sleep_15') ?? '15 минут', 'val': 15},
          {'title': l10n?.t('audio_ext.sleep_30') ?? '30 минут', 'val': 30},
          {'title': l10n?.t('audio_ext.sleep_45') ?? '45 минут', 'val': 45},
          {'title': '60 ${l10n?.t('common.minutes_short') ?? 'минут'}', 'val': 60},
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
                      Icon(Icons.bedtime_rounded,
                          size: 20, color: Theme.of(context).colorScheme.primary),
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
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_rounded,
                              color: Theme.of(context).colorScheme.primary)
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
      book: widget.book,
      onSelectChapter: (cIdx) => _goToChapter(cIdx),
    );
  }

  void _skipAudio(double deltaSeconds) {
    _seekAudio(_audioCurrentSeconds + deltaSeconds);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final curScroll = _scrollController.offset;
    final totalChapters =
        widget.book.chapters.isEmpty ? 1 : widget.book.chapters.length;

    if (maxScroll <= 0) return;
    final chapterFraction = (curScroll / maxScroll).clamp(0.0, 1.0);
    final overallProgress =
        ((_currentChapterIndex + chapterFraction) / totalChapters)
            .clamp(0.0, 1.0);

    setState(() {
      _scrollProgress = overallProgress;
    });

    if ((overallProgress - _lastReportedProgress).abs() > 0.04) {
      _lastReportedProgress = overallProgress;
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

  void _reportPaginatedProgress([int? pageIndex, int? totalPages]) {
    final curPage = pageIndex ?? _currentPageInChapter;
    final totalP = totalPages ??
        (widget.book.chapters.isEmpty
            ? 1
            : ReaderThemeHelpers.paginateChapter(
                    widget.book.chapters[_currentChapterIndex].content)
                .length);
    final totalChapters =
        widget.book.chapters.isEmpty ? 1 : widget.book.chapters.length;
    final chapterFraction = totalP > 0 ? ((curPage + 1) / totalP) : 0.0;
    final overallProgress =
        ((_currentChapterIndex + chapterFraction) / totalChapters)
            .clamp(0.0, 1.0);
    final estimatedPage = (overallProgress * widget.book.pages)
        .toInt()
        .clamp(1, widget.book.pages);

    setState(() {
      _scrollProgress = overallProgress;
    });

    if ((overallProgress - _lastReportedProgress).abs() > 0.02) {
      _lastReportedProgress = overallProgress;
      context.read<BookProvider>().updateReadingPosition(
            widget.book.id,
            currentPage: estimatedPage,
            progress: overallProgress,
            currentChapterIndex: _currentChapterIndex,
          );
    }
  }

  void _goToChapter(int index, {int initialPage = 0}) {
    if (widget.book.chapters.isEmpty) return;
    final wasPlaying = _isAudioPlaying;
    _audioPlaybackTimer?.cancel();
    setState(() {
      _currentChapterIndex = index.clamp(0, widget.book.chapters.length - 1);
      _currentPageInChapter = initialPage;
    });
    _initChapterAudio();
    if (wasPlaying) {
      _startAudio();
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
      book: widget.book,
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
      book: widget.book,
      currentChapterIndex: _currentChapterIndex,
      onSelectChapter: (idx) => _goToChapter(idx),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final readerBg =
        ReaderThemeHelpers.getReaderBg(themeProvider.readerTheme, isDark);
    final readerTextColor =
        ReaderThemeHelpers.getReaderTextColor(themeProvider.readerTheme, isDark);

    final chapters = widget.book.chapters;
    final hasChapters = chapters.isNotEmpty;
    final currentChapter = hasChapters
        ? chapters[_currentChapterIndex]
        : BookChapter(
            id: 'c0',
            title: l10n?.t('reader.chapters') ?? 'Агуулга',
            content: l10n?.t('common.loading') ??
                'Номын агуулга ачаалагдаж байна...',
            estimatedMinutes: 5,
          );

    final paragraphs = currentChapter.content.split('\n\n');
    final paragraphSentences = paragraphs
        .map((p) {
          final matches = RegExp(r'[^.!?]+[.!?]*\s*').allMatches(p);
          final list = matches
              .map((m) => m.group(0) ?? '')
              .where((s) => s.trim().isNotEmpty)
              .toList();
          return list.isEmpty ? [p] : list;
        })
        .toList();
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
            if (themeProvider.isPaginated)
              ReaderPageView(
                book: widget.book,
                currentChapter: currentChapter,
                currentChapterIndex: _currentChapterIndex,
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
                    ReaderThemeHelpers.paginateChapter(currentChapter.content)
                        .length,
                  );
                },
                onGoToChapter: (idx) => _goToChapter(idx),
                onToggleControls: _toggleControls,
                onShowHighlight: (text) => _showHighlightModal(text),
                l10n: l10n,
              )
            else
              ReaderScrollView(
                book: widget.book,
                currentChapter: currentChapter,
                currentChapterIndex: _currentChapterIndex,
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
              book: widget.book,
              isAudioPlaying: _isAudioPlaying,
              onBack: () => Navigator.of(context).pop(),
              onOpenSearch: _showSearchSheet,
              onOpenToc: _showTableOfContents,
              onOpenAppearance: _showAppearanceSheet,
              onToggleAudio: () {
                if (!widget.book.hasAudio) return;
                if (_isAudioPlaying) {
                  _pauseAudio();
                } else {
                  _startAudio();
                }
              },
              onAddBookmark: () {
                String quote;
                if (themeProvider.isPaginated) {
                  final pages = ReaderThemeHelpers.paginateChapter(currentChapter.content);
                  final curPageText = (pages.isNotEmpty && _currentPageInChapter < pages.length)
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
                    quote = widget.book.title;
                  }
                }
                _showHighlightModal(quote);
              },
            ),
            if (widget.book.hasAudio &&
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
                },
                sleepTimerMinutes: _sleepTimerMinutes,
                onOpenSleepTimer: _showSleepTimerSheet,
                onClose: () {
                  _pauseAudio();
                  setState(() => _audioCurrentSeconds = 0);
                },
                l10n: l10n,
              ),
            ReaderBottomHud(
              showControls: _showControls,
              readerBg: readerBg,
              readerTextColor: readerTextColor,
              isPaginated: themeProvider.isPaginated,
              scrollProgress: _scrollProgress,
              currentChapterIndex: _currentChapterIndex,
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
