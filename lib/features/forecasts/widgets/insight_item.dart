import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class InsightItem extends StatelessWidget {
  final String insight;

  const InsightItem({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.lightbulb_outline;
    Color iconColor = AppColors.info;

    // Determine icon based on insight content
    if (insight.contains('Внимание') || insight.contains('просроч')) {
      iconData = Icons.warning_amber;
      iconColor = AppColors.warning;
    } else if (insight.contains('вырос') || insight.contains('отлич')) {
      iconData = Icons.thumb_up;
      iconColor = AppColors.success;
    } else if (insight.contains('сниз')) {
      iconData = Icons.thumb_down;
      iconColor = AppColors.error;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight,
              style: AppTypography.bodySmall.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
