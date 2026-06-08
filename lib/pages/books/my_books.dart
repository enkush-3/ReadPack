import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/books/book_list.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/navigation/page_header.dart';
import 'book_details.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  String _filter = 'all';
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> _savedBooks = [
    {'title': 'Atomic Habits', 'author': 'James Clear', 'color': const Color(0xFFE67E22), 'rating': 4.8, 'status': 'reading'},
    {'title': 'Deep Work', 'author': 'Cal Newport', 'color': const Color(0xFF16A085), 'rating': 4.6, 'status': 'completed'},
    {'title': 'The Alchemist', 'author': 'Paulo Coelho', 'color': const Color(0xFF8E44AD), 'rating': 4.7, 'status': 'reading'},
    {'title': 'Sapiens', 'author': 'Y. N. Harari', 'color': const Color(0xFF2C3E50), 'rating': 4.9, 'status': 'completed'},
    {'title': 'Mindset', 'author': 'C. Dweck', 'color': const Color(0xFFC0392B), 'rating': 4.5, 'status': 'reading'},
  ];

  List<Map<String, dynamic>> get _filteredBooks {
    if (_filter == 'all') return _savedBooks;
    return _savedBooks.where((b) => b['status'] == _filter).toList();
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
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
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshWrapper(
      onRefresh: _onRefresh,
      child: SafeArea(
        child: Column(
          children: [
            const PageHeader(
              title: 'Хадгалсан',
              subtitle: 'Таны номын сан',
            ),
            _buildFilterChips(colorScheme),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredBooks.isEmpty
                  ? _EmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'Хадгалсан ном байхгүй',
                description: 'Та одоогоор ямар ч ном хадгалаагүй байна.',
              )
                  : _buildBooksList(colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    final filters = [
      {'key': 'all', 'label': 'Бүгд', 'count': _savedBooks.length},
      {'key': 'reading', 'label': 'Уншиж буй', 'count': _savedBooks.where((b) => b['status'] == 'reading').length},
      {'key': 'completed', 'label': 'Дууссан', 'count': _savedBooks.where((b) => b['status'] == 'completed').length},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _filter == filter['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filter = filter['key'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${filter['count']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? colorScheme.onPrimary.withValues(alpha: 0.8)
                            : colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBooksList(ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredBooks.length,
      itemBuilder: (context, index) {
        final book = _filteredBooks[index];
        return Stack(
          children: [
            BookCard(
              title: book['title'],
              author: book['author'],
              color: book['color'],
              rating: book['rating'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsPage(book: book),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_rounded,
                  color: colorScheme.primary,
                  size: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}