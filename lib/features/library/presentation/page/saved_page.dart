import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/library/widgets/library_quote_card.dart';
import 'package:readpack/features/library/widgets/library_reading_card.dart';
import 'package:readpack/features/library/widgets/library_saved_card.dart';
import 'package:readpack/features/library/widgets/library_shelves_view.dart';
import 'package:readpack/features/library/widgets/library_sort_bar.dart';
import 'package:readpack/features/shared/common/refresh.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class SavedPage extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const SavedPage({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  // 0: Currently Reading, 1: Saved, 2: Shelves / Collections, 3: Quotes
  int _selectedSegment = 0;
  int _quoteFilterIndex = 0; // 0: All, 1: Bookmarked, 2: Liked

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);

    final libraryTitle = l10n?.t('library.title') ?? 'Миний Сан';
    final readingSegment =
        l10n?.t('library.currently_reading') ?? 'Уншиж буй';
    final savedSegment = l10n?.t('library.saved') ?? 'Хадгалсан';
    final shelvesSegment = l10n?.t('library.shelves') ?? 'Цуглуулгууд';
    final quotesSegment = l10n?.t('library.quotes') ?? 'Ишлэлүүд';
    final booksCountText = l10n?.t('home.books_count') ?? 'ном';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshWrapper(
          onRefresh: () => bookProvider.refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            libraryTitle,
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${bookProvider.savedBooks.length + bookProvider.continueReadingBooks.length} $booksCountText',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 4-Segment Switcher
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _buildSegmentItem(0, readingSegment, colorScheme),
                            _buildSegmentItem(1, savedSegment, colorScheme),
                            _buildSegmentItem(2, shelvesSegment, colorScheme),
                            _buildSegmentItem(3, quotesSegment, colorScheme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sort Bar for Reading and Saved segments
              if (_selectedSegment == 0 || _selectedSegment == 1)
                SliverToBoxAdapter(
                  child: LibrarySortBar(provider: bookProvider),
                ),

              _buildContent(bookProvider, colorScheme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentItem(
    int index,
    String label,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedSegment == index;

    return Expanded(
      child: AnimatedPressable(
        onTap: () => setState(() => _selectedSegment = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BookProvider provider,
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
    // 1. Loading State
    if (provider.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: SkeletonLoader(
                width: double.infinity,
                height: 100,
                borderRadius: 16,
              ),
            ),
            childCount: 4,
          ),
        ),
      );
    }

    // 2. Error State
    if (provider.errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateView(
          errorMessage: provider.errorMessage!,
          onRetry: () => provider.refresh(),
        ),
      );
    }

    // 3. Segment 0: Currently Reading
    if (_selectedSegment == 0) {
      final readingBooks = provider.continueReadingBooks;
      if (readingBooks.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            icon: Icons.menu_book_rounded,
            title: l10n?.t('library.empty_reading_title') ??
                'Одоогоор уншиж буй ном алга',
            message: l10n?.t('library.empty_reading_desc') ??
                'Нүүр хуудаснаас сонирхсон номоо сонгоод уншиж эхлээрэй.',
            actionLabel: l10n?.t('library.explore_books') ?? 'Ном хайх',
            onAction: () => widget.onNavigateTab?.call(0),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final book = readingBooks[index];
              return LibraryReadingCard(
                book: book,
                provider: provider,
              );
            },
            childCount: readingBooks.length,
          ),
        ),
      );
    }

    // 4. Segment 1: Saved Books
    if (_selectedSegment == 1) {
      final savedBooks = provider.sortedSavedBooks;
      if (savedBooks.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            icon: Icons.bookmark_border_rounded,
            title: l10n?.t('library.empty_saved_title') ??
                'Хадгалсан ном байхгүй байна',
            message: l10n?.t('library.empty_saved_desc') ??
                'Дараа уншихаар хадгалсан номнууд тань энд харагдана.',
            actionLabel: l10n?.t('library.explore_books') ?? 'Номууд үзэх',
            onAction: () => widget.onNavigateTab?.call(0),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.60,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final book = savedBooks[index];
              return LibrarySavedCard(
                book: book,
                provider: provider,
              );
            },
            childCount: savedBooks.length,
          ),
        ),
      );
    }

    // 5. Segment 2: Custom Shelves / Collections
    if (_selectedSegment == 2) {
      return LibraryShelvesView(provider: provider);
    }

    // 6. Segment 3: Quotes / Bookmarks (All, Saved, Liked)
    final allBookmarks = provider.bookmarks;
    List<Bookmark> displayedBookmarks;
    if (_quoteFilterIndex == 1) {
      displayedBookmarks = allBookmarks.where((b) => !b.isLiked).toList();
    } else if (_quoteFilterIndex == 2) {
      displayedBookmarks = allBookmarks.where((b) => b.isLiked).toList();
    } else {
      displayedBookmarks = allBookmarks;
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Sub-Filter Bar & Add Quote Button
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildQuoteFilterChip(
                          index: 0,
                          label: 'Бүгд (${allBookmarks.length})',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _buildQuoteFilterChip(
                          index: 1,
                          label:
                              'Тэмдэглэсэн (${allBookmarks.where((b) => !b.isLiked).length})',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _buildQuoteFilterChip(
                          index: 2,
                          label:
                              'Таалагдсан ❤️ (${allBookmarks.where((b) => b.isLiked).length})',
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedPressable(
                  onTap: () => _showAddQuoteDialog(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: colorScheme.onPrimary),
                        const SizedBox(width: 4),
                        Text(
                          'Ишлэл нэмэх',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (displayedBookmarks.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _quoteFilterIndex == 2
                        ? Icons.favorite_border_rounded
                        : Icons.format_quote_rounded,
                    size: 40,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _quoteFilterIndex == 2
                        ? 'Таалагдсан ишлэл хараахан алга'
                        : 'Ишлэл олдсонгүй',
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _quoteFilterIndex == 2
                        ? 'Ишлэлүүд дээрх зүрхэн дээр дарж таалагдсандаа нэмээрэй.'
                        : 'Ном уншиж байхдаа онцлох эшлэлээ тэмдэглэн аваарай.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            ...displayedBookmarks.map((bm) {
              return LibraryQuoteCard(
                bm: bm,
                provider: provider,
              );
            }),
        ]),
      ),
    );
  }

  Widget _buildQuoteFilterChip({
    required int index,
    required String label,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _quoteFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _quoteFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  void _showAddQuoteDialog(BuildContext context, BookProvider provider) {
    if (provider.books.isEmpty) return;
    String selectedBookId = provider.books.first.id;
    final quoteController = TextEditingController();
    final noteController = TextEditingController();
    int selectedColor = 0xFFFFD54F;

    final colorOptions = [
      0xFFFFD54F, // amber
      0xFF81C784, // green
      0xFF64B5F6, // blue
      0xFFBA68C8, // purple
      0xFFFF8A80, // pink
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            final selectedBook = provider.books.firstWhere(
              (b) => b.id == selectedBookId,
              orElse: () => provider.books.first,
            );

            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Шинэ ишлэл тэмдэглэх',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ном сонгох:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedBookId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.3)),
                        ),
                      ),
                      items: provider.books.map((b) {
                        return DropdownMenuItem(
                          value: b.id,
                          child: Text(
                            b.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedBookId = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Ишлэлийн эх бичвэр:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: quoteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Таалагдсан эсвэл чухал ишлэлээ бичнэ үү...',
                        hintStyle: TextStyle(
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Хувийн тэмдэглэл (заавал биш):',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        hintText: 'Таны бодол, сэтгэгдэл...',
                        hintStyle: TextStyle(
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Тодруулах өнгө:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: colorOptions.map((c) {
                        final isSel = selectedColor == c;
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedColor = c),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: isSel
                                  ? Border.all(
                                      color: colorScheme.primary, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Болих'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final text = quoteController.text.trim();
                    if (text.isEmpty) return;

                    final newBm = Bookmark(
                      id: 'bm_${DateTime.now().millisecondsSinceEpoch}',
                      bookId: selectedBook.id,
                      bookTitle: selectedBook.title,
                      chapterTitle: selectedBook.chapters.isNotEmpty
                          ? selectedBook.chapters.first.title
                          : 'Бүлэг 1',
                      pageNumber: 1,
                      quote: text,
                      note: noteController.text.trim(),
                      colorHex: selectedColor,
                      isLiked: false,
                      createdAt: DateTime.now(),
                    );
                    provider.addBookmark(newBm);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ишлэл амжилттай хадгалагдлаа!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text('Хадгалах'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
