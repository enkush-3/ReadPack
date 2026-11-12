import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/details/widgets/book_detail_review_form.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';

class BookDetailReviewsTab extends StatelessWidget {
  final Book currentBook;
  final AppLocalizations? l10n;

  const BookDetailReviewsTab({super.key, required this.currentBook, this.l10n});

  Widget _buildRatingBreakdown(
    Book book,
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
    final ratingValue = book.rating > 0 ? book.rating.toStringAsFixed(1) : '—';
    final ratingCount = book.reviewsCount > 0
        ? '${book.reviewsCount} ${l10n?.t('reviews.ratings_count') ?? 'үнэлгээ'}'
        : (l10n?.locale.languageCode == 'en'
              ? 'No rating data'
              : 'Үнэлгээний мэдээлэл алга');

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
                ratingValue,
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
                    book.rating <= 0
                        ? Icons.star_outline_rounded
                        : index < book.rating.floor()
                        ? Icons.star_rounded
                        : index < book.rating
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                ratingCount,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.t('reviews.rating_summary') ??
                      (l10n?.locale.languageCode == 'en'
                          ? 'Catalog rating'
                          : 'Сангийн үнэлгээ'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.t('reviews.rating_distribution_unavailable') ??
                      (l10n?.locale.languageCode == 'en'
                          ? 'Rating distribution is not provided.'
                          : 'Үнэлгээний задаргаа мэдээлэлгүй байна.'),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentL10n = l10n ?? AppLocalizations.of(context);
    final reviewsTitle =
        currentL10n?.t('reviews.title') ?? 'Үнэлгээ & Сэтгэгдэл';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _buildRatingBreakdown(currentBook, colorScheme, currentL10n),
        const SizedBox(height: 20),
        BookDetailReviewForm(currentBook: currentBook, l10n: currentL10n),
        const SizedBox(height: 20),
        if (currentBook.reviews.isEmpty)
          EmptyStateView(
            icon: Icons.rate_review_outlined,
            title:
                currentL10n?.t('reviews.empty') ??
                'Анхны сэтгэгдлийг та бичээрэй!',
            message: currentL10n?.locale.languageCode == 'en'
                ? 'There are no submitted reviews for this book.'
                : 'Энэ номд одоогоор сэтгэгдэл ирээгүй байна.',
          )
        else
          ...currentBook.reviews.map((rev) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
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
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Colors.amber,
                          ),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedPressable(
                        onTap: () {
                          context.read<BookProvider>().toggleReviewHelpful(
                            currentBook.id,
                            rev.id,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: rev.isHelpful
                                ? colorScheme.primary.withValues(alpha: 0.12)
                                : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: rev.isHelpful
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant.withValues(
                                      alpha: 0.3,
                                    ),
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
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rev.helpfulCount > 0
                                    ? '${rev.helpfulCount} ${currentL10n?.t('book.helpful') ?? 'тустай'}'
                                    : (currentL10n?.t('book.helpful_btn') ??
                                          'Тустай 👍'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: rev.isHelpful
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
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
    );
  }
}
