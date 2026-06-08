import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/common/filter_shell.dart';
import '../../widgets/navigation/page_header.dart';
import '../books/book_details.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = [
    'Atomic Habits',
    'F. Scott Fitzgerald',
    'Бизнесийн номууд',
    'Psychology',
  ];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          PageHeader(
            title: 'Хайх',
            subtitle: 'Дуртай номоо олоорой',
            actions: [
              IconButton(
                icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  shape: const CircleBorder(),
                ),
                onPressed: () async {
                  final result = await FilterBottomSheet.show(
                    context,
                    FilterData.defaults(),
                  );
                  if (result != null) {
                    debugPrint('Filter applied: ${result.categories}, rating: ${result.minRating}');
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSearchBar(colorScheme),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecentSearches(colorScheme),
                  const SizedBox(height: 32),
                  _buildPopularBooks(colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Ном, зохиолч хайх...',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 14,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 24,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
    );
  }

  Widget _buildRecentSearches(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Сая хайсан',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _recentSearches.clear()),
                child: Text(
                  'Цэвэрлэх',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentSearches.isEmpty)
            Text(
              'Сая хайлт байхгүй байна',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          search,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPopularBooks(ColorScheme colorScheme) {
    final popularBooks = [
      {'title': 'Sapiens', 'author': 'Y. N. Harari', 'color': const Color(0xFF2C3E50), 'rating': 4.8},
      {'title': 'Mindset', 'author': 'C. Dweck', 'color': const Color(0xFFC0392B), 'rating': 4.5},
      {'title': 'The Power of Now', 'author': 'E. Tolle', 'color': const Color(0xFF27AE60), 'rating': 4.7},
      {'title': '1984', 'author': 'G. Orwell', 'color': const Color(0xFF34495E), 'rating': 4.9},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Эрэлттэй номууд',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: popularBooks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final book = popularBooks[index];
              return _PopularBookItem(book: book);
            },
          ),
        ],
      ),
    );
  }
}

class _PopularBookItem extends StatelessWidget {
  final Map<String, dynamic> book;

  const _PopularBookItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final title = book['title'] as String;
    final author = book['author'] as String;
    final color = book['color'] as Color;
    final rating = book['rating'] as double;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsPage(book: book),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('📖', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded, color: colorScheme.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}