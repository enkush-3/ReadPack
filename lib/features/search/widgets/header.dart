import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readpack/features/search/widgets/filtershell.dart';
import 'package:readpack/helper/translation.dart';

class SearchHeader extends StatelessWidget {
  final String? userName;

  const SearchHeader({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
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
            ),
            child: TextButton(
              onPressed: () => context.go('/home'),
              child: Text(
              userName![0].toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Text(
                  l10n.t('book.search'),
                  style: TextStyle(
                    fontFamily: 'Serif',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                  ),
                ),
                Text(
                  l10n.t('book.find'),
                  style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.7),
                  colorScheme.primary,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.tune_rounded, color: colorScheme.onPrimary),
              onPressed: () async {
                final result = await FilterBottomSheet.show(
                  context,
                  FilterData.defaults(),
                );
                if (result != null) {
                  debugPrint('Filter applied: ${result.categories}, rating: ${result.minRating}');
                }
              },
            ),
          )
        ],
      ),
    );
  }
}