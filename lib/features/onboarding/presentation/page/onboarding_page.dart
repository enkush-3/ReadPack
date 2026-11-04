import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Selected onboarding state indices
  int _selectedGoalIndex = 0;
  final Set<int> _selectedGenreIndices = {0, 1, 2};
  int _selectedDailyMinutes = 30;
  int _selectedYearlyBooks = 24;

  static const List<Map<String, String>> _mnGoals = [
    {
      'title': 'Хувь хүний хөгжил',
      'desc': 'Сахилга бат, бүтээмж, шинэ дадал зуршил суулгах',
      'icon': '🚀',
    },
    {
      'title': 'Карьер & Бизнес',
      'desc': 'Мэргэжлийн ур чадвар, манлайлал ба стартап менежмент',
      'icon': '💼',
    },
    {
      'title': 'Сэтгэл зүй & Төвлөрөл',
      'desc': 'Стрессээс ангижрах, дотоод тайвшрал ба эерэг хандлага',
      'icon': '🧠',
    },
    {
      'title': 'Санхүүгийн эрх чөлөө',
      'desc': 'Хөрөнгө оруулалт, мөнгөний сэтгэлгээ ба санхүүгийн сахилга',
      'icon': '💰',
    },
    {
      'title': 'Ертөнцийг танин мэдэх',
      'desc': 'Дэлхийн түүх, гүн ухаан, шинжлэх ухаан ба сонгодог зохиол',
      'icon': '🌍',
    },
  ];

  static const List<Map<String, String>> _enGoals = [
    {
      'title': 'Personal Growth',
      'desc': 'Discipline, productivity & building lifelong habits',
      'icon': '🚀',
    },
    {
      'title': 'Career & Business',
      'desc': 'Professional skills, leadership & startup management',
      'icon': '💼',
    },
    {
      'title': 'Psychology & Focus',
      'desc': 'Relieve stress, cultivate calm and mental clarity',
      'icon': '🧠',
    },
    {
      'title': 'Financial Freedom',
      'desc': 'Investing, wealth mindset & financial discipline',
      'icon': '💰',
    },
    {
      'title': 'Exploring the World',
      'desc': 'World history, philosophy, science & classics',
      'icon': '🌍',
    },
  ];

  static const List<String> _mnGenres = [
    'Бизнес',
    'Хувь хүний хөгжил',
    'Сэтгэл зүй',
    'Түүх',
    'Уран зөгнөлт',
    'Шинжлэх ухаан',
    'Сонгодог зохиол',
    'Гүн ухаан',
    'Эрүүл мэнд',
    'Манлайлал',
    'Роман',
    'Адал явдал',
  ];

  static const List<String> _enGenres = [
    'Business',
    'Personal Growth',
    'Psychology',
    'History',
    'Sci-Fi',
    'Science',
    'Classics',
    'Philosophy',
    'Health',
    'Leadership',
    'Romance',
    'Adventure',
  ];

  List<Map<String, String>> _goals(bool isEn) => isEn ? _enGoals : _mnGoals;
  List<String> _genres(bool isEn) => isEn ? _enGenres : _mnGenres;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finishOnboarding([bool isEn = false]) {
    final bookProvider = context.read<BookProvider>();
    final currentGenres = _genres(isEn);
    bookProvider.completeOnboarding(
      favoriteGenres: _selectedGenreIndices.map((i) => currentGenres[i]).toList(),
      dailyGoalMinutes: _selectedDailyMinutes,
      yearlyGoalBooks: _selectedYearlyBooks,
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.appshell);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isEn = l10n?.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0 && _currentPage < 3)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: _prevPage,
                      color: colorScheme.onSurface,
                    )
                  else
                    const SizedBox(width: 40),
                  // Progress indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.outlineVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: () => _finishOnboarding(isEn),
                      child: Text(
                        l10n?.t('onboarding.skip') ?? 'Алгасах',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // PageView Steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStep1Goal(colorScheme, l10n, isEn),
                  _buildStep2Genres(colorScheme, l10n, isEn),
                  _buildStep3Targets(colorScheme, l10n, isEn),
                  _buildStep4Celebration(colorScheme, l10n, isEn),
                ],
              ),
            ),

            // Bottom Continue Bar (Steps 0, 1, 2)
            if (_currentPage < 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n?.t('onboarding.next') ?? 'Үргэлжлүүлэх',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Reading Goal
  Widget _buildStep1Goal(ColorScheme colorScheme, AppLocalizations? l10n, bool isEn) {
    final goals = _goals(isEn);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${l10n?.t('onboarding.step') ?? 'Алхам'} 1/3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.t('onboarding.step1_title') ?? 'Таны унших гол зорилго юу вэ?',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.t('onboarding.step1_desc') ??
                'Танд тохирсон шилдэг номуудыг санал болгоход тусална.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 24),
          ...goals.asMap().entries.map((entry) {
            final index = entry.key;
            final goal = entry.value;
            final isSelected = _selectedGoalIndex == index;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AnimatedPressable(
                onTap: () {
                  setState(() => _selectedGoalIndex = index);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.08)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            goal['icon']!,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal['desc']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 2: Favorite Genres
  Widget _buildStep2Genres(ColorScheme colorScheme, AppLocalizations? l10n, bool isEn) {
    final genres = _genres(isEn);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${l10n?.t('onboarding.step') ?? 'Алхам'} 2/3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.t('onboarding.step2_title') ?? 'Дуртай номын төрлүүдээ сонгоно уу',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.t('onboarding.step2_desc') ??
                'Нэг болон түүнээс дээш төрлийг сонгоорой.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: genres.asMap().entries.map((entry) {
              final index = entry.key;
              final genre = entry.value;
              final isSelected = _selectedGenreIndices.contains(index);
              return AnimatedPressable(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_selectedGenreIndices.length > 1) {
                        _selectedGenreIndices.remove(index);
                      }
                    } else {
                      _selectedGenreIndices.add(index);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        genre,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: colorScheme.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.t('onboarding.genres_recommendation_hint', {
                          'count': '${_selectedGenreIndices.length}',
                        }) ??
                        'Таны сонгосон ${_selectedGenreIndices.length} төрөлд тулгуурлан нүүр хуудасны зөвлөмж автоматаар баяжина.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Targets & Habits
  Widget _buildStep3Targets(ColorScheme colorScheme, AppLocalizations? l10n, bool isEn) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${l10n?.t('onboarding.step') ?? 'Алхам'} 3/3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.t('onboarding.step3_title') ??
                'Өдөрт хэдэн минут унших зорилготой вэ?',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.t('onboarding.step3_desc') ??
                'Өдөр тутмын тогтмол уншлага нь мэдлэгийг батжуулна.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [15, 30, 45, 60].map((mins) {
              final isSelected = _selectedDailyMinutes == mins;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedPressable(
                    onTap: () => setState(() => _selectedDailyMinutes = mins),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$mins',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n?.t('onboarding.minutes_label') ?? 'минут',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                  : colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            l10n?.t('onboarding.yearly_goal') ?? '2026 онд хэдэн ном унших вэ?',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [12, 24, 36, 52].map((books) {
              final isSelected = _selectedYearlyBooks == books;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedPressable(
                    onTap: () => setState(() => _selectedYearlyBooks = books),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.secondaryContainer
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.secondary
                              : colorScheme.outlineVariant.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$books',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n?.t('onboarding.books_per_year') ?? 'ном / жил',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // STEP 4: Celebration Screen (+100 XP Gamification)
  Widget _buildStep4Celebration(ColorScheme colorScheme, AppLocalizations? l10n, bool isEn) {
    final goals = _goals(isEn);
    final genres = _genres(isEn);
    final selectedGoalTitle = goals[_selectedGoalIndex]['title']!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🎉',
                style: TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n?.t('onboarding.congrats_title') ?? 'Бүх зүйл бэлэн боллоо!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.t('onboarding.congrats_desc') ??
                'Танд урамшуулал болгож +100 XP олгогдлоо. Таны уншлагын аялал эхэллээ!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Gamification XP Reward Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.12),
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('⚡', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.t('onboarding.xp_bonus') ?? '+100 XP Бонус нэмэгдлээ!',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n?.t('onboarding.goal_summary', {
                              'goal': selectedGoalTitle,
                              'mins': '$_selectedDailyMinutes',
                            }) ??
                            'Зорилго: $selectedGoalTitle • Өдөрт $_selectedDailyMinutes мин',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Summary Chip Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.t('onboarding.selected_genres_count', {
                        'count': '${_selectedGenreIndices.length}',
                      }) ??
                      'Сонгосон төрлүүд (${_selectedGenreIndices.length}):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedGenreIndices.map((i) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        genres[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // Final Start Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _finishOnboarding(isEn),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n?.t('onboarding.start_reading') ?? 'Уншиж эхлэх',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
