import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/client_user.dart';
import 'client_edit_order_screen.dart';

class ClientOrderDetailScreen extends ConsumerStatefulWidget {
  final ClientOrder order;

  const ClientOrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<ClientOrderDetailScreen> createState() => _ClientOrderDetailScreenState();
}

class _ClientOrderDetailScreenState extends ConsumerState<ClientOrderDetailScreen> {
  bool _isCancelling = false;

  ClientOrder get order => widget.order;
  bool get canEdit => order.status == 'pending';

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить заказ?'),
        content: const Text('Вы уверены, что хотите отменить этот заказ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Да, отменить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);

    try {
      await ref.read(clientAuthNotifierProvider.notifier).cancelOrder(order.id);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заказ отменён'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  void _editOrder() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ClientEditOrderScreen(order: order),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Детали заказа'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editOrder,
              tooltip: 'Изменить',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Model info card
          _buildModelCard(),
          const SizedBox(height: AppSpacing.md),

          // Status notice for pending
          if (canEdit) ...[
            _buildPendingNotice(),
            const SizedBox(height: AppSpacing.md),
          ],

          // Info section
          _buildInfoSection(),
          const SizedBox(height: AppSpacing.md),

          // Cost section
          _buildCostSection(),

          // Actions
          if (canEdit) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildActionButtons(),
          ],

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildModelCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Model image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.surfaceVariantColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: order.model.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.network(
                        order.model.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.checkroom,
                          size: 40,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.checkroom,
                      size: 40,
                      color: context.textSecondaryColor,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.model.name,
                    style: AppTypography.h4,
                  ),
                  if (order.model.category != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      order.model.category!,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _StatusBadge(status: order.status, label: order.statusLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Заказ ожидает принятия. Вы можете изменить или отменить его.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _DetailRow(
              icon: Icons.store,
              label: 'Ателье',
              value: order.tenantName,
            ),
            const Divider(height: 24),
            _DetailRow(
              icon: Icons.inventory_2,
              label: 'Количество',
              value: '${order.quantity} шт.',
            ),
            if (order.dueDate != null) ...[
              const Divider(height: 24),
              _DetailRow(
                icon: Icons.event,
                label: 'Срок готовности',
                value: _formatDate(order.dueDate!),
              ),
            ],
            const Divider(height: 24),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Дата создания',
              value: _formatDate(order.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSection() {
    if (order.model.basePrice == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Стоимость',
            style: AppTypography.labelLarge.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.model.basePrice!.toStringAsFixed(0)} ₽ × ${order.quantity} шт.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${order.totalCost.toStringAsFixed(0)} ₽',
                style: AppTypography.h3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isCancelling ? null : _cancelOrder,
            icon: _isCancelling
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined),
            label: const Text('Отменить'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _editOrder,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Изменить'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.textSecondaryColor),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        break;
      case 'in_progress':
        color = AppColors.info;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = context.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
