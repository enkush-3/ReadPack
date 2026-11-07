import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/book_cover_image.dart';

class LibraryReadingCard extends StatelessWidget {
  final Book book;
  final BookProvider provider;

  const LibraryReadingCard({
    super.key,
    required this.book,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            child: SizedBox(
              width: 68,
              height: 96,
              child: BookCoverImage(
                image: book.image,
                colorHex: book.colorHex,
                title: book.title,
                author: book.author,
                borderRadius: 12,
                fit: BoxFit.cover,
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
                      l10n?.t('library.read_percent',
                              {'percent': '$progressPct'}) ??
                          '$progressPct% уншсан',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        provider.toggleDownloadBook(book.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.isBookDownloaded(book.id)
                                  ? (l10n?.t('library.downloaded_success', {
                                        'size':
                                            '${provider.getDownloadedSizeMb(book.id)}'
                                      }) ??
                                      'Ном оффлайн уншихаар татагдлаа (${provider.getDownloadedSizeMb(book.id)} MB)')
                                  : (l10n?.t('library.removed_download') ??
                                      'Ном оффлайн сангаас хасагдлаа'),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
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
}
