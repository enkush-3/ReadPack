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
          width: size * 0.9,
          height: size * 0.9,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: size * 0.25,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.auto_stories_rounded,
              color: colorScheme.onPrimary,
              size: size * 0.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Read',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: size * 0.48,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Pack',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: size * 0.48,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}