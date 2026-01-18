import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A metric display widget showing label, value, and optional sub-value
class MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color? color;
  final TextAlign textAlign;

  const MetricItem({
    super.key,
    required this.label,
    required this.value,
    this.subValue,
    this.color,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondaryColor,
          ),
          textAlign: textAlign,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: textAlign,
        ),
        if (subValue != null)
          Text(
            subValue!,
            style: AppTypography.bodySmall.copyWith(
              color: color ?? context.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: textAlign,
          ),
      ],
    );
  }
}
