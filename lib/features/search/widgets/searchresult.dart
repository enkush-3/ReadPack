import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/home/widgets/books_card.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';

class SearchResult extends StatelessWidget {
  final List<Book> books;
  final VoidCallback? onResetFilter;

  const SearchResult({
    super.key,
    required this.books,
    this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bookProvider = context.watch<BookProvider>();
    final query = bookProvider.searchQuery.trim();

    if (books.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        title: l10n?.t('book.no_results') ?? 'Хайлтад тохирох ном олдсонгүй',
        message: l10n?.t('book.no_results_desc') ??
            'Нэр, зохиолч эсвэл түлхүүр үгээ өөрчилж хайна уу.',
        actionLabel: onResetFilter != null
            ? (l10n?.t('filter.clear') ?? 'Шүүлтүүр цэвэрлэх')
            : null,
        onAction: onResetFilter,
      );
    }

    final hasAnyChapterMatches = query.isNotEmpty &&
        books.any((b) =>
            bookProvider.getChapterMatchesForBook(b.id, query).isNotEmpty);

    if (hasAnyChapterMatches) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final chapterMatches =
              bookProvider.getChapterMatchesForBook(book.id, query);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        Routes.bookDetail,
                        arguments: book,
                      );
                    },
                    leading: Container(
                      width: 44,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Color(book.colorHex),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          book.title.isNotEmpty ? book.title[0] : '',
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
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          book.author,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 15, color: Colors.amber),
                            const SizedBox(width: 3),
                            Text(
                              book.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${book.pages} ${l10n?.t('book.pages') ?? 'хуудас'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ),
                ),
                if (chapterMatches.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.find_in_page_rounded,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${l10n?.t('search.found_in_chapter') ?? 'Бүлгээс олдсон:'} ${chapterMatches.first['chapterTitle']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chapterMatches.first['snippet'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Routes.reader,
                                arguments: {
                                  'book': book,
                                  'initialChapterIndex':
                                      chapterMatches.first['chapterIndex'],
                                },
                              );
                            },
                            child: Text(
                              l10n?.t('search.read_chapter_direct') ??
                                  'Энэ бүлгээс шууд унших →',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          title: book.title,
          author: book.author,
          rating: book.rating,
          image: book.image,
          onTap: () {
            Navigator.of(context).pushNamed(
              Routes.bookDetail,
              arguments: book,
            );
          },
        );
      },
    );
  }
}