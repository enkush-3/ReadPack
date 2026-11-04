import 'package:flutter/material.dart';

class ReadPackLogo extends StatelessWidget {
  final double size;

  const ReadPackLogo({
    super.key,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            color: colorScheme.primary,
            size: size * 0.75,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Read",
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: size * 0.7,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            Text(
              "Pack",
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: size * 0.6,
                fontWeight: FontWeight.w400,
                color: colorScheme.secondary,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}