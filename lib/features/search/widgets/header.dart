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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.t('book.search') ?? 'Хайх',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                l10n?.t('book.find') ?? 'Дуртай номоо олоорой',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: l10n?.t('filter.title') ?? 'Filters',
          child: IconButton.filledTonal(
            onPressed: () async {
              final result = await FilterBottomSheet.show(
                context,
                currentFilters ?? FilterData.defaults(),
              );
              if (result != null) {
                onFilterApplied?.call(result);
              }
            },
            icon: const Icon(Icons.tune_rounded),
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: colorScheme.onSecondaryContainer,
              backgroundColor: colorScheme.secondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
