import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/details/presentation/page/book_detail.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/book_cover_image.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class BookDetailSimilarTab extends StatelessWidget {
  final Book currentBook;
  final AppLocalizations? l10n;

  const BookDetailSimilarTab({super.key, required this.currentBook, this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final allBooks = bookProvider.books;
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

    final displaySimilar = similar.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.t('book.tabs.similar') ?? 'Ижил төстэй номууд',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${displaySimilar.length} / 10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (displaySimilar.isEmpty && bookProvider.isLoading)
          _buildLoadingState()
        else if (displaySimilar.isEmpty && bookProvider.errorMessage != null)
          ErrorStateView(
            errorMessage: bookProvider.errorMessage!,
            onRetry: bookProvider.retryInitialization,
          )
        else if (displaySimilar.isEmpty)
          EmptyStateView(
            icon: Icons.auto_stories_outlined,
            title: l10n?.t('book.similar_empty') ?? 'Ижил төстэй ном олдсонгүй',
            message: l10n?.locale.languageCode == 'en'
                ? 'There are no other books in the catalog yet.'
                : 'Сан дотор өөр ном алга байна.',
          )
        else
          SizedBox(
            height: 236,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: displaySimilar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final b = displaySimilar[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => BookDetailPage(book: b),
                      ),
                    );
                  },
                  child: Container(
                    width: 128,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.25,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              BookCoverImage(
                                image: b.image,
                                colorHex: b.colorHex,
                                title: b.title,
                                author: b.author,
                                width: 112,
                                height: 152,
                                borderRadius: 10,
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        b.rating > 0
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 11,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        b.rating > 0
                                            ? b.rating.toStringAsFixed(1)
                                            : '—',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.author,
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
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 236,
      child: Row(
        children: [
          Expanded(child: SkeletonLoader(width: double.infinity, height: 220)),
          SizedBox(width: 14),
          Expanded(child: SkeletonLoader(width: double.infinity, height: 220)),
        ],
      ),
    );
  }
}
