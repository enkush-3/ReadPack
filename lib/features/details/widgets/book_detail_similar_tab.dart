import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/details/presentation/page/book_detail.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';

class BookDetailSimilarTab extends StatelessWidget {
  final Book currentBook;
  final AppLocalizations? l10n;

  const BookDetailSimilarTab({
    super.key,
    required this.currentBook,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allBooks = context.watch<BookProvider>().books;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          l10n?.t('book.tabs.similar') ?? 'Ижил төстэй номууд',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        ...similar.map((b) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => BookDetailPage(book: b),
                    ),
                  );
                },
                leading: Container(
                  width: 44,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(b.colorHex),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      b.title.isNotEmpty ? b.title[0] : '',
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  b.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${b.author} • ⭐ ${b.rating}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
