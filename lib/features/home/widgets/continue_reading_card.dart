import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/book_cover_image.dart';

class ContinueReadingCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onClose;
  final bool isFullWidth;

  const ContinueReadingCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onClose,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressPct = (book.progress * 100).toInt();
    final l10n = AppLocalizations.of(context);
    final continueText =
        l10n?.t('home.continue_reading') ?? 'Үргэлжлүүлэн унших';
    final pagesText = l10n?.t('book.pages') ?? 'хуудас';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.65)
            : colorScheme.surface,
        borderRadius: isFullWidth
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : BorderRadius.circular(16),
        border: isFullWidth
            ? Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              )
            : Border.all(
                color: colorScheme.primary.withValues(alpha: 0.25),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: isFullWidth
              ? const BorderRadius.vertical(top: Radius.circular(16))
              : BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(
              children: [
                // Compact Cover Image
                SizedBox(
                  width: 34,
                  height: 46,
                  child: BookCoverImage(
                    image: book.image,
                    colorHex: book.colorHex,
                    title: book.title,
                    author: book.author,
                    borderRadius: 6,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),

                // Book Title & Progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              continueText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$progressPct%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
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
                      const SizedBox(height: 1),
                      Text(
                        '${book.currentPage} / ${book.pages} $pagesText',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: book.progress.clamp(0.0, 1.0),
                          backgroundColor:
                              colorScheme.outlineVariant.withValues(alpha: 0.35),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                          minHeight: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Action Controls: Play & Close (X) Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                    if (onClose != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onClose,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
