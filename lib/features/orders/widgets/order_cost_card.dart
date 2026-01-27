import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/order_cost.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/utils/toast.dart';

/// Карточка себестоимости заказа
class OrderCostCard extends ConsumerStatefulWidget {
  final String orderId;

  const OrderCostCard({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderCostCard> createState() => _OrderCostCardState();
}

class _OrderCostCardState extends ConsumerState<OrderCostCard> {
  OrderCost? _cost;
  bool _isLoading = true;
  bool _isRecalculating = false;
  String? _error;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadCost());
    }
  }

  Future<void> _loadCost() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cost = await ref.read(bomNotifierProvider.notifier).getOrderCost(widget.orderId);
      setState(() {
        _cost = cost;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Не удалось загрузить себестоимость';
      });
    }
  }

  Future<void> _recalculate() async {
    setState(() => _isRecalculating = true);

    try {
      final cost = await ref.read(bomNotifierProvider.notifier).recalculateOrderCost(widget.orderId);
      setState(() {
        _cost = cost;
        _isRecalculating = false;
      });
      if (mounted) {
        AppToast.success(context, 'Себестоимость пересчитана');
      }
    } catch (e) {
      setState(() => _isRecalculating = false);
      if (mounted) {
        AppToast.error(context, 'Ошибка пересчёта: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_error != null || _cost == null) {
      return _buildErrorCard();
    }

    return _buildCostCard();
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 0,
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 0,
      color: context.surfaceVariantColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 32,
              color: context.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Себестоимость не рассчитана',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Убедитесь, что у модели добавлены материалы',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _loadCost,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Попробовать снова'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard() {
    final cost = _cost!;
    final isOverBudget = cost.isOverBudget;
    final varianceColor = isOverBudget ? AppColors.error : AppColors.success;

    return Card(
      elevation: 0,
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.calculate_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Себестоимость заказа',
                    style: AppTypography.labelLarge.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
                _isRecalculating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: _recalculate,
                        icon: const Icon(Icons.refresh, size: 20),
                        tooltip: 'Пересчитать',
                        color: context.textSecondaryColor,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Plan vs Actual comparison
            Row(
              children: [
                // Planned
                Expanded(
                  child: _CostBox(
                    title: 'План',
                    value: cost.formattedPlannedCost,
                    breakdown: [
                      _BreakdownRow('Материалы', cost.plannedMaterialCost),
                      _BreakdownRow('Работа', cost.plannedLaborCost),
                      _BreakdownRow('Накладные', cost.plannedOverheadCost),
                    ],
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Actual
                Expanded(
                  child: _CostBox(
                    title: 'Факт',
                    value: cost.formattedActualCost,
                    breakdown: [
                      _BreakdownRow('Материалы', cost.actualMaterialCost),
                      _BreakdownRow('Работа', cost.actualLaborCost),
                      _BreakdownRow('Накладные', cost.actualOverheadCost),
                    ],
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Variance indicator
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: varianceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: varianceColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOverBudget
                        ? Icons.trending_up
                        : cost.variancePct < 0
                            ? Icons.trending_down
                            : Icons.remove,
                    color: varianceColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Отклонение: ${cost.formattedVariance}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: varianceColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: varianceColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      cost.formattedVariancePct,
                      style: AppTypography.labelSmall.copyWith(
                        color: varianceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostBox extends StatelessWidget {
  final String title;
  final String value;
  final List<_BreakdownRow> breakdown;
  final Color color;

  const _CostBox({
    required this.title,
    required this.value,
    required this.breakdown,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...breakdown.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    Text(
                      '${row.value.toStringAsFixed(0)} сом',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _BreakdownRow {
  final String label;
  final double value;

  const _BreakdownRow(this.label, this.value);
}
