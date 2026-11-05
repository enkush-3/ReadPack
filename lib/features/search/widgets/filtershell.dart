import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:readpack/features/search/model/filter_data.dart';
import 'package:readpack/features/search/widgets/filter_dialog_sections.dart';
import 'package:readpack/helper/translation.dart';

export 'package:readpack/features/search/model/filter_data.dart';

class FilterBottomSheet extends StatefulWidget {
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
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
                            FilterSectionTitle(title: categorySection),
                            const SizedBox(height: 12),
                            CategoryChips(
                              selected: _data.categories,
                              onChanged: (v) =>
                                  setState(() => _data.categories = v),
                            ),
                            const SizedBox(height: 24),
                            FilterSectionTitle(title: ratingSection),
                            const SizedBox(height: 12),
                            RatingFilterSection(
                              selected: _data.minRating,
                              onChanged: (v) =>
                                  setState(() => _data.minRating = v),
                            ),
                            const SizedBox(height: 24),
                            FilterSectionTitle(title: sortSection),
                            const SizedBox(height: 12),
                            SortOptionsSection(
                              selected: _data.sortBy,
                              onChanged: (v) =>
                                  setState(() => _data.sortBy = v),
                            ),
                            const SizedBox(height: 24),
                            FilterSectionTitle(
                              title: l10n?.t('filter.mood') ??
                                  'Сэтгэл хөдлөл (Mood & Pace)',
                            ),
                            const SizedBox(height: 12),
                            MoodChipsSection(
                              selected: _data.mood,
                              onChanged: (v) => setState(() => _data.mood = v),
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
                                    vertical: 14,
                                  ),
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
                                    vertical: 14,
                                  ),
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
}