import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/quotes/presentation/phone_widget_sheet.dart';
import 'package:readpack/features/shared/widgets/quote_share_modal.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class HomeQuoteBanner extends StatelessWidget {
  const HomeQuoteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);
    final dailyQuoteTitle =
        l10n?.t('home.daily_quote_title') ?? 'Өдрийн эшлэл';
    final dailyQuote = l10n?.t('home.daily_quote') ??
        'Ном уншдаг хүн үхэхээсээ өмнө мянган амьдралаар амьдардаг.';
    final dailyQuoteAuthor =
        l10n?.t('home.daily_quote_author') ?? 'Жорж Р.Р. Мартин';

    final isAlreadySaved =
        bookProvider.bookmarks.any((b) => b.quote == dailyQuote);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.6),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        dailyQuoteTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Save Quote Button
                        AnimatedPressable(
                          onTap: () {
                            if (!isAlreadySaved) {
                              bookProvider.addBookmark(
                                Bookmark(
                                  id: 'daily_${DateTime.now().millisecondsSinceEpoch}',
                                  bookId: 'daily_quote_source',
                                  bookTitle: 'Өдрийн эшлэл',
                                  chapterTitle: dailyQuoteAuthor,
                                  pageNumber: 1,
                                  quote: dailyQuote,
                                  note: 'Өдрийн онцлох эшлэл',
                                  createdAt: DateTime.now(),
                                  colorHex: 0xFFFFD54F,
                                  isLiked: true,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n?.t('home.quote_saved_success') ??
                                        'Өдрийн эшлэл амжилттай хадгалагдлаа! 📌',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n?.t('home.quote_already_saved') ??
                                        'Энэ эшлэл таны санд хадгалагдсан байна ❤️',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isAlreadySaved
                                  ? colorScheme.primary
                                  : colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAlreadySaved
                                      ? Icons.bookmark_added_rounded
                                      : Icons.bookmark_add_outlined,
                                  size: 13,
                                  color: isAlreadySaved
                                      ? colorScheme.onPrimary
                                      : colorScheme.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isAlreadySaved
                                      ? (l10n?.t('home.saved_quote') ?? 'Хадгалсан')
                                      : (l10n?.t('home.save_quote') ?? 'Хадгалах'),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: isAlreadySaved
                                        ? colorScheme.onPrimary
                                        : colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Phone Widget Button
                        AnimatedPressable(
                          onTap: () => PhoneWidgetSheet.show(context),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.widgets_rounded,
                              size: 13,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Share Button
                        AnimatedPressable(
                          onTap: () {
                            QuoteShareModal.show(
                              context,
                              quote: dailyQuote,
                              author: dailyQuoteAuthor,
                              bookTitle: 'ReadPack Daily',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.share_rounded,
                              size: 13,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
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
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '— $dailyQuoteAuthor',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
