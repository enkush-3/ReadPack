import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/shared/widgets/quote_share_modal.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/bookmark.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class LibraryQuoteCard extends StatelessWidget {
  final Bookmark bm;
  final BookProvider provider;

  const LibraryQuoteCard({
    super.key,
    required this.bm,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      provider.toggleLikeBookmark(bm.id);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            !bm.isLiked
                                ? (l10n?.t('library.quote_liked') ??
                                    'Таалагдсан ишлэлд нэмэгдлээ ❤️')
                                : (l10n?.t('library.quote_unliked') ??
                                    'Таалагдсан ишлэлээс хасагдлаа'),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        bm.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: bm.isLiked
                            ? Colors.redAccent
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      provider.removeBookmark(bm.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n?.t('library.quote_deleted') ??
                                'Ишлэл устгагдлаа',
                          ),
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
                      const Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: Colors.white,
                      ),
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
                      content: Text(
                        l10n?.t('reader.quote_copied') ??
                            'Ишлэл амжилттай хуулагдлаа!',
                      ),
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
                      Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: colorScheme.primary,
                      ),
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
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: colorScheme.onPrimary,
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
  }
}
