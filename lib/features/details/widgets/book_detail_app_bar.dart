import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/backbutton.dart';

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

  Widget _buildPlaceholderCover(Book book) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(book.colorHex),
            Color(book.colorHex).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, color: Colors.white, size: 36),
            const SizedBox(height: 12),
            Text(
              book.title,
              textAlign: TextAlign.center,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: Color(currentBook.colorHex),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: CustomBackButton(
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            iconColor: Color(currentBook.colorHex),
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: AnimatedPressable(
            onTap: () {
              bookProvider.toggleFavoriteBook(currentBook.id);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentBook.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: currentBook.isFavorite
                    ? Colors.redAccent
                    : Color(currentBook.colorHex),
                size: 22,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AnimatedPressable(
            onTap: () {
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
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentBook.isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: currentBook.isSaved
                    ? colorScheme.primary
                    : Color(currentBook.colorHex),
                size: 22,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(currentBook.colorHex),
                    Color(currentBook.colorHex).withValues(alpha: 0.8),
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
                    width: 150,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: currentBook.image != null
                          ? Image.asset(
                              currentBook.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholderCover(currentBook),
                            )
                          : _buildPlaceholderCover(currentBook),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
