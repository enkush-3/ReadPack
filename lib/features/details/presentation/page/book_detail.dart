import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/backbutton.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _isDescriptionExpanded = false;
  int _selectedTabIndex = 0;

  // Embedded Inline Review form state (NO MODAL)
  double _userRating = 5.0;
  late TextEditingController _nameController;
  late TextEditingController _commentController;
  bool _isReviewSubmitted = false;

  // Embedded Audio Preview player state
  bool _showAudioPlayer = false;
  bool _isAudioPlaying = false;
  double _audioCurrentSeconds = 0.0;
  double _audioTotalSeconds = 300.0;
  double _audioSpeed = 1.0;
  Timer? _audioTimer;

  bool get _isTesting => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _commentController = TextEditingController();

    if (widget.book.chapters.isNotEmpty) {
      _audioTotalSeconds =
          (widget.book.chapters.first.estimatedMinutes * 60).toDouble();
      if (_audioTotalSeconds <= 0) _audioTotalSeconds = 240.0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    _audioTimer?.cancel();
    super.dispose();
  }

  void _toggleAudioPlay() {
    if (_isAudioPlaying) {
      _audioTimer?.cancel();
      setState(() => _isAudioPlaying = false);
    } else {
      setState(() => _isAudioPlaying = true);
      if (_isTesting) return;

      _audioTimer?.cancel();
      _audioTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
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
          }
        });
      });
    }
  }

  String _formatTime(double totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds.toInt() % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _submitInlineReview(Book currentBook) {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    final userProfile = context.read<BookProvider>().userProfile;
    final userName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : userProfile.name;

    final newReview = BookReview(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      userName: userName,
      rating: _userRating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    context.read<BookProvider>().addReview(currentBook.id, newReview);
    _commentController.clear();

    setState(() {
      _isReviewSubmitted = true;
    });

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.t('reviews.success') ?? 'Таны сэтгэгдэл амжилттай нэмэгдлээ!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);

    // Get reactive updated book instance if present
    final currentBook = bookProvider.books.firstWhere(
      (b) => b.id == widget.book.id,
      orElse: () => widget.book,
    );

    final aboutText = l10n?.t('book.about') ?? 'Номын тухай';
    final readMoreText = l10n?.t('book.read_more') ?? 'Дэлгэрэнгүй унших';
    final showLessText = l10n?.t('book.show_less') ?? 'Хураангуйлах';
    final takeawaysText =
        l10n?.t('book.key_takeaways') ?? 'Гол санаанууд (Key Takeaways)';
    final chaptersText = l10n?.t('book.chapters') ?? 'Бүлгүүд';
    final reviewsTitle =
        l10n?.t('reviews.title') ?? 'Үнэлгээ & Сэтгэгдэл';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: Color(currentBook.colorHex),
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: CustomBackButton(
                  backgroundColor: Colors.white.withValues(alpha: 0.85),
                  iconColor: Color(currentBook.colorHex),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnimatedPressable(
                  onTap: () {
                    bookProvider.toggleFavoriteBook(currentBook.id);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      currentBook.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: currentBook.isFavorite
                          ? Colors.redAccent
                          : Color(currentBook.colorHex),
                      size: 22,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: AnimatedPressable(
                  onTap: () {
                    bookProvider.toggleSaveBook(currentBook.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          currentBook.isSaved
                              ? (l10n?.t('book.added_to_saved') ??
                                  'Ном хадгалагдлаа')
                              : (l10n?.t('book.removed_from_saved') ??
                                  'Хадгалсан номнуудаас хасагдлаа'),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      currentBook.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: currentBook.isSaved
                          ? colorScheme.primary
                          : Color(currentBook.colorHex),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(currentBook.colorHex),
                          Color(currentBook.colorHex).withValues(alpha: 0.8),
                          colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Hero(
                        tag: 'book_cover_${currentBook.id}',
                        child: Container(
                          width: 150,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: currentBook.image != null
                                ? Image.asset(
                                    currentBook.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildPlaceholderCover(currentBook),
                                  )
                                : _buildPlaceholderCover(currentBook),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      currentBook.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      currentBook.author,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),

                  // Tags
                  if (currentBook.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: currentBook.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  _buildStatsRow(currentBook, colorScheme, l10n),
                  const SizedBox(height: 20),
                  _buildActionButtons(currentBook, colorScheme, l10n),

                  // Embedded Audio Player Section
                  if (_showAudioPlayer) ...[
                    const SizedBox(height: 20),
                    _buildEmbeddedAudioPlayer(currentBook, colorScheme, l10n),
                  ],

                  // 4-Tab Navigation
                  _buildTabBar(colorScheme, l10n),

                  if (_selectedTabIndex == 0) ...[
                    // Synopsis
                    const SizedBox(height: 20),
                    Text(
                    aboutText,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentBook.description,
                    maxLines: _isDescriptionExpanded ? null : 4,
                    overflow: _isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.75),
                      height: 1.6,
                    ),
                  ),
                  if (currentBook.description.length > 150)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDescriptionExpanded = !_isDescriptionExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _isDescriptionExpanded ? showLessText : readMoreText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                  // Key Takeaways (Blinkist / Apple Books Feature)
                  if (currentBook.keyTakeaways.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                takeawaysText,
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...currentBook.keyTakeaways.map((takeaway) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 6, right: 8),
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      takeaway,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.8),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  _buildAuthorCard(currentBook, colorScheme, l10n),
                ],

                if (_selectedTabIndex == 1) ...[
                  // Table of Contents
                  const SizedBox(height: 20),
                  Text(
                    chaptersText,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (currentBook.chapters.isEmpty)
                    EmptyStateView(
                      icon: Icons.menu_book_rounded,
                      title: l10n?.t('reader.no_chapters') ??
                          'Бүлэг хараахан ороогүй байна',
                      message: l10n?.t('reader.no_chapters_desc') ??
                          'Номын бүлгүүд удахгүй шинэчлэгдэнэ.',
                    )
                  else
                    ...List.generate(currentBook.chapters.length, (index) {
                      final chapter = currentBook.chapters[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Routes.reader,
                                arguments: {
                                  'book': currentBook,
                                  'initialChapterIndex': index,
                                },
                              );
                            },
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            chapter.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            '~${chapter.estimatedMinutes} ${l10n?.t('book.minutes_read') ?? 'минут уншина'}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }),
                ],

                if (_selectedTabIndex == 0 || _selectedTabIndex == 2) ...[
                  // Reviews & Rating Section
                  const SizedBox(height: 32),
                  Text(
                    reviewsTitle,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRatingBreakdown(currentBook, colorScheme, l10n),

                  // EMBEDDED INLINE REVIEW FORM (NO MODAL)
                  const SizedBox(height: 20),
                  _buildEmbeddedReviewForm(currentBook, colorScheme, l10n),

                  // Reviews List
                  const SizedBox(height: 20),
                  if (currentBook.reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Text(
                        l10n?.t('reviews.empty') ??
                            'Анхны сэтгэгдлийг та бичээрэй!',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  else
                    ...currentBook.reviews.map((rev) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: colorScheme.primary
                                          .withValues(alpha: 0.15),
                                      child: Text(
                                        rev.userName.isNotEmpty
                                            ? rev.userName[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      rev.userName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 15, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(
                                      rev.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              rev.comment,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedPressable(
                                  onTap: () {
                                    context
                                        .read<BookProvider>()
                                        .toggleReviewHelpful(currentBook.id, rev.id);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: rev.isHelpful
                                          ? colorScheme.primary.withValues(alpha: 0.12)
                                          : colorScheme.surfaceContainerHighest
                                              .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: rev.isHelpful
                                            ? colorScheme.primary
                                            : colorScheme.outlineVariant
                                                .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          rev.isHelpful
                                              ? Icons.thumb_up_alt_rounded
                                              : Icons.thumb_up_off_alt_rounded,
                                          size: 13,
                                          color: rev.isHelpful
                                              ? colorScheme.primary
                                              : colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rev.helpfulCount > 0
                                              ? '${rev.helpfulCount} ${l10n?.t('book.helpful') ?? 'тустай'}'
                                              : (l10n?.t('book.helpful_btn') ?? 'Тустай 👍'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: rev.isHelpful
                                                ? colorScheme.primary
                                                : colorScheme.onSurface
                                                    .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],

                if (_selectedTabIndex == 3) ...[
                  _buildSimilarBooks(currentBook, colorScheme, l10n),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildTabBar(ColorScheme colorScheme, AppLocalizations? l10n) {
    final tabs = [
      l10n?.t('book.tabs.overview') ?? 'Тойм',
      l10n?.t('book.tabs.chapters') ?? 'Бүлгүүд',
      l10n?.t('book.tabs.reviews') ?? 'Шүүмж',
      l10n?.t('book.tabs.similar') ?? 'Ижил төстэй',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAuthorCard(
      Book currentBook, ColorScheme colorScheme, AppLocalizations? l10n) {
    final isEn = l10n?.locale.languageCode == 'en';
    String bio;
    if (currentBook.author.contains('Orwell')) {
      bio = isEn
          ? 'George Orwell (1903–1950) was a renowned English novelist, essayist, and critic, famed for "1984" and "Animal Farm".'
          : 'Жорж Орвелл (1903–1950) нь Английн нэрт зохиолч, сэтгүүлч, шүүмжлэгч. Түүний "1984" болон "Амьтны ферм" романууд нь 20-р зууны тоталитаризмын эсрэг хамгийн хүчирхэг бүтээлүүд юм.';
    } else if (currentBook.author.contains('Clear')) {
      bio = isEn
          ? 'James Clear is a bestselling author and keynote speaker on habits, decision-making, and continuous improvement.'
          : 'Жэймс Клир нь дадал зуршил, шийдвэр гаргалт, хувь хүний тасралтгүй хөгжлийн чиглэлээр дэлхийд хүлээн зөвшөөрөгдсөн зохиолч, илтгэгч юм.';
    } else if (currentBook.author.contains('Parrish')) {
      bio = isEn
          ? 'Shane Parrish is an entrepreneur, author, and the founder of Farnam Street, helping leaders make better decisions.'
          : 'Шейн Парриш нь "Farnam Street" платформыг үндэслэгч, шийдвэр гаргалт ба сэтгэлгээний загваруудын шилдэг эксперт юм.';
    } else if (currentBook.author.contains('Harari')) {
      bio = isEn
          ? 'Yuval Noah Harari is an Oxford-educated historian, philosopher, and bestselling author of Sapiens and Homo Deus.'
          : 'Ювал Ной Харари нь Оксфордын их сургуулийн түүхийн ухааны доктор, дэлхийн түүх ба ирээдүйн чиг хандлагыг тодорхойлогч философич юм.';
    } else {
      bio = isEn
          ? '${currentBook.author} is an internationally acclaimed author celebrated for insightful and transformative works.'
          : '${currentBook.author} нь олон улсын шилдэг бүтээлүүдээрээ уншигчдын талархлыг хүлээсэн нэр хүндтэй зохиолч юм.';
    }

    final allBooks = context.watch<BookProvider>().books;
    final relatedBooks = allBooks
        .where((b) =>
            b.id != currentBook.id &&
            (b.author.toLowerCase() == currentBook.author.toLowerCase() ||
                b.category.toLowerCase() == currentBook.category.toLowerCase()))
        .take(4)
        .toList();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(currentBook.colorHex).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Color(currentBook.colorHex), width: 2),
                ),
                child: Center(
                  child: Text(
                    currentBook.author.isNotEmpty ? currentBook.author[0] : 'A',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(currentBook.colorHex),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n?.t('book.about_author') ?? 'Зохиолчийн тухай',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentBook.author,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          if (relatedBooks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n?.t('book.more_by_author') ?? 'Зохиолчийн бусад номууд',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: relatedBooks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, idx) {
                  final rb = relatedBooks[idx];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => BookDetailPage(book: rb),
                        ),
                      );
                    },
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(rb.colorHex).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(rb.colorHex).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_rounded,
                              size: 24, color: Color(rb.colorHex)),
                          const SizedBox(height: 6),
                          Text(
                            rb.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimilarBooks(
      Book currentBook, ColorScheme colorScheme, AppLocalizations? l10n) {
    final allBooks = context.watch<BookProvider>().books;
    final similar = allBooks.where((b) => b.id != currentBook.id).toList();

    similar.sort((a, b) {
      final aAuthorMatch =
          a.author.toLowerCase() == currentBook.author.toLowerCase() ? 2 : 0;
      final bAuthorMatch =
          b.author.toLowerCase() == currentBook.author.toLowerCase() ? 2 : 0;
      final aCatMatch =
          a.category.toLowerCase() == currentBook.category.toLowerCase()
              ? 1
              : 0;
      final bCatMatch =
          b.category.toLowerCase() == currentBook.category.toLowerCase()
              ? 1
              : 0;
      return (bAuthorMatch + bCatMatch).compareTo(aAuthorMatch + aCatMatch);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          l10n?.t('book.tabs.similar') ?? 'Ижил төстэй номууд',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        ...similar.map((b) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => BookDetailPage(book: b),
                    ),
                  );
                },
                leading: Container(
                  width: 44,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(b.colorHex),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      b.title.isNotEmpty ? b.title[0] : '',
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  b.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  '${b.author} • ⭐ ${b.rating}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Embedded Inline Review Form (No Modal)
  Widget _buildEmbeddedReviewForm(
      Book currentBook, ColorScheme colorScheme, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.t('reviews.write_review') ?? 'Сэтгэгдэл бичих',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _userRating = star.toDouble());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        _userRating >= star
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          if (_isReviewSubmitted) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.t('reviews.success') ??
                          'Таны сэтгэгдэл амжилттай нэмэгдлээ!',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: l10n?.t('reviews.your_name_hint') ??
                  'Нэрээ оруулна уу (заавал биш)',
              hintStyle: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n?.t('reviews.your_comment_hint') ??
                  'Энэ номын талаар сэтгэгдлээ хуваалцаарай...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedPressable(
              onTap: () => _submitInlineReview(currentBook),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded,
                        size: 14, color: colorScheme.onPrimary),
                    const SizedBox(width: 6),
                    Text(
                      l10n?.t('reviews.submit') ?? 'Илгээх',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Embedded Audio Preview Player
  Widget _buildEmbeddedAudioPlayer(
      Book currentBook, ColorScheme colorScheme, AppLocalizations? l10n) {
    final chapterTitle = currentBook.chapters.isNotEmpty
        ? currentBook.chapters.first.title
        : currentBook.title;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.7),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones_rounded,
                    size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.t('book.audio_narration') ?? 'Аудио хүүрнэл',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      chapterTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  _audioTimer?.cancel();
                  setState(() {
                    _isAudioPlaying = false;
                    _showAudioPlayer = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isAudioPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 40,
                  color: colorScheme.primary,
                ),
                onPressed: _toggleAudioPlay,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _audioCurrentSeconds,
                    max: _audioTotalSeconds,
                    activeColor: colorScheme.primary,
                    inactiveColor:
                        colorScheme.outlineVariant.withValues(alpha: 0.4),
                    onChanged: (val) {
                      setState(() => _audioCurrentSeconds = val);
                    },
                  ),
                ),
              ),
              Text(
                '${_formatTime(_audioCurrentSeconds)} / ${_formatTime(_audioTotalSeconds)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_audioSpeed}x',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown(
      Book book, ColorScheme colorScheme, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                book.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < book.rating.floor()
                        ? Icons.star_rounded
                        : Icons.star_half_rounded,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '${book.reviewsCount} ${l10n?.t('reviews.ratings_count') ?? 'үнэлгээ'}',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.78, colorScheme),
                _buildRatingBar(4, 0.15, colorScheme),
                _buildRatingBar(3, 0.05, colorScheme),
                _buildRatingBar(2, 0.01, colorScheme),
                _buildRatingBar(1, 0.01, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double pct, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearPercentIndicator(
                lineHeight: 6,
                percent: pct,
                padding: EdgeInsets.zero,
                backgroundColor:
                    colorScheme.outlineVariant.withValues(alpha: 0.3),
                progressColor: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover(Book book) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(book.colorHex),
            Color(book.colorHex).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, color: Colors.white, size: 36),
            const SizedBox(height: 12),
            Text(
              book.title,
              textAlign: TextAlign.center,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
      Book book, ColorScheme colorScheme, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.star_rounded,
            iconColor: Colors.amber,
            value: book.rating.toStringAsFixed(1),
            label:
                '${book.reviewsCount} ${l10n?.t('reviews.ratings_count') ?? 'үнэлгээ'}',
            colorScheme: colorScheme,
          ),
          Container(
            height: 30,
            width: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          _buildStatItem(
            icon: Icons.auto_stories_rounded,
            iconColor: colorScheme.primary,
            value: '${book.pages}',
            label: l10n?.t('book.pages') ?? 'Хуудас',
            colorScheme: colorScheme,
          ),
          Container(
            height: 30,
            width: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          _buildStatItem(
            icon: Icons.access_time_rounded,
            iconColor: colorScheme.secondary,
            value: '${book.readTimeMinutes} ${l10n?.t('common.minutes_short') ?? 'м'}',
            label: l10n?.t('book.duration') ?? 'Хугацаа',
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      Book book, ColorScheme colorScheme, AppLocalizations? l10n) {
    final isStarted = book.progress > 0;
    final progressPct = (book.progress * 100).toInt();

    final readButtonLabel = isStarted
        ? '${l10n?.t('book.continue_reading') ?? 'Үргэлжлүүлэх'} ($progressPct%)'
        : (l10n?.t('book.start_reading') ?? 'Уншиж эхлэх');

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AnimatedPressable(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.reader,
                arguments: {
                  'book': book,
                  'initialChapterIndex': book.currentChapterIndex,
                },
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isStarted
                        ? Icons.play_arrow_rounded
                        : Icons.auto_stories_rounded,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    readButtonLabel,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: AnimatedPressable(
            onTap: () {
              setState(() {
                _showAudioPlayer = !_showAudioPlayer;
                if (_showAudioPlayer) {
                  _toggleAudioPlay();
                }
              });
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _showAudioPlayer
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _showAudioPlayer
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.headphones_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
