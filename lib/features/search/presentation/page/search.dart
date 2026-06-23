import 'package:flutter/material.dart';
import 'package:readpack/features/search/model/model.dart';
import 'package:readpack/features/search/widgets/header.dart';
import 'package:readpack/features/search/widgets/searchresult.dart';
import 'package:readpack/features/shared/common/refresh.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/inputfield.dart';
 
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _StateSearchPage();
}

class _StateSearchPage extends State<SearchPage> {
  bool isRefresh = false;

  final _books = [
    {'title': 'Sapiens', 'author': 'Y. N. Harari', 'color': const Color(0xFF2C3E50), 'rating': 4.8, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': 'Mindset', 'author': 'C. Dweck', 'color': const Color(0xFFC0392B), 'rating': 4.5, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': 'The Power of Now', 'author': 'E. Tolle', 'color': const Color(0xFF27AE60), 'rating': 4.7, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': '1984', 'author': 'G. Orwell', 'color': const Color(0xFF34495E), 'rating': 4.9, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': 'Sapiens', 'author': 'Y. N. Harari', 'color': const Color(0xFF2C3E50), 'rating': 4.8, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': 'Mindset', 'author': 'C. Dweck', 'color': const Color(0xFFC0392B), 'rating': 4.5, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': 'The Power of Now', 'author': 'E. Tolle', 'color': const Color(0xFF27AE60), 'rating': 4.7, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': '1984', 'author': 'G. Orwell', 'color': const Color(0xFF34495E), 'rating': 4.9, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': 'Sapiens', 'author': 'Y. N. Harari', 'color': const Color(0xFF2C3E50), 'rating': 4.8, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': 'Mindset', 'author': 'C. Dweck', 'color': const Color(0xFFC0392B), 'rating': 4.5, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': 'The Power of Now', 'author': 'E. Tolle', 'color': const Color(0xFF27AE60), 'rating': 4.7, 'image': 'assets/public/books/clear_thinking.png'},
    {'title': '1984', 'author': 'G. Orwell', 'color': const Color(0xFF34495E), 'rating': 4.9, 'image': 'assets/public/books/clear_thinking.png'},
  ];

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _SearchContent(),
    );
  }

  Widget _SearchContent() {
    final l10n = AppLocalizations.of(context)!;
    const userName = 'Enkush';

    return RefreshWrapper(
      onRefresh: _onRefresh,

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 10),
            child: SearchHeader(userName: userName),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: InputField(
                    hint: l10n.t('hint.search'),
                    icon: Icons.search_rounded,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SearchResult(
              books: _books.map((book) => Book(
                title: book['title'] as String,
                author: book['author'] as String,
                rating: book['rating'] as double,
                image: book['image'] as String,
              )).toList(),
            ),
          )
        ],
      )
    );
  }

}