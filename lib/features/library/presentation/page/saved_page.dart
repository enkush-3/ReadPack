import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/shared/common/refresh.dart';
import 'package:readpack/features/shared/widgets/quote_share_modal.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/collection.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);

    final libraryTitle = l10n?.t('library.title') ?? 'Миний Сан';
    final readingSegment =
        l10n?.t('library.currently_reading') ?? 'Уншиж буй';
    final savedSegment = l10n?.t('library.saved') ?? 'Хадгалсан';
    final shelvesSegment =
        l10n?.t('library.shelves') ?? 'Цуглуулгууд';
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
                                horizontal: 12, vertical: 6),
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
                      // 4-Segment Switcher (Reading, Saved, Shelves, Quotes)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _buildSegmentItem(0, readingSegment),
                            _buildSegmentItem(1, savedSegment),
                            _buildSegmentItem(2, shelvesSegment),
                            _buildSegmentItem(3, quotesSegment),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sort & Offline Download Manager Bar for Reading and Saved segments
              if (_selectedSegment == 0 || _selectedSegment == 1)
                SliverToBoxAdapter(
                  child: _buildSortAndFilterBar(bookProvider, colorScheme, l10n),
                ),

              _buildContent(bookProvider, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentItem(int index, String label) {
    final isSelected = _selectedSegment == index;
    final colorScheme = Theme.of(context).colorScheme;

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

  Widget _buildSortAndFilterBar(
      BookProvider provider, ColorScheme colorScheme, AppLocalizations? l10n) {
    final sortLabels = {
      'recent': l10n?.t('library.sort_recent') ?? 'Сүүлд уншсан',
      'title': l10n?.t('library.sort_title') ?? 'Гарчгаар',
      'author': l10n?.t('library.sort_author') ?? 'Зохиолчоор',
      'progress': l10n?.t('library.sort_progress') ?? 'Явцаар',
      'rating': l10n?.t('library.sort_rating') ?? 'Үнэлгээгээр',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PopupMenuButton<String>(
            initialValue: provider.librarySortBy,
            onSelected: (val) => provider.setLibrarySortBy(val),
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) {
              return sortLabels.entries.map((entry) {
                final isSelected = provider.librarySortBy == entry.key;
                return PopupMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded,
                      size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    sortLabels[provider.librarySortBy] ?? 'Эрэмбэ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_done_rounded,
                    size: 14, color: Colors.green),
                const SizedBox(width: 5),
                Text(
                  '${provider.downloadedBookIds.length} ${l10n?.t('library.downloaded') ?? 'татагдсан'} (${provider.totalDownloadedStorageMb.toStringAsFixed(1)} MB)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BookProvider provider, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);

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
              return _buildReadingBookCard(book, provider, colorScheme);
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
              return _buildSavedGridCard(book, provider, colorScheme);
            },
            childCount: savedBooks.length,
          ),
        ),
      );
    }

    // 5. Segment 2: Custom Shelves / Collections
    if (_selectedSegment == 2) {
      return _buildCollectionsSegment(provider, colorScheme, l10n);
    }

    // 6. Segment 3: Quotes / Bookmarks
    final bookmarks = provider.bookmarks;
    if (bookmarks.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateView(
          icon: Icons.format_quote_rounded,
          title: l10n?.t('library.empty_quotes_title') ??
              'Тэмдэглэсэн ишлэл одоогоор алга',
          message: l10n?.t('library.empty_quotes_desc') ??
              'Ном уншиж байхдаа онцлох эшлэлээ тэмдэглэн авч, эндээс хараарай.',
          actionLabel: l10n?.t('library.explore_books') ?? 'Ном унших',
          onAction: () => widget.onNavigateTab?.call(0),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final bm = bookmarks[index];
            return _buildQuoteCard(bm, provider, colorScheme, l10n);
          },
          childCount: bookmarks.length,
        ),
      ),
    );
  }

  Widget _buildReadingBookCard(
      Book book, BookProvider provider, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    final progressPct = (book.progress * 100).toInt();
    final isDownloaded = provider.isBookDownloaded(book.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'saved_book_${book.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 68,
                height: 96,
                child: book.image != null
                    ? Image.asset(book.image!, fit: BoxFit.cover)
                    : Container(
                        color: Color(book.colorHex),
                        child:
                            const Icon(Icons.menu_book, color: Colors.white),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  book.author,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$progressPct% ${l10n?.t('library.read_percent') ?? 'уншсан'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    // Offline download toggle button
                    GestureDetector(
                      onTap: () {
                        provider.toggleDownloadBook(book.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.isBookDownloaded(book.id)
                                  ? 'Ном оффлайн уншихаар татагдлаа (${provider.getDownloadedSizeMb(book.id)} MB)'
                                  : 'Ном оффлайн сангаас хасагдлаа',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDownloaded
                              ? Colors.green.withValues(alpha: 0.12)
                              : colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDownloaded
                                ? Colors.green.withValues(alpha: 0.3)
                                : colorScheme.outlineVariant
                                    .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDownloaded
                                  ? Icons.download_done_rounded
                                  : Icons.download_rounded,
                              size: 11,
                              color: isDownloaded
                                  ? Colors.green
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isDownloaded
                                  ? '${provider.getDownloadedSizeMb(book.id)}MB'
                                  : 'Татах',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDownloaded
                                    ? Colors.green
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
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: book.progress,
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.15),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedPressable(
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: colorScheme.onPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedGridCard(
      Book book, BookProvider provider, ColorScheme colorScheme) {
    final isDownloaded = provider.isBookDownloaded(book.id);

    return AnimatedPressable(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.bookDetail,
          arguments: book,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: book.image != null
                        ? Image.asset(book.image!, fit: BoxFit.cover)
                        : Container(
                            color: Color(book.colorHex),
                            child: const Center(
                              child: Icon(Icons.menu_book,
                                  color: Colors.white, size: 36),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        provider.toggleSaveBook(book.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: GestureDetector(
                      onTap: () {
                        provider.toggleDownloadBook(book.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDownloaded
                                  ? Icons.download_done_rounded
                                  : Icons.download_rounded,
                              size: 11,
                              color: isDownloaded
                                  ? Colors.greenAccent
                                  : Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isDownloaded
                                  ? '${provider.getDownloadedSizeMb(book.id)}MB'
                                  : 'Татах',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isDownloaded
                                    ? Colors.greenAccent
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsSegment(
      BookProvider provider, ColorScheme colorScheme, AppLocalizations? l10n) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Create Shelf Button
          AnimatedPressable(
            onTap: () => _showCreateCollectionDialog(context, provider),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '+ Шинэ цуглуулга үүсгэх',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (provider.collections.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'Цуглуулга хараахан үүсгээгүй байна.',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            )
          else
            ...provider.collections.map((coll) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    onTap: () =>
                        _showCollectionDetailsSheet(context, coll, provider),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCollectionIcon(coll.icon),
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      coll.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (coll.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            coll.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${coll.bookIds.length} ном агуулсан',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: colorScheme.error.withValues(alpha: 0.7),
                      onPressed: () {
                        provider.deleteCollection(coll.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Цуглуулга устгагдлаа'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
        ]),
      ),
    );
  }

  IconData _getCollectionIcon(String iconKey) {
    switch (iconKey) {
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'lightbulb':
        return Icons.lightbulb_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'bookmark':
      default:
        return Icons.bookmark_rounded;
    }
  }

  void _showCreateCollectionDialog(
      BuildContext context, BookProvider provider) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedIcon = 'bookmark';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: const Text(
                'Шинэ цуглуулга үүсгэх',
                style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Цуглуулгын нэр',
                      hintText: 'ж.нь 2026 онд унших номууд',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Тайлбар (Заавал биш)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Икон сонгох:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      'bookmark',
                      'emoji_events',
                      'lightbulb',
                      'star',
                      'school'
                    ].map((iconKey) {
                      final isSelected = selectedIcon == iconKey;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() => selectedIcon = iconKey);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCollectionIcon(iconKey),
                            size: 20,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Цуцлах'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      provider.createCollection(
                        nameCtrl.text.trim(),
                        descCtrl.text.trim(),
                        icon: selectedIcon,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Шинэ цуглуулга амжилттай үүсгэгдлээ! (+30 XP)'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Үүсгэх'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCollectionDetailsSheet(
      BuildContext context, BookCollection collection, BookProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        final booksInCollection = provider.books
            .where((b) => collection.bookIds.contains(b.id))
            .toList();

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      collection.name,
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              if (collection.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  collection.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Add book to this collection button
              AnimatedPressable(
                onTap: () {
                  _showAddBookToCollectionPicker(context, collection, provider);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        '+ Энэ цуглуулгад ном нэмэх',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: booksInCollection.isEmpty
                    ? Center(
                        child: Text(
                          'Цуглуулгад одоогоор ном ороогүй байна.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: booksInCollection.length,
                        itemBuilder: (context, idx) {
                          final b = booksInCollection[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.of(context).pushNamed(
                                  Routes.bookDetail,
                                  arguments: b,
                                );
                              },
                              leading: Container(
                                width: 36,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color(b.colorHex),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    b.title.isNotEmpty ? b.title[0] : '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                b.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                b.author,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    size: 18),
                                color: colorScheme.error.withValues(alpha: 0.7),
                                onPressed: () {
                                  provider.removeBookFromCollection(
                                      collection.id, b.id);
                                  Navigator.pop(ctx);
                                },
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

  void _showAddBookToCollectionPicker(
      BuildContext context, BookCollection collection, BookProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (pickerCtx) {
        final colorScheme = Theme.of(context).colorScheme;
        final availableBooks = provider.books
            .where((b) => !collection.bookIds.contains(b.id))
            .toList();

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Цуглуулгад нэмэх номоо сонгоно уу',
                style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: availableBooks.length,
                  itemBuilder: (context, i) {
                    final b = availableBooks[i];
                    return ListTile(
                      title: Text(b.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(b.author, style: const TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.add_circle_outline_rounded),
                      onTap: () {
                        provider.addBookToCollection(collection.id, b.id);
                        Navigator.pop(pickerCtx);
                        Navigator.pop(context); // close parent sheet to refresh
                      },
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

  Widget _buildQuoteCard(Bookmark bm, BookProvider provider,
      ColorScheme colorScheme, AppLocalizations? l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: Color(bm.colorHex),
            width: 4,
          ),
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
          right: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${bm.bookTitle} • ${bm.chapterTitle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  provider.removeBookmark(bm.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n?.t('library.quote_deleted') ??
                          'Ишлэл устгагдлаа'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '“${bm.quote}”',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          if (bm.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bm.note,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Story Card Share Button
              AnimatedPressable(
                onTap: () {
                  final book = provider.books.firstWhere(
                    (b) => b.id == bm.bookId,
                    orElse: () => provider.books.first,
                  );
                  QuoteShareModal.show(
                    context,
                    quote: bm.quote,
                    bookTitle: bm.bookTitle,
                    author: book.author,
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        l10n?.t('library.share_story_btn') ?? 'Story карт',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedPressable(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: bm.quote));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n?.t('reader.quote_copied') ??
                          'Ишлэл амжилттай хуулагдлаа!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 13, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        l10n?.t('library.copy') ?? 'Хуулах',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedPressable(
                onTap: () {
                  final book = provider.books.firstWhere(
                    (b) => b.id == bm.bookId,
                    orElse: () => provider.books.first,
                  );
                  Navigator.of(context).pushNamed(
                    Routes.bookDetail,
                    arguments: book,
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n?.t('library.view_book') ?? 'Ном үзэх',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: colorScheme.onPrimary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
