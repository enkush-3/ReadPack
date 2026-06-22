import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageHeader extends StatelessWidget {
  final String? userName;

  const PageHeader({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
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
            child: Text(
              userName!,
              style: TextStyle(
                fontFamily: 'Serif',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: colorScheme.primary),
              onPressed: () {},
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => NotificationsPage(),
              //     ),
              //   );
              // },
            ),
          )
        ],
      ),
    );
  }
}