import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterData initialData;
  final void Function(FilterData) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialData,
    required this.onApply,
  });

  static Future<FilterData?> show(BuildContext context, FilterData initialData) {
    return showDialog<FilterData>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      barrierDismissible: true,
      builder: (context) {
        return _BlurFilterDialog(initialData: initialData);
      },
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _BlurFilterDialog extends StatefulWidget {
  final FilterData initialData;

  const _BlurFilterDialog({required this.initialData});

  @override
  State<_BlurFilterDialog> createState() => _BlurFilterDialogState();
}

class _BlurFilterDialogState extends State<_BlurFilterDialog> {
  late FilterData _data;

  @override
  void initState() {
    super.initState();
    _data = FilterData.from(widget.initialData);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);
    final filterTitle = l10n?.t('filter.title') ?? 'Шүүлтүүр';
    final categorySection = l10n?.t('filter.category') ?? 'Төрөл';
    final ratingSection = l10n?.t('filter.rating') ?? 'Үнэлгээ';
    final sortSection = l10n?.t('filter.sort_by') ?? 'Эрэмбэлэх';
    final clearText = l10n?.t('filter.clear') ?? 'Цэвэрлэх';
    final applyText = l10n?.t('filter.apply') ?? 'Шүүх';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, size.height * 0.6 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.75,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                filterTitle,
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: colorScheme.onSurface,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FilterSectionTitle(title: categorySection),
                                const SizedBox(height: 12),
                                _CategoryChips(
                                  selected: _data.categories,
                                  onChanged: (v) =>
                                      setState(() => _data.categories = v),
                                ),

                                const SizedBox(height: 24),

                                _FilterSectionTitle(title: ratingSection),
                                const SizedBox(height: 12),
                                _RatingFilter(
                                  selected: _data.minRating,
                                  onChanged: (v) =>
                                      setState(() => _data.minRating = v),
                                ),

                                const SizedBox(height: 24),

                                _FilterSectionTitle(title: sortSection),
                                const SizedBox(height: 12),
                                _SortOptions(
                                  selected: _data.sortBy,
                                  onChanged: (v) =>
                                      setState(() => _data.sortBy = v),
                                ),

                                const SizedBox(height: 24),

                                _FilterSectionTitle(
                                  title: l10n?.t('filter.mood') ??
                                      'Сэтгэл хөдлөл (Mood & Pace)',
                                ),
                                const SizedBox(height: 12),
                                _MoodChips(
                                  selected: _data.mood,
                                  onChanged: (v) =>
                                      setState(() => _data.mood = v),
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _resetFilters,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.onSurface,
                                      side: BorderSide(
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.2),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      clearText,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: _applyFilters,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      applyText,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }

  void _resetFilters() {
    setState(() {
      _data = FilterData.defaults();
    });
  }

  void _applyFilters() {
    Navigator.pop(context, _data);
  }
}

class FilterData {
  List<String> categories;
  double minRating;
  String sortBy;
  String priceRange;
  String mood;

  FilterData({
    required this.categories,
    required this.minRating,
    required this.sortBy,
    required this.priceRange,
    this.mood = 'all',
  });

  factory FilterData.defaults() => FilterData(
    categories: [],
    minRating: 0,
    sortBy: 'popular',
    priceRange: 'all',
    mood: 'all',
  );

  factory FilterData.from(FilterData other) => FilterData(
    categories: List.from(other.categories),
    minRating: other.minRating,
    sortBy: other.sortBy,
    priceRange: other.priceRange,
    mood: other.mood,
  );
}


class _FilterSectionTitle extends StatelessWidget {
  final String title;
  const _FilterSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Serif',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _CategoryChips({required this.selected, required this.onChanged});

  static const _categoryItems = [
    {'key': 'all', 'label': 'Бүгд'},
    {'key': 'book.categories.romance', 'label': 'Роман'},
    {'key': 'book.categories.history', 'label': 'Түүх'},
    {'key': 'book.categories.science', 'label': 'Шинжлэх ухаан'},
    {'key': 'book.categories.business', 'label': 'Бизнес'},
    {'key': 'book.categories.adventure', 'label': 'Адал явдал'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categoryItems.map((item) {
        final key = item['key']!;
        final label = key == 'all'
            ? (l10n?.t('filter.all') ?? 'Бүгд')
            : (l10n?.t(key) ?? item['label']!);
        final isSelected = key == 'all'
            ? selected.isEmpty
            : selected.contains(key);

        return GestureDetector(
          onTap: () {
            if (key == 'all') {
              onChanged([]);
            } else {
              final newSelected = List<String>.from(selected);
              if (newSelected.contains(key)) {
                newSelected.remove(key);
              } else {
                newSelected.add(key);
              }
              onChanged(newSelected);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RatingFilter extends StatelessWidget {
  final double selected;
  final ValueChanged<double> onChanged;

  const _RatingFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final allText = l10n?.t('filter.all') ?? 'Бүгд';

    return Row(
      children: [0, 3, 4, 4.5, 5].map((rating) {
        final isSelected = selected == rating;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(rating.toDouble()),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: isSelected ? Colors.amber : Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    rating == 0 ? allText : '$rating+',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SortOptions extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _SortOptions({required this.selected, required this.onChanged});

  static const _options = [
    {'key': 'popular', 'label': 'Эрэлттэй', 'icon': Icons.local_fire_department_rounded},
    {'key': 'newest', 'label': 'Шинэ', 'icon': Icons.new_releases_rounded},
    {'key': 'rating', 'label': 'Үнэлгээ', 'icon': Icons.star_rounded},
    {'key': 'title', 'label': 'Нэр', 'icon': Icons.sort_by_alpha_rounded},
  ];

  String _getSortLabel(String key, AppLocalizations? l10n) {
    switch (key) {
      case 'popular':
        return l10n?.t('filter.sort_popular') ?? 'Эрэлттэй';
      case 'newest':
        return l10n?.t('filter.sort_newest') ?? 'Шинэ';
      case 'rating':
        return l10n?.t('filter.sort_rating') ?? 'Үнэлгээ';
      case 'title':
        return l10n?.t('filter.sort_title') ?? 'Нэр';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: _options.map((opt) {
          final isSelected = selected == opt['key'];
          final sortKey = opt['key'] as String;
          final sortLabel = _getSortLabel(sortKey, l10n);

          return GestureDetector(
            onTap: () => onChanged(sortKey),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    opt['icon'] as IconData,
                    size: 20,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sortLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MoodChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _MoodChips({
    required this.selected,
    required this.onChanged,
  });

  static const _moods = [
    {'key': 'all', 'label': 'Бүгд (All)', 'icon': Icons.all_inclusive_rounded},
    {'key': 'inspiring', 'label': 'Урам зориг (Inspiring)', 'icon': Icons.bolt_rounded},
    {'key': 'philosophical', 'label': 'Гүн ухаан (Philosophical)', 'icon': Icons.auto_stories_rounded},
    {'key': 'light_reading', 'label': 'Хөнгөн (Light Reading)', 'icon': Icons.menu_book_rounded},
    {'key': 'deep_focus', 'label': 'Гүн төвлөрөл (Deep Focus)', 'icon': Icons.psychology_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _moods.map((m) {
        final key = m['key'] as String;
        final label = m['label'] as String;
        final icon = m['icon'] as IconData;
        final isSelected = selected == key;

        return ChoiceChip(
          selected: isSelected,
          avatar: Icon(
            icon,
            size: 16,
            color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
          ),
          label: Text(label),
          selectedColor: colorScheme.primary,
          backgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
          onSelected: (_) => onChanged(key),
        );
      }).toList(),
    );
  }
}