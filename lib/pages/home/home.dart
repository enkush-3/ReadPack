import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readpact/pages/home/notification.dart';
import '../../widgets/books/book_card.dart';
import '../../widgets/books/book_list.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/common/swipeable.dart';
import '../../widgets/navigation/bottom_nav.dart';
import '../../widgets/navigation/page_header.dart';
import '../books/book_details.dart';
import '../profile/profile.dart';
import '../search/search.dart';
import '../books/my_books.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final String userName = 'Enkush';
  bool _isRefreshing = false;

  final PageController _pageController = PageController();

  final List<String> _categories = [
    'Бүгд', 'Роман', 'Түүх', 'Шинжлэх ухаан', 'Бизнес', 'Адал явдал',
  ];
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SwipeablePages(
          pageController: _pageController,
          initialPage: _selectedIndex,
          onPageChanged: _onPageChanged,
          pages: [
            _buildHomeContent(),
            const SearchPage(),
            const SavedPage(),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshWrapper(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PageHeader(userName: userName, actions: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_none_rounded, color: colorScheme.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],)
          ),
          SliverToBoxAdapter(
            child: _SectionTitle(title: 'Онцлох номууд'),
          ),
          SliverToBoxAdapter(child: _buildFeaturedBooks(colorScheme)),

          SliverToBoxAdapter(child: _buildCategories(colorScheme)),
          SliverToBoxAdapter(
            child: _SectionTitle(title: _categories[_selectedCategory], onSeeAll: () {}),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _recentBooks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 140,
                      child: BookCard(
                        title: _recentBooks[index]['title']!,
                        author: _recentBooks[index]['author']!,
                        color: _recentBooks[index]['color']!,
                        rating: _recentBooks[index]['rating']!,
                        onTap: () => _openBook(_recentBooks[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionTitle(title: 'Санал болгох ном', onSeeAll: () {}),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _recentBooks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 140,
                      child: BookCard(
                        title: _recentBooks[index]['title']!,
                        author: _recentBooks[index]['author']!,
                        color: _recentBooks[index]['color']!,
                        rating: _recentBooks[index]['rating']!,
                        onTap: () => _openBook(_recentBooks[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  void _openBook(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book),
      ),
    );
  }

  Widget _buildCategories(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox.shrink(),
          ),
          itemBuilder: (context, index) {
            final isSelected = _selectedCategory == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedBooks(ColorScheme colorScheme) {
    return SizedBox(
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
            onTap: () => _openBook(book),
          );
        },
      ),
    );
  }

  final List<Map<String, dynamic>> _featuredBooks = [
    {'title': 'The Great\nGatsby', 'author': 'F. Scott Fitzgerald', 'color': const Color(0xFF425CAC), 'image': '📚'},
    {'title': 'Atomic\nHabits', 'author': 'James Clear', 'color': const Color(0xFFE67E22), 'image': '🎯'},
    {'title': 'Deep\nWork', 'author': 'Cal Newport', 'color': const Color(0xFF16A085), 'image': '💡'},
    {'title': 'The\nAlchemist', 'author': 'Paulo Coelho', 'color': const Color(0xFF8E44AD), 'image': '✨'},
  ];

  final List<Map<String, dynamic>> _recentBooks = [
    {'title': 'Sapiens', 'author': 'Y. N. Harari', 'color': const Color(0xFF2C3E50), 'rating': 4.8},
    {'title': 'Mindset', 'author': 'C. Dweck', 'color': const Color(0xFFC0392B), 'rating': 4.5},
    {'title': 'The Power\nof Now', 'author': 'E. Tolle', 'color': const Color(0xFF27AE60), 'rating': 4.7},
    {'title': '1984', 'author': 'G. Orwell', 'color': const Color(0xFF34495E), 'rating': 4.9},
  ];
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionTitle({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Бүгдийг харах',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}