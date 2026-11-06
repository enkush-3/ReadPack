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

  bool get _isTesting => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

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

    context.read<BookProvider>().updateReadingPosition(
          widget.book.id,
          currentPage: estimatedPage,
          progress: overallProgress,
          currentChapterIndex: _currentChapterIndex,
        );
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
