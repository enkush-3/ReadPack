import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/home/widgets/books_card.dart';
import 'package:readpack/features/home/widgets/categories.dart';
import 'package:readpack/features/home/widgets/continue_reading_card.dart';
import 'package:readpack/features/home/widgets/features_book.dart';
import 'package:readpack/features/home/widgets/header.dart';
import 'package:readpack/features/shared/common/refresh.dart';
import 'package:readpack/features/shared/widgets/quote_share_modal.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomePage({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _categoryKeys = [
    'book.categories.all',
    'book.categories.business',
    'book.categories.science',
    'book.categories.history',
    'book.categories.romance',
    'book.categories.adventure',
  ];
  int _selectedCategoryIndex = 0;

  List<String> _getCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _categoryKeys
        .map((key) => l10n?.t(key) ?? key.split('.').last)
        .toList();
  }

  void _onCategoryChanged(int index) {
    setState(() => _selectedCategoryIndex = index);
    context
        .read<BookProvider>()
        .setSelectedCategory(_categoryKeys[_selectedCategoryIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);
    final userName = bookProvider.userProfile.name;

    final featuredTitle =
        l10n?.t('book.feature') ?? 'Онцлох номнууд';
    final dailyQuoteTitle =
        l10n?.t('home.daily_quote_title') ?? 'Өдрийн эшлэл';
    final dailyQuote = l10n?.t('home.daily_quote') ??
        'Ном уншдаг хүн үхэхээсээ өмнө мянган амьдралаар амьдардаг.';
    final dailyQuoteAuthor =
        l10n?.t('home.daily_quote_author') ?? 'Жорж Р.Р. Мартин';
    final booksCountText = l10n?.t('home.books_count') ?? 'ном';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshWrapper(
          onRefresh: () => bookProvider.refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header with Avatar, Greeting, Reading Streak flame badge, and Notifications
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: HomeHeader(
                    userName: userName,
                    onAvatarTap: () => widget.onNavigateTab?.call(3),
                  ),
                ),
              ),

              // 2. Loading State Handling
              if (bookProvider.isLoading) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: SkeletonLoader(
                      width: double.infinity,
                      height: 120,
                      borderRadius: 20,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (_, __) => const BookCardSkeleton(),
                      ),
                    ),
                  ),
                ),
              ] else if (bookProvider.errorMessage != null) ...[
                // 3. Error State Handling
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateView(
                    errorMessage: bookProvider.errorMessage!,
                    onRetry: () => bookProvider.refresh(),
                  ),
                ),
              ] else ...[
                // 4. Hero Daily Inspiration / Quote Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer.withValues(alpha: 0.6),
                            colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.format_quote_rounded,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dailyQuoteTitle,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        QuoteShareModal.show(
                                          context,
                                          quote: dailyQuote,
                                          author: dailyQuoteAuthor,
                                          bookTitle: 'ReadPack Daily',
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.share_rounded,
                                                size: 13,
                                                color: colorScheme.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              l10n?.t('quote_share.share') ??
                                                  'Хуваалцах',
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
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '"$dailyQuote"',
                                  style: TextStyle(
                                    fontFamily: 'Serif',
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.85),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '— $dailyQuoteAuthor',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 5. Continue Reading Section (if any in progress)
                if (bookProvider.continueReadingBooks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ContinueReadingCard(
                        book: bookProvider.continueReadingBooks.first,
                        onTap: () {
                          final currentBook =
                              bookProvider.continueReadingBooks.first;
                          Navigator.of(context).pushNamed(
                            Routes.reader,
                            arguments: {
                              'book': currentBook,
                              'initialChapterIndex':
                                  currentBook.currentChapterIndex,
                            },
                          );
                        },
                      ),
                    ),
                  ),

                // 6. Featured Books Section
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          featuredTitle,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 290,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: bookProvider.featuredBooks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final book = bookProvider.featuredBooks[index];
                            return FeaturedBookCard(
                              book: book,
                              title: book.title,
                              author: book.author,
                              color: Color(book.colorHex),
                              image: book.image ?? '',
                              category: l10n?.t(book.category) ?? 'Онцлох',
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  Routes.bookDetail,
                                  arguments: book,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // 7. Categories Selector
                SliverToBoxAdapter(
                  child: Categories(
                    categories: _getCategories(context),
                    selectedIndex: _selectedCategoryIndex,
                    onChanged: _onCategoryChanged,
                  ),
                ),

                // 8. Category Header with Book Count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getCategories(context)[_selectedCategoryIndex],
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${bookProvider.filteredBooks.length} $booksCountText',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 9. Books Grid or Empty State
                if (bookProvider.filteredBooks.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: l10n?.t('home.empty_category_title') ??
                          'Энэ ангилалд ном олдсонгүй',
                      message: l10n?.t('home.empty_category_desc') ??
                          'Өөр ангилал сонгож үзнэ үү.',
                      actionLabel: l10n?.t('home.view_all_books') ??
                          'Бүх номыг харах',
                      onAction: () => _onCategoryChanged(0),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24)
                        .copyWith(bottom: 32),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = bookProvider.filteredBooks[index];
                          return BookCard(
                            book: book,
                            title: book.title,
                            author: book.author,
                            rating: book.rating,
                            image: book.image,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Routes.bookDetail,
                                arguments: book,
                              );
                            },
                          );
                        },
                        childCount: bookProvider.filteredBooks.length,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}