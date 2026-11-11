import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/quotes/presentation/phone_widget_sheet.dart';
import 'package:readpack/features/shared/widgets/quote_share_modal.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/bookmark.dart';

class LibraryQuoteCard extends StatelessWidget {
  final Bookmark bm;
  final BookProvider provider;

  const LibraryQuoteCard({super.key, required this.bm, required this.provider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final accentColor = Color(bm.colorHex == 0 ? 0xFFFFD54F : bm.colorHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.format_quote_rounded,
                                  size: 16,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${bm.bookTitle} • ${bm.chapterTitle}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: bm.isLiked
                                    ? (l10n?.t('library.quote_unliked') ??
                                          'Remove from liked quotes')
                                    : (l10n?.t('library.quote_liked') ??
                                          'Like quote'),
                                onPressed: () {
                                  provider.toggleLikeBookmark(bm.id);
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        !bm.isLiked
                                            ? (l10n?.t('library.quote_liked') ??
                                                  'Таалагдсан ишлэлд нэмэгдлээ ❤️')
                                            : (l10n?.t(
                                                    'library.quote_unliked',
                                                  ) ??
                                                  'Таалагдсан ишлэлээс хасагдлаа'),
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  bm.isLiked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                ),
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                  foregroundColor: bm.isLiked
                                      ? colorScheme.error
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              IconButton(
                                tooltip: l10n?.t('common.delete') ?? 'Устгах',
                                onPressed: () {
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
                                icon: const Icon(Icons.delete_outline_rounded),
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                  foregroundColor: colorScheme.onSurfaceVariant,
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
                          fontSize: 14.5,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                      if (bm.note.isNotEmpty &&
                          bm.note != 'Хувийн тэмдэглэл (заавал биш)') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                size: 13,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  bm.note,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          // Story Card Share Button
                          FilledButton.tonalIcon(
                            onPressed: () {
                              final matchingBook = provider.books
                                  .where((b) => b.id == bm.bookId)
                                  .firstOrNull;
                              QuoteShareModal.show(
                                context,
                                quote: bm.quote,
                                bookTitle: bm.bookTitle,
                                author: matchingBook?.author ?? bm.chapterTitle,
                              );
                            },
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: Text(
                              l10n?.t('library.share_story_btn') ??
                                  'Story карт',
                              maxLines: 1,
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              foregroundColor: colorScheme.onSecondaryContainer,
                              backgroundColor: colorScheme.secondaryContainer,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: l10n?.t('widget.title') ?? 'Утасны виджет',
                            onPressed: () {
                              PhoneWidgetSheet.show(
                                context,
                                initialBookmark: bm,
                              );
                            },
                            icon: const Icon(Icons.widgets_rounded),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              foregroundColor: colorScheme.onSecondaryContainer,
                              backgroundColor: colorScheme.secondaryContainer,
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: l10n?.t('library.copy') ?? 'Хуулах',
                            onPressed: () {
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
                            icon: const Icon(Icons.copy_rounded),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              foregroundColor: colorScheme.onSecondaryContainer,
                              backgroundColor: colorScheme.secondaryContainer,
                            ),
                          ),
                          if (bm.bookId != 'daily_quote_source' &&
                              provider.books.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                final book = provider.books.firstWhere(
                                  (b) => b.id == bm.bookId,
                                  orElse: () => provider.books.first,
                                );
                                Navigator.of(
                                  context,
                                ).pushNamed(Routes.bookDetail, arguments: book);
                              },
                              icon: const Icon(Icons.menu_book_rounded),
                              label: Text(
                                l10n?.t('library.view_book') ?? 'Ном үзэх',
                                maxLines: 1,
                              ),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                foregroundColor: colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
