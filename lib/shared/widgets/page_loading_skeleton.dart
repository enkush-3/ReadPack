import 'package:flutter/material.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

class PageLoadingSkeleton extends StatelessWidget {
  const PageLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: const [
        SkeletonLoader(width: 180, height: 24),
        SizedBox(height: 20),
        SkeletonLoader(width: double.infinity, height: 132, borderRadius: 20),
        SizedBox(height: 20),
        SkeletonLoader(width: double.infinity, height: 76, borderRadius: 16),
        SizedBox(height: 12),
        SkeletonLoader(width: double.infinity, height: 76, borderRadius: 16),
        SizedBox(height: 12),
        SkeletonLoader(width: double.infinity, height: 76, borderRadius: 16),
      ],
    );
  }
}
