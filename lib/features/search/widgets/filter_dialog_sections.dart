import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';

class FilterSectionTitle extends StatelessWidget {
  final String title;
  const FilterSectionTitle({super.key, required this.title});

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

class CategoryChips extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

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

class RatingFilterSection extends StatelessWidget {
  final double selected;
  final ValueChanged<double> onChanged;

  const RatingFilterSection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

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
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Colors.amber,
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

class SortOptionsSection extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const SortOptionsSection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

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

class MoodChipsSection extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const MoodChipsSection({
    super.key,
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
