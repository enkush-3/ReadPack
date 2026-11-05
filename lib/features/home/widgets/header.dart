import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/routes/routes.dart';
import 'package:readpack/features/home/widgets/streak_modal_sheet.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    required this.userName,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context);
    if (hour < 12) {
      return l10n?.t('home.greeting_morning') ?? 'Өглөөний мэнд,';
    } else if (hour < 18) {
      return l10n?.t('home.greeting_afternoon') ?? 'Өдрийн мэнд,';
    } else {
      return l10n?.t('home.greeting_evening') ?? 'Оройн мэнд,';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookProvider = context.watch<BookProvider>();
    final profile = bookProvider.userProfile;
    final unreadCount = bookProvider.unreadNotificationsCount;
    final l10n = AppLocalizations.of(context);
    final displayName = profile.isGuest
        ? (l10n?.t('profile.guest_user') ??
            (userName.isNotEmpty ? userName : 'Guest'))
        : (userName.isNotEmpty ? userName : profile.name);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Avatar + Greeting
        Expanded(
          child: Row(
            children: [
              AnimatedPressable(
                onTap: onAvatarTap,
                child: Container(
                  width: 46,
                  height: 46,
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
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getGreeting(context),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Right side: Reading Streak Badge + Notifications
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Interactive Reading Streak (Flame) Badge
            AnimatedPressable(
              onTap: () =>
                  showStreakModalSheet(context, profile, colorScheme, l10n),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF5722).withValues(alpha: 0.15),
                      const Color(0xFFFF9800).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.streakDays} ${l10n?.t('home.streak_badge') ?? 'хоног'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Notification Bell
            AnimatedPressable(
              onTap: onNotificationTap ??
                  () {
                    Navigator.of(context).pushNamed(Routes.notifications);
                  },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      unreadCount > 0
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        child: Center(
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}