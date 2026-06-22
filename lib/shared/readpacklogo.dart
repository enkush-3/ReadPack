import 'package:flutter/material.dart';

class ReadPackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 90),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.auto_stories,
              color: colorScheme.primary.withValues(alpha: 0.8),
              size: 56,
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
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary.withValues(alpha: 0.8),
                  letterSpacing: -1,
                  height: 1.0,
                ),
              ),
              Text(
                "Pack",
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 40,
                  color: colorScheme.primary.withValues(alpha: 0.8),
                  letterSpacing: -1,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}