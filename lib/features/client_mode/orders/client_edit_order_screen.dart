import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/client_provider.dart';
import '../../../core/models/client_user.dart';

class ClientEditOrderScreen extends StatefulWidget {
  final ClientOrder order;

  const ClientEditOrderScreen({super.key, required this.order});

  @override
  State<ClientEditOrderScreen> createState() => _ClientEditOrderScreenState();
}

class _ClientEditOrderScreenState extends State<ClientEditOrderScreen> {
  late int _quantity;
  DateTime? _dueDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.order.quantity;
    _dueDate = widget.order.dueDate;
  }

  Future<void> _updateOrder() async {
    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<ClientProvider>();
      await provider.updateOrder(
        orderId: widget.order.id,
        quantity: _quantity,
        dueDate: _dueDate?.toIso8601String(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заказ обновлён'),
            backgroundColor: Colors.green,
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Изменить заказ'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Order info (readonly)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: context.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: order.model.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Image.network(
                            order.model.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.checkroom,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        )
                      : Icon(Icons.checkroom, color: context.textSecondaryColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.model.name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        order.tenantName,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quantity
          _buildSectionTitle('Количество'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                Text('$_quantity', style: AppTypography.h3),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                ),
                const Spacer(),
                Text(
                  'шт.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Due date
          _buildSectionTitle('Желаемая дата готовности'),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                locale: const Locale('ru'),
              );
              if (date != null) {
                setState(() => _dueDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: context.textSecondaryColor),
                  const SizedBox(width: 12),
                  Text(
                    _dueDate != null
                        ? '${_dueDate!.day.toString().padLeft(2, '0')}.${_dueDate!.month.toString().padLeft(2, '0')}.${_dueDate!.year}'
                        : 'Не указана',
                    style: AppTypography.bodyLarge,
                  ),
                  const Spacer(),
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Summary
          if (order.model.basePrice != null) ...[
            _buildSectionTitle('Итого'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.model.name} × $_quantity',
                    style: AppTypography.bodyMedium,
                  ),
                  Text(
                    '${(order.model.basePrice! * _quantity).toStringAsFixed(0)} ₽',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Submit button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _updateOrder,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Сохранить изменения'),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        color: context.textSecondaryColor,
      ),
    );
  }
}
