import 'package:flutter/material.dart';
import 'package:readpack/features/home/widgets/books_card.dart';
import 'package:readpack/features/search/model/model.dart';
import 'package:readpack/features/search/widgets/searchhistory.dart';

class SearchResult extends StatefulWidget {
  final List<Book> books;

  const SearchResult({
    super.key,
    required this.books,
  });

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;


    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface
        ),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: SearchHistory(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.6,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = widget.books[index];
                    return BookCard(
                      title: book.title,          
                      author: book.author,        
                      rating: book.rating,        
                      image: book.image,          
                      onTap: () {},
                    );
                  },
                  childCount: widget.books.length,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}