import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class ProfileHeaderCard extends StatelessWidget {
  final BookProvider bookProvider;

  const ProfileHeaderCard({
    super.key,
    required this.bookProvider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = bookProvider.userProfile;
    final l10n = AppLocalizations.of(context);
    final displayName = profile.isGuest
        ? (l10n?.t('profile.guest_user') ?? profile.name)
        : profile.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Avatar & Name Row
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: profile.isGuest
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                    : null,
                gradient: profile.isGuest
                    ? null
                    : LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                shape: BoxShape.circle,
                border: profile.isGuest
                    ? Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                      )
                    : null,
                boxShadow: profile.isGuest
                    ? null
                    : [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: profile.isGuest
                    ? Icon(
                        Icons.person_outline_rounded,
                        size: 28,
                        color: colorScheme.primary,
                      )
                    : Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (profile.isGuest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n?.t('profile.guest_badge') ?? 'Зочин',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.isGuest
                        ? (l10n?.t('app.tagline') ??
                            'Таны ухаалаг цахим номын сан')
                        : profile.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (!profile.isGuest)
              AnimatedPressable(
                onTap: () => Navigator.of(context).pushNamed(Routes.settings),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
