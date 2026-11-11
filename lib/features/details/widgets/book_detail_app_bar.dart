import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/backbutton.dart';
import 'package:readpack/shared/widgets/book_cover_image.dart';

class BookDetailAppBar extends StatelessWidget {
  final Book currentBook;
  final BookProvider bookProvider;
  final AppLocalizations? l10n;

  const BookDetailAppBar({
    super.key,
    required this.currentBook,
    required this.bookProvider,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: colorScheme.surfaceContainerHigh,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: CustomBackButton(
            backgroundColor: colorScheme.primaryContainer,
            iconColor: colorScheme.onPrimaryContainer,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        IconButton.filledTonal(
          tooltip: l10n?.t('book.favorite') ?? 'Дуртай ном',
          onPressed: () => bookProvider.toggleFavoriteBook(currentBook.id),
          icon: Icon(
            currentBook.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
          ),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: currentBook.isFavorite
                ? colorScheme.error
                : colorScheme.onSecondaryContainer,
            backgroundColor: colorScheme.secondaryContainer,
          ),
        ),
        const SizedBox(width: 4),
        IconButton.filledTonal(
          tooltip: l10n?.t('book.save') ?? 'Ном хадгалах',
          onPressed: () {
            bookProvider.toggleSaveBook(currentBook.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  currentBook.isSaved
                      ? (l10n?.t('book.added_to_saved') ?? 'Ном хадгалагдлаа')
                      : (l10n?.t('book.removed_from_saved') ??
                            'Хадгалсан номнуудаас хасагдлаа'),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: Icon(
            currentBook.isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
          ),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: colorScheme.onSecondaryContainer,
            backgroundColor: colorScheme.secondaryContainer,
          ),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed =
              constraints.biggest.height <=
              kToolbarHeight + MediaQuery.of(context).padding.top + 28;
          return FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(
              left: 64,
              right: 112,
              bottom: 14,
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Text(
                currentBook.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.surfaceContainerHigh,
                        colorScheme.surfaceContainerHighest,
                        colorScheme.surface,
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Hero(
                      tag: 'book_cover_${currentBook.id}',
                      child: Container(
                        width: 148,
                        height: 222,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: BookCoverImage(
                          image: currentBook.image,
                          colorHex: currentBook.colorHex,
                          title: currentBook.title,
                          author: currentBook.author,
                          borderRadius: 16,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
