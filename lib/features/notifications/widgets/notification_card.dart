import 'package:flutter/material.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notif;
  final BookProvider provider;

  const NotificationCard({
    super.key,
    required this.notif,
    required this.provider,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'new_book':
        return Icons.menu_book_rounded;
      case 'recommendation':
        return Icons.auto_awesome_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'system':
        return Icons.system_update_rounded;
      case 'author':
        return Icons.favorite_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type, ColorScheme colorScheme) {
    switch (type) {
      case 'new_book':
        return colorScheme.primary;
      case 'recommendation':
        return const Color(0xFFE67E22);
      case 'achievement':
        return const Color(0xFF27AE60);
      case 'system':
        return const Color(0xFF8E44AD);
      case 'author':
        return const Color(0xFFE74C3C);
      default:
        return colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = _getColorForType(notif.type, colorScheme);
    final icon = _getIconForType(notif.type);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        provider.deleteNotification(notif.id);
      },
      child: AnimatedPressable(
        onTap: () {
          if (!notif.isRead) {
            provider.markNotificationAsRead(notif.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif.isRead
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
                : colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif.isRead
                  ? colorScheme.outlineVariant.withValues(alpha: 0.2)
                  : colorScheme.primary.withValues(alpha: 0.2),
              width: notif.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 15,
                              fontWeight: notif.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notif.time,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => provider.deleteNotification(notif.id),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
