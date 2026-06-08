import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/navigation/page_header.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _activeTab = 'all';

  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.menu_book_rounded,
      'iconColor': const Color(0xFF425CAC),
      'title': 'Шинэ ном нэмэгдлээ',
      'message': '"Atomic Habits" ном таны сан руу нэмэгдлээ. Одоо уншиж эхлээрэй!',
      'time': '5 мин',
      'isRead': false,
      'type': 'new_book',
    },
    {
      'icon': Icons.star_rounded,
      'iconColor': const Color(0xFFE67E22),
      'title': 'Өдрийн зөвлөмж',
      'message': 'Таны уншдаг төрөлд тохирох 3 шинэ ном санал болгож байна.',
      'time': '1 цаг',
      'isRead': false,
      'type': 'recommendation',
    },
    {
      'icon': Icons.emoji_events_rounded,
      'iconColor': const Color(0xFF27AE60),
      'title': 'Амжилт!',
      'message': 'Та 7 өдөр дараалан уншсаны төлөө "Номын хорхойтон" badge авлаа.',
      'time': 'Өчигдөр',
      'isRead': true,
      'type': 'achievement',
    },
    {
      'icon': Icons.update_rounded,
      'iconColor': const Color(0xFF8E44AD),
      'title': 'Аппликейшн шинэчлэгдсэн',
      'message': 'Шинэ функц: Одоо та номуудаа offline-р унших боломжтой боллоо.',
      'time': '2 өдөр',
      'isRead': true,
      'type': 'system',
    },
    {
      'icon': Icons.favorite_rounded,
      'iconColor': const Color(0xFFC0392B),
      'title': 'Дуртай зохиолч',
      'message': 'Paulo Coelho-ийн шинэ ном гарлаа. Шалгаад үзээрэй!',
      'time': '3 өдөр',
      'isRead': true,
      'type': 'author',
    },
    {
      'icon': Icons.favorite_rounded,
      'iconColor': const Color(0xFFC0392B),
      'title': 'Дуртай зохиолч',
      'message': 'Paulo Coelho-ийн шинэ ном гарлаа. Шалгаад үзээрэй!',
      'time': '3 өдөр',
      'isRead': true,
      'type': 'author',
    },
    {
      'icon': Icons.favorite_rounded,
      'iconColor': const Color(0xFFC0392B),
      'title': 'Дуртай зохиолч',
      'message': 'Paulo Coelho-ийн шинэ ном гарлаа. Шалгаад үзээрэй!',
      'time': '3 өдөр',
      'isRead': true,
      'type': 'author',
    },
    {
      'icon': Icons.favorite_rounded,
      'iconColor': const Color(0xFFC0392B),
      'title': 'Дуртай зохиолч',
      'message': 'Paulo Coelho-ийн шинэ ном гарлаа. Шалгаад үзээрэй!',
      'time': '3 өдөр',
      'isRead': true,
      'type': 'author',
    },
    {
      'icon': Icons.favorite_rounded,
      'iconColor': const Color(0xFFC0392B),
      'title': 'Дуртай зохиолч',
      'message': 'Paulo Coelho-ийн шинэ ном гарлаа. Шалгаад үзээрэй!',
      'time': '3 өдөр',
      'isRead': true,
      'type': 'author',
    },
    {
      'icon': Icons.favorite_rounded,
      'iconColor': const Color(0xFFC0392B),
      'title': 'Дуртай зохиолч',
      'message': 'Paulo Coelho-ийн шинэ ном гарлаа. Шалгаад үзээрэй!',
      'time': '3 өдөр',
      'isRead': true,
      'type': 'author',
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_activeTab == 'unread') {
      return _notifications.where((n) => !n['isRead']).toList();
    } else if (_activeTab == 'archived') {
      return _notifications.where((n) => n['isRead']).toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Мэдэгдэл',
              onBack: () => Navigator.pop(context),
            ),
            _buildTabs(colorScheme),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? _EmptyNotifications()
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredNotifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final notification = _filteredNotifications[index];
                  return _NotificationItem(
                    notification: notification,
                    onTap: () => _onNotificationTap(notification),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(ColorScheme colorScheme) {
    final tabs = [
      {'key': 'all', 'label': 'Бүгд'},
      {'key': 'unread', 'label': 'Уншаагүй'},
      {'key': 'archived', 'label': 'Архивласан'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: tabs.map((tab) {
            final isSelected = _activeTab == tab['key'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = tab['key'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });
    debugPrint('Мэдэгдэл дарагдлаа: ${notification['title']}');
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRead = notification['isRead'] as bool;
    final iconColor = notification['iconColor'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
              : colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: isRead
              ? null
              : Border.all(
            color: colorScheme.primary.withValues(alpha: 0.15),
            width: 1,
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
              child: Icon(
                notification['icon'] as IconData,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] as String,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification['time'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Мэдэгдэл байхгүй',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Одоогоор танд шинэ мэдэгдэл алга.',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}