import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BookCoverImage extends StatelessWidget {
  final String? image;
  final int colorHex;
  final String title;
  final String? author;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double borderRadius;

  const BookCoverImage({
    super.key,
    required this.image,
    required this.colorHex,
    required this.title,
    this.author,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = 0,
  });

  Widget _buildArtworkPlaceholder() {
    Color primaryColor;
    if (colorHex != 0xFF182350 && colorHex != 0xFF1E293B) {
      primaryColor = Color(colorHex);
    } else {
      const palette = [
        Color(0xFF8B263E), // Rich Crimson
        Color(0xFF1B4965), // Deep Ocean Teal
        Color(0xFF2D5A27), // Forest Emerald
        Color(0xFF6B4226), // Warm Leather Brown
        Color(0xFF4A306D), // Royal Plum
        Color(0xFF9C4A1A), // Burnt Sienna
        Color(0xFF1E3A8A), // Midnight Indigo
      ];
      final hash = title.hashCode.abs();
      primaryColor = palette[hash % palette.length];
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated book spine groove
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  if (author != null && author!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      author!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    final img = image?.trim();

    if (img == null || img.isEmpty) {
      content = _buildArtworkPlaceholder();
    } else if (img.startsWith('http://') || img.startsWith('https://')) {
      content = CachedNetworkImage(
        imageUrl: img,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: Color(colorHex).withValues(alpha: 0.3),
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _buildArtworkPlaceholder(),
      );
    } else {
      content = Image.asset(
        img,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildArtworkPlaceholder(),
      );
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}
