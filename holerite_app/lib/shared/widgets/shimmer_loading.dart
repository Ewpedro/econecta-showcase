import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';

class ShimmerDashboard extends StatelessWidget {
  const ShimmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceVariant,
      highlightColor: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _box(height: 200, radius: 20),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _box(height: 90, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _box(height: 90, radius: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _box(height: 90, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _box(height: 90, radius: 16)),
              ],
            ),
            const SizedBox(height: 20),
            _box(height: 160, radius: 16),
          ],
        ),
      ),
    );
  }

  Widget _box({required double height, double radius = 8}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
