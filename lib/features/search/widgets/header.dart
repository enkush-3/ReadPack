import 'package:flutter/material.dart';
import 'package:readpack/features/search/widgets/filtershell.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class SearchHeader extends StatelessWidget {
  final String? userName;
  final VoidCallback? onAvatarTap;
  final FilterData? currentFilters;
  final void Function(FilterData)? onFilterApplied;

  const SearchHeader({
    super.key,
    this.userName,
    this.onAvatarTap,
    this.currentFilters,
    this.onFilterApplied,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final userInitial = (userName != null && userName!.isNotEmpty)
        ? userName![0].toUpperCase()
        : 'U';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedPressable(
          onTap: onAvatarTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userInitial,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.t('book.search') ?? 'Хайх',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              l10n?.t('book.find') ?? 'Дуртай номоо олоорой',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        AnimatedPressable(
          onTap: () async {
            final result = await FilterBottomSheet.show(
              context,
              currentFilters ?? FilterData.defaults(),
            );
            if (result != null) {
              onFilterApplied?.call(result);
            }
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tune_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}