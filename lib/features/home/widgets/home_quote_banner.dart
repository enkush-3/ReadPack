import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/quotes/presentation/phone_widget_sheet.dart';
import 'package:readpack/features/shared/widgets/quote_share_modal.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class HomeQuoteBanner extends StatefulWidget {
  const HomeQuoteBanner({super.key});

  @override
  State<HomeQuoteBanner> createState() => _HomeQuoteBannerState();
}

class _HomeQuoteBannerState extends State<HomeQuoteBanner> {
  int _flashcardIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final l10n = AppLocalizations.of(context);
    final hasFlashcards = bookProvider.bookmarks.isNotEmpty;

    final String quoteTitle;
    final String displayQuote;
    final String quoteAuthor;
    final bool isFlashcardMode = _flashcardIndex >= 0 && hasFlashcards;

    if (isFlashcardMode) {
      final safeIdx = _flashcardIndex % bookProvider.bookmarks.length;
      final bm = bookProvider.bookmarks[safeIdx];
      quoteTitle =
          '${l10n?.t('flashcards.daily_card') ?? 'Өдрийн сануулга'} (${safeIdx + 1}/${bookProvider.bookmarks.length})';
      displayQuote = bm.quote;
      quoteAuthor = '${bm.bookTitle} • ${bm.chapterTitle}';
    } else {
      quoteTitle = l10n?.t('home.daily_quote_title') ?? 'Өдрийн эшлэл';
      displayQuote = l10n?.t('home.daily_quote') ??
          'Ном уншдаг хүн үхэхээсээ өмнө мянган амьдралаар амьдардаг.';
      quoteAuthor = l10n?.t('home.daily_quote_author') ?? 'Жорж Р.Р. Мартин';
    }

    final isAlreadySaved =
        bookProvider.bookmarks.any((b) => b.quote == displayQuote);

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
              isFlashcardMode ? Icons.style_rounded : Icons.format_quote_rounded,
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
                        quoteTitle,
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
                        if (hasFlashcards) ...[
                          AnimatedPressable(
                            onTap: () {
                              setState(() {
                                if (_flashcardIndex == -1) {
                                  _flashcardIndex = 0;
                                } else if (_flashcardIndex <
                                    bookProvider.bookmarks.length - 1) {
                                  _flashcardIndex++;
                                } else {
                                  _flashcardIndex = -1;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isFlashcardMode
                                    ? colorScheme.primary.withValues(alpha: 0.18)
                                    : colorScheme.primary
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.replay_rounded,
                                    size: 12,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    l10n?.t('flashcards.review_action') ??
                                        'Давтах',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        // Save Quote Button
                        AnimatedPressable(
                          onTap: () {
                            if (!isAlreadySaved) {
                              bookProvider.addBookmark(
                                Bookmark(
                                  id: 'daily_${DateTime.now().millisecondsSinceEpoch}',
                                  bookId: 'daily_quote_source',
                                  bookTitle: quoteTitle,
                                  chapterTitle: quoteAuthor,
                                  pageNumber: 1,
                                  quote: displayQuote,
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
                                        'Эшлэл амжилттай хадгалагдлаа! 📌',
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
                              quote: displayQuote,
                              author: quoteAuthor,
                              bookTitle: isFlashcardMode
                                  ? 'ReadPack Flashcard'
                                  : 'ReadPack Daily',
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
                  '"$displayQuote"',
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
                  '— $quoteAuthor',
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
