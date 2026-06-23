import 'package:flutter/material.dart';
import 'package:readpack/features/home/widgets/books_card.dart';
import 'package:readpack/features/home/widgets/categories.dart';
import 'package:readpack/features/home/widgets/features_book.dart';
import 'package:readpack/features/home/widgets/header.dart';
import 'package:readpack/features/shared/common/refresh.dart';
import 'package:readpack/helper/translation.dart';

class HomePage extends StatefulWidget{
  const HomePage({
    super.key
  });

  @override
  State<HomePage> createState() => _StateHomePage();
}

class _StateHomePage extends State<HomePage> {
  bool isRefresh = false;

  final List<Map<String, dynamic>> _featuredBooks = [
    {'title': 'The Great\nGatsby', 'author': 'F. Scott Fitzgerald', 'color': const Color(0xFF425CAC).withValues(alpha: 0.5), 'image': 'assets/public/books/clear_thinking.png'},
    {'title': 'Atomic\nHabits', 'author': 'James Clear', 'color': const Color(0xFFE67E22), 'image': '🎯'},
    {'title': 'Deep\nWork', 'author': 'Cal Newport', 'color': const Color(0xFF16A085), 'image': '💡'},
    {'title': 'The\nAlchemist', 'author': 'Paulo Coelho', 'color': const Color(0xFF8E44AD), 'image': '✨'},
  ];

  final List<Map<String, dynamic>> _books = [
    {'title': 'Sapiens', 'author': 'Y. N. Harari', 'color': const Color(0xFF2C3E50), 'rating': 4.8, 'image': 'assets/public/books/sapiens.png'},
    {'title': 'Mindset', 'author': 'C. Dweck', 'color': const Color(0xFFC0392B), 'rating': 4.5, 'image': 'assets/public/books/sapiens.png'},
    {'title': 'The Power\nof Now', 'author': 'E. Tolle', 'color': const Color(0xFF27AE60), 'rating': 4.7, 'image': 'assets/public/books/sapiens.png'},
    {'title': '1984', 'author': 'G. Orwell', 'color': const Color(0xFF34495E), 'rating': 4.9, 'image': 'assets/public/books/1984.png'},
    {'title': 'Atomic\nHabits', 'author': 'James Clear', 'color': const Color(0xFFE67E22), 'rating': 4.6, 'image': 'assets/public/books/sapiens.png'},
    {'title': 'Deep Work', 'author': 'Cal Newport', 'color': const Color(0xFF16A085), 'rating': 4.4, 'image': 'assets/public/books/sapiens.png'},
    {'title': 'Thinking,\nFast & Slow', 'author': 'D. Kahneman', 'color': const Color(0xFF8E44AD), 'rating': 4.7, 'image': 'assets/public/books/sapiens.png'},
    {'title': 'The\nAlchemist', 'author': 'P. Coelho', 'color': const Color(0xFFD35400), 'rating': 4.8, 'image': 'assets/public/books/sapiens.png'},
    {'title': 'Educated', 'author': 'T. Westover', 'color': const Color(0xFF2980B9), 'rating': 4.5, 'image': 'assets/public/books/sapiens.png'},
    {'title': 'Becoming', 'author': 'M. Obama', 'color': const Color(0xFF1ABC9C), 'rating': 4.6, 'image': 'assets/public/books/sapiens.png'},
    {'title': 'Outliers', 'author': 'M. Gladwell', 'color': const Color(0xFFE74C3C), 'rating': 4.3, 'image': 'assets/public/books/sapiens.png'},
    {'title': 'The Lean\nStartup', 'author': 'E. Ries', 'color': const Color(0xFF3498DB), 'rating': 4.4, 'image': 'assets/public/books/sapiens.png'},
  ];

  final List<String> _categoryKeys = [
    'book.categories.all',
    'book.categories.romance',
    'book.categories.history',
    'book.categories.science',
    'book.categories.business',
    'book.categories.adventure',
  ];
    int _selectedCategory = 0;

  List<String> get _categories {
    final l10n = AppLocalizations.of(context)!;
    return _categoryKeys.map((key) => l10n.t(key)).toList();
  }

  Future<void> _onRefresh() async {
    setState(() => isRefresh = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Өгөгдөл шинэчлэгдлээ'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Алдаа: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isRefresh = false);
      }
    }
  }

  void _onCategoryChanged(int index) {
    setState(() => _selectedCategory = index);
    debugPrint('Сонгогдсон категори: ${_categories[index]}');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      
      body: _HomeContent(),
    );
  }

  Widget _HomeContent() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    const userName = 'Enkush';
    
    return RefreshWrapper(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 10), // Дээд padding нэмэгдүүлсэн (status bar-аас зай)
              child: HomeHeader(userName: userName),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Text(
                    l10n.t('book.feature'),
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _featuredBooks.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final book = _featuredBooks[index];
                      return FeaturedBookCard(
                        title: book['title']!,
                        author: book['author']!,
                        color: book['color']!,
                        image: book['image']!,
                      );
                    },
                  ),
                ),
              ],
            )
          ),

          SliverToBoxAdapter(
            child: Categories(
              categories: _categories, 
              selectedIndex: _selectedCategory, 
              onChanged: _onCategoryChanged
            )
          ),


          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    l10n.t(_categoryKeys[_selectedCategory]),
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _books.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 140,
                            child: BookCard(
                              title: _books[index]['title']!,
                              author: _books[index]['author']!,
                              rating: _books[index]['rating']!,
                              image: _books[index]['image']!,
                              // onTap: () => _openBook(_books[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}