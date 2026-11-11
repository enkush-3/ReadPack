import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/book_cover_image.dart';

class ContinueReadingCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onClose;

  const ContinueReadingCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final progress = book.progress.clamp(0.0, 1.0);
    final continueLabel =
        l10n?.t('home.continue_reading') ?? 'Үргэлжлүүлэн унших';
    final pagesLabel = l10n?.t('book.pages') ?? 'хуудас';
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.45),
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: cardShape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 64,
                child: BookCoverImage(
                  image: book.image,
                  colorHex: book.colorHex,
                  title: book.title,
                  author: book.author,
                  fit: BoxFit.cover,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            continueLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${book.currentPage} / ${book.pages} $pagesLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: continueLabel,
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow_rounded),
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: colorScheme.onPrimaryContainer,
                  backgroundColor: colorScheme.primaryContainer,
                ),
              ),
              if (onClose != null)
                IconButton(
                  tooltip: l10n?.t('common.close') ?? 'Хаах',
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
