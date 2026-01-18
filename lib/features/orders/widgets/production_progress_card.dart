import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/metric_item.dart';
import '../../../core/models/models.dart';

/// Card displaying production progress for an order
class ProductionProgressCard extends StatelessWidget {
  final Order order;
  final List<ProcessStep> processSteps;
  final List<WorkLog> workLogs;

  const ProductionProgressCard({
    super.key,
    required this.order,
    required this.processSteps,
    required this.workLogs,
  });

  double get _plannedTotalHours {
    if (processSteps.isEmpty) return 0;
    final totalMinutes = processSteps.fold<int>(
      0,
      (sum, step) => sum + step.estimatedTime,
    );
    return (totalMinutes * order.quantity) / 60.0;
  }

  int get _completedQuantity {
    if (processSteps.isEmpty || workLogs.isEmpty) return 0;
    return processSteps.map((step) {
      return workLogs
          .where((w) => w.step.toLowerCase() == step.name.toLowerCase())
          .fold<int>(0, (sum, w) => sum + w.quantity);
    }).reduce((a, b) => a < b ? a : b);
  }

  double get _progressPercentage {
    if (order.quantity == 0) return 0;
    return (_completedQuantity / order.quantity * 100).clamp(0, 100);
  }

  double get _expectedProgressPercentage {
    if (order.dueDate == null) return 0;
    final totalDays = order.dueDate!.difference(order.createdAt).inDays;
    final elapsedDays = DateTime.now().difference(order.createdAt).inDays;
    if (totalDays <= 0) return 100;
    return (elapsedDays / totalDays * 100).clamp(0, 100);
  }

  bool get _isBehindSchedule => _progressPercentage < _expectedProgressPercentage - 10;

  int get _daysRemaining {
    if (order.dueDate == null) return 0;
    return order.dueDate!.difference(DateTime.now()).inDays;
  }

  double get _neededPerDay {
    if (_daysRemaining <= 0) return double.infinity;
    final remaining = order.quantity - _completedQuantity;
    return remaining / _daysRemaining;
  }

  @override
  Widget build(BuildContext context) {
    final isOnSchedule = !_isBehindSchedule;
    final statusColor = isOnSchedule ? AppColors.success : AppColors.warning;

    return SectionCard(
      title: 'Прогресс производства',
      icon: Icons.trending_up,
      child: Column(
        children: [
          // Progress bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (order.dueDate != null)
                FractionallySizedBox(
                  widthFactor: _expectedProgressPercentage / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.textSecondaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              FractionallySizedBox(
                widthFactor: _progressPercentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Metrics row
          Row(
            children: [
              Expanded(
                child: MetricItem(
                  label: 'Выполнено',
                  value: '$_completedQuantity/${order.quantity} шт',
                  subValue: '${_progressPercentage.toStringAsFixed(0)}%',
                  color: statusColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: context.borderColor,
              ),
              Expanded(
                child: MetricItem(
                  label: 'План. часов',
                  value: '${_plannedTotalHours.toStringAsFixed(1)} ч',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: context.borderColor,
              ),
              Expanded(
                child: MetricItem(
                  label: 'Осталось дней',
                  value: _daysRemaining > 0 ? '$_daysRemaining' : 'Просрочен',
                  color: _daysRemaining <= 0 ? AppColors.error : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Status indicator
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isOnSchedule ? Icons.check_circle_outline : Icons.warning_amber,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isOnSchedule ? 'В графике' : 'Отставание от плана',
                    style: AppTypography.bodyMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isOnSchedule && _daysRemaining > 0)
                  Text(
                    'Нужно ${_neededPerDay.toStringAsFixed(1)} шт/день',
                    style: AppTypography.bodySmall.copyWith(
                      color: statusColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
