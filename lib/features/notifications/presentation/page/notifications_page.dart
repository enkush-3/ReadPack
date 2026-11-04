import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/helper/translation.dart';
import 'package:readpack/models/notification_model.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/backbutton.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _activeTab = 'all'; // 'all', 'unread', 'archived'

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
    final bookProvider = context.watch<BookProvider>();
    final allNotifs = bookProvider.notifications;
    final l10n = AppLocalizations.of(context);

    final titleText = l10n?.t('notifications.title') ?? 'Мэдэгдэл';
    final markAllText =
        l10n?.t('notifications.mark_all_read') ?? 'Бүгдийг унших';
    final allMarkedText = l10n?.t('notifications.all_marked_read') ??
        'Бүх мэдэгдлийг уншсанаар тэмдэглэлээ.';
    final tabAllText =
        '${l10n?.t('notifications.all') ?? 'Бүгд'} (${allNotifs.length})';
    final tabUnreadText =
        '${l10n?.t('notifications.unread') ?? 'Уншаагүй'} (${bookProvider.unreadNotificationsCount})';
    final tabArchivedText =
        '${l10n?.t('notifications.archived') ?? 'Уншсан'} (${allNotifs.length - bookProvider.unreadNotificationsCount})';

    final filtered = allNotifs.where((n) {
      if (_activeTab == 'unread') return !n.isRead;
      if (_activeTab == 'archived') return n.isRead;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  CustomBackButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titleText,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  if (bookProvider.unreadNotificationsCount > 0)
                    AnimatedPressable(
                      onTap: () {
                        bookProvider.markAllNotificationsAsRead();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(allMarkedText),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.done_all_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              markAllText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTabItem('all', tabAllText, colorScheme),
                    _buildTabItem('unread', tabUnreadText, colorScheme),
                    _buildTabItem('archived', tabArchivedText, colorScheme),
                  ],
                ),
              ),
            ),

            // Main Content Area
            Expanded(
              child: bookProvider.isLoading
                  ? _buildLoadingSkeleton()
                  : filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final notif = filtered[index];
                            return _buildNotificationCard(
                              notif,
                              colorScheme,
                              bookProvider,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String key, String label, ColorScheme colorScheme) {
    final isSelected = _activeTab == key;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _activeTab = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationItem notif,
    ColorScheme colorScheme,
    BookProvider provider,
  ) {
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

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    final emptyUnreadTitle =
        l10n?.t('notifications.empty_unread_title') ?? 'Уншаагүй мэдэгдэл алга';
    final emptyTitle =
        l10n?.t('notifications.empty_title') ?? 'Мэдэгдэл байхгүй байна';
    final emptyDesc = l10n?.t('notifications.empty_desc') ??
        'Таны бүх мэдэгдлүүд уншигдсан байна.';
    final viewAllText =
        l10n?.t('notifications.view_all') ?? 'Бүх мэдэгдлийг харах';

    return Center(
      child: EmptyStateView(
        icon: Icons.notifications_off_rounded,
        title: _activeTab == 'unread' ? emptyUnreadTitle : emptyTitle,
        message: emptyDesc,
        actionLabel: _activeTab != 'all' ? viewAllText : null,
        onAction: _activeTab != 'all'
            ? () => setState(() => _activeTab = 'all')
            : null,
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SkeletonLoader(
          width: double.infinity,
          height: 90,
          borderRadius: 16,
        ),
      ),
    );
  }
}
