import 'package:flutter/material.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_button.dart';

class ErrorStateView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.t('error.title') ?? 'Алдаа гарлаа',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedButton(
              onPressed: onRetry,
              icon: Icons.refresh_rounded,
              semanticLabel: l10n?.t('common.retry') ?? 'Дахин оролдох',
              child: Text(l10n?.t('common.retry') ?? 'Дахин оролдох'),
            ),
          ],
        ),
      ),
    );
  }
}
