import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Stock level indicator widget
class StockIndicator extends StatelessWidget {
  final double quantity;
  final double? minStockLevel;
  final bool showLabel;
  final double size;

  const StockIndicator({
    super.key,
    required this.quantity,
    this.minStockLevel,
    this.showLabel = false,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getStockStatus();
    final color = _getColor(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            _getLabel(status),
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  StockStatus _getStockStatus() {
    if (quantity <= 0) {
      return StockStatus.outOfStock;
    }
    if (minStockLevel != null && quantity <= minStockLevel!) {
      return StockStatus.low;
    }
    if (minStockLevel != null && quantity <= minStockLevel! * 1.5) {
      return StockStatus.warning;
    }
    return StockStatus.ok;
  }

  Color _getColor(StockStatus status) {
    switch (status) {
      case StockStatus.ok:
        return AppColors.success;
      case StockStatus.warning:
        return AppColors.warning;
      case StockStatus.low:
        return AppColors.error;
      case StockStatus.outOfStock:
        return AppColors.error;
    }
  }

  String _getLabel(StockStatus status) {
    switch (status) {
      case StockStatus.ok:
        return 'В наличии';
      case StockStatus.warning:
        return 'Мало';
      case StockStatus.low:
        return 'Критично';
      case StockStatus.outOfStock:
        return 'Нет в наличии';
    }
  }
}

enum StockStatus { ok, warning, low, outOfStock }

/// Stock level progress bar
class StockLevelBar extends StatelessWidget {
  final double quantity;
  final double? minStockLevel;
  final double maxLevel;
  final double height;

  const StockLevelBar({
    super.key,
    required this.quantity,
    this.minStockLevel,
    this.maxLevel = 100,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (quantity / maxLevel).clamp(0.0, 1.0);
    final color = _getColor();

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    if (quantity <= 0) {
      return AppColors.error;
    }
    if (minStockLevel != null && quantity <= minStockLevel!) {
      return AppColors.error;
    }
    if (minStockLevel != null && quantity <= minStockLevel! * 1.5) {
      return AppColors.warning;
    }
    return AppColors.success;
  }
}
