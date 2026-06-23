import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeHeader extends StatelessWidget {
  final String? userName;

  const HomeHeader({
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
              icon: Icon(Icons.notifications_none_rounded, color: colorScheme.onPrimary),
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