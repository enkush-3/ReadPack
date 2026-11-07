import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/notifications/widgets/notification_card.dart';
import 'package:readpack/helper/translation.dart';
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
  String _activeTab = 'all';

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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  CustomBackButton(onTap: () => Navigator.of(context).pop()),
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
                            Icon(Icons.done_all_rounded,
                                size: 16, color: colorScheme.primary),
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
            Expanded(
              child: bookProvider.isLoading
                  ? _buildLoadingSkeleton()
                  : filtered.isEmpty
                      ? _buildEmptyState(bookProvider)
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => NotificationCard(
                            notif: filtered[index],
                            provider: bookProvider,
                          ),
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

  Widget _buildEmptyState(BookProvider bookProvider) {
    final l10n = AppLocalizations.of(context);
    final emptyUnreadTitle =
        l10n?.t('notifications.empty_unread_title') ?? 'Уншаагүй мэдэгдэл алга';
    final emptyTitle =
        l10n?.t('notifications.empty_title') ?? 'Мэдэгдэл байхгүй байна';
    final emptyDesc = l10n?.t('notifications.empty_desc') ??
        'Таны бүх мэдэгдлүүд уншигдсан байна.';
    final viewAllText =
        l10n?.t('notifications.view_all') ?? 'Бүх мэдэгдлийг харах';
    final hasAnyNotifications = bookProvider.notifications.isNotEmpty;

    return Center(
      child: EmptyStateView(
        icon: Icons.notifications_off_rounded,
        title: _activeTab == 'unread' ? emptyUnreadTitle : emptyTitle,
        message: emptyDesc,
        actionLabel: (_activeTab != 'all' && hasAnyNotifications) ? viewAllText : null,
        onAction: (_activeTab != 'all' && hasAnyNotifications)
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
