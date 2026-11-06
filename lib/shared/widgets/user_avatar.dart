import 'package:flutter/material.dart';
import 'package:readpack/models/user_stats.dart';

class UserAvatar extends StatelessWidget {
  final UserProfile profile;
  final double size;
  final double fontSize;
  final bool showEditBadge;

  const UserAvatar({
    super.key,
    required this.profile,
    this.size = 54,
    this.fontSize = 22,
    this.showEditBadge = false,
  });

  static const List<Map<String, String>> presetAvatars = [
    {'id': '', 'label': 'Үсэг', 'type': 'initial'},
    {'id': '🦉', 'label': 'Шар шувуу', 'type': 'emoji'},
    {'id': '🦊', 'label': 'Үнэг', 'type': 'emoji'},
    {'id': '🦁', 'label': 'Арслан', 'type': 'emoji'},
    {'id': '🐼', 'label': 'Панда', 'type': 'emoji'},
    {'id': '🎓', 'label': 'Эрдэмтэн', 'type': 'emoji'},
    {'id': '🚀', 'label': 'Сансар', 'type': 'emoji'},
    {'id': '👑', 'label': 'Титэм', 'type': 'emoji'},
    {
      'id': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      'label': 'Зураг 1',
      'type': 'image',
    },
    {
      'id': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
      'label': 'Зураг 2',
      'type': 'image',
    },
    {
      'id': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
      'label': 'Зураг 3',
      'type': 'image',
    },
    {
      'id': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
      'label': 'Зураг 4',
      'type': 'image',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatar = profile.avatarUrl.trim();
    final isImageUrl =
        avatar.startsWith('http://') || avatar.startsWith('https://');
    final isEmoji = avatar.isNotEmpty && !isImageUrl;

    Widget innerContent;
    if (profile.isGuest) {
      innerContent = Icon(
        Icons.person_outline_rounded,
        size: size * 0.5,
        color: colorScheme.primary,
      );
    } else if (isImageUrl) {
      innerContent = ClipOval(
        child: Image.network(
          avatar,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitial(colorScheme),
        ),
      );
    } else if (isEmoji) {
      innerContent = Text(
        avatar,
        style: TextStyle(fontSize: fontSize * 1.15),
      );
    } else {
      innerContent = _buildInitial(colorScheme);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: profile.isGuest
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : null,
            gradient: profile.isGuest
                ? null
                : LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.72),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            shape: BoxShape.circle,
            border: Border.all(
              color: profile.isGuest
                  ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                  : colorScheme.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: profile.isGuest
                ? null
                : [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(child: innerContent),
        ),
        if (showEditBadge && !profile.isGuest)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: size * 0.24,
                color: colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitial(ColorScheme colorScheme) {
    final initial =
        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U';
    return Text(
      initial,
      style: TextStyle(
        fontFamily: 'Serif',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
    );
  }
}

