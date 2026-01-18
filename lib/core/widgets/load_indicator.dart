import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Circular progress indicator showing load percentage
class LoadIndicator extends StatelessWidget {
  final int loadPercentage;
  final Color color;
  final double size;
  final double strokeWidth;

  const LoadIndicator({
    super.key,
    required this.loadPercentage,
    required this.color,
    this.size = 44,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: loadPercentage / 100,
            backgroundColor: context.surfaceVariantColor,
            valueColor: AlwaysStoppedAnimation(color),
            strokeWidth: strokeWidth,
          ),
          Text(
            '$loadPercentage',
            style: AppTypography.labelSmall.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
