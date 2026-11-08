import 'package:flutter/material.dart';
import 'package:readpack/features/search/model/filter_data.dart';
import 'package:readpack/features/search/widgets/filter_dialog_sections.dart';
import 'package:readpack/helper/translation.dart';

export 'package:readpack/features/search/model/filter_data.dart';

class FilterBottomSheet extends StatelessWidget {
  final FilterData initialData;
  final void Function(FilterData) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialData,
    required this.onApply,
  });

  static Future<FilterData?> show(
    BuildContext context,
    FilterData initialData,
  ) {
    return showModalBottomSheet<FilterData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return _FilterBottomSheetContent(initialData: initialData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _FilterBottomSheetContent extends StatefulWidget {
  final FilterData initialData;

  const _FilterBottomSheetContent({required this.initialData});

  @override
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late FilterData _data;

  @override
  void initState() {
    super.initState();
    _data = FilterData.from(widget.initialData);
  }

  void _resetFilters() {
    setState(() {
      _data = FilterData.defaults();
    });
  }

  void _applyFilters() {
    Navigator.pop(context, _data);
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

    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Center(
              child: Text(
                filterTitle,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilterSectionTitle(title: categorySection),
                  const SizedBox(height: 10),
                  CategoryChips(
                    selected: _data.categories,
                    onChanged: (newCategories) {
                      setState(() {
                        _data.categories = newCategories;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  FilterSectionTitle(title: ratingSection),
                  const SizedBox(height: 10),
                  RatingFilterSection(
                    selected: _data.minRating,
                    onChanged: (rating) {
                      setState(() => _data.minRating = rating);
                    },
                  ),
                  const SizedBox(height: 20),
                  FilterSectionTitle(title: sortSection),
                  const SizedBox(height: 10),
                  SortOptionsSection(
                    selected: _data.sortBy,
                    onChanged: (sort) {
                      setState(() => _data.sortBy = sort);
                    },
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
        ],
      ),
    );
  }
}
