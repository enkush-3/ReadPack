import 'dart:ui';
import 'package:flutter/material.dart';

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
                            'Шүүлтүүр',
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
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                            _FilterSectionTitle(title: 'Төрөл'),
                            const SizedBox(height: 12),
                            _CategoryChips(
                              selected: _data.categories,
                              onChanged: (v) => setState(() => _data.categories = v),
                            ),

                            const SizedBox(height: 24),

                            _FilterSectionTitle(title: 'Үнэлгээ'),
                            const SizedBox(height: 12),
                            _RatingFilter(
                              selected: _data.minRating,
                              onChanged: (v) => setState(() => _data.minRating = v),
                            ),

                            const SizedBox(height: 24),

                            _FilterSectionTitle(title: 'Эрэмбэлэх'),
                            const SizedBox(height: 12),
                            _SortOptions(
                              selected: _data.sortBy,
                              onChanged: (v) => setState(() => _data.sortBy = v),
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
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Цэвэрлэх',
                                  style: TextStyle(
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
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Шүүх',
                                  style: TextStyle(
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

  FilterData({
    required this.categories,
    required this.minRating,
    required this.sortBy,
    required this.priceRange,
  });

  factory FilterData.defaults() => FilterData(
    categories: [],
    minRating: 0,
    sortBy: 'popular',
    priceRange: 'all',
  );

  factory FilterData.from(FilterData other) => FilterData(
    categories: List.from(other.categories),
    minRating: other.minRating,
    sortBy: other.sortBy,
    priceRange: other.priceRange,
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

  static const _allCategories = [
    'Бүгд', 'Роман', 'Түүх', 'Шинжлэх ухаан',
    'Бизнес', 'Адал явдал', 'Уран зохиол',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allCategories.map((cat) {
        final isSelected = cat == 'Бүгд'
            ? selected.isEmpty
            : selected.contains(cat);

        return GestureDetector(
          onTap: () {
            if (cat == 'Бүгд') {
              onChanged([]);
            } else {
              final newSelected = List<String>.from(selected);
              if (newSelected.contains(cat)) {
                newSelected.remove(cat);
              } else {
                newSelected.add(cat);
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
              cat,
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
                    rating == 0 ? 'Бүгд' : '$rating+',
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: _options.map((opt) {
          final isSelected = selected == opt['key'];
          return GestureDetector(
            onTap: () => onChanged(opt['key'] as String),
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
                      opt['label'] as String,
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