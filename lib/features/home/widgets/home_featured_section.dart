import 'package:flutter/material.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/home/widgets/features_book.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/book.dart';

class HomeFeaturedSection extends StatelessWidget {
  final List<Book> featuredBooks;

  const HomeFeaturedSection({
    super.key,
    required this.featuredBooks,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final featuredTitle = l10n?.t('book.feature') ?? 'Онцлох номнууд';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            featuredTitle,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 290,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: featuredBooks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final book = featuredBooks[index];
              return FeaturedBookCard(
                book: book,
                title: book.title,
                author: book.author,
                color: Color(book.colorHex),
                image: book.image ?? '',
                category: l10n?.t(book.category) ?? 'Онцлох',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.bookDetail,
                    arguments: book,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
