import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/onboarding/presentation/widgets/onboarding_celebration_step.dart';
import 'package:readpack/features/onboarding/presentation/widgets/onboarding_constants.dart';
import 'package:readpack/features/onboarding/presentation/widgets/onboarding_genre_step.dart';
import 'package:readpack/features/onboarding/presentation/widgets/onboarding_goal_step.dart';
import 'package:readpack/features/onboarding/presentation/widgets/onboarding_pace_step.dart';
import 'package:readpack/helper/translation.dart';

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
    final currentGenres = OnboardingConstants.genres(isEn);
    bookProvider.completeOnboarding(
      favoriteGenres:
          _selectedGenreIndices.map((i) => currentGenres[i]).toList(),
      dailyGoalMinutes: _selectedDailyMinutes,
      yearlyGoalBooks: _selectedYearlyBooks,
    );

    final args = ModalRoute.of(context)?.settings.arguments;
    final bool isFromSettings = args is Map && args['fromSettings'] == true;

    if (isFromSettings && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.appshell,
        (route) => false,
        arguments: 0,
      );
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
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
                              : colorScheme.outlineVariant
                                  .withValues(alpha: 0.4),
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
                  OnboardingGoalStep(
                    selectedIndex: _selectedGoalIndex,
                    onSelect: (index) =>
                        setState(() => _selectedGoalIndex = index),
                    isEn: isEn,
                  ),
                  OnboardingGenreStep(
                    selectedIndices: _selectedGenreIndices,
                    onToggle: (index) {
                      setState(() {
                        if (_selectedGenreIndices.contains(index)) {
                          if (_selectedGenreIndices.length > 1) {
                            _selectedGenreIndices.remove(index);
                          }
                        } else {
                          _selectedGenreIndices.add(index);
                        }
                      });
                    },
                    isEn: isEn,
                  ),
                  OnboardingPaceStep(
                    selectedDailyMinutes: _selectedDailyMinutes,
                    selectedYearlyBooks: _selectedYearlyBooks,
                    onDailyMinutesChanged: (mins) =>
                        setState(() => _selectedDailyMinutes = mins),
                    onYearlyBooksChanged: (books) =>
                        setState(() => _selectedYearlyBooks = books),
                  ),
                  OnboardingCelebrationStep(
                    selectedGoalIndex: _selectedGoalIndex,
                    selectedGenreIndices: _selectedGenreIndices,
                    selectedDailyMinutes: _selectedDailyMinutes,
                    isEn: isEn,
                    onFinish: () => _finishOnboarding(isEn),
                  ),
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
}
