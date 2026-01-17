import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/materials_provider.dart';
import '../../core/models/material.dart' as mat;
import '../../core/widgets/stock_indicator.dart';

class StockAdjustmentScreen extends StatefulWidget {
  final mat.Material material;

  const StockAdjustmentScreen({
    super.key,
    required this.material,
  });

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isIncrease = true;
  bool _isSubmitting = false;

  double get _adjustmentQuantity {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    return _isIncrease ? qty : -qty;
  }

  double get _resultQuantity {
    return widget.material.quantity + _adjustmentQuantity;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<MaterialsProvider>();
      final updated = await provider.adjustStock(
        widget.material.id,
        quantity: _adjustmentQuantity,
        reason: _reasonController.text.isNotEmpty
            ? _reasonController.text
            : (_isIncrease ? 'Приход' : 'Списание'),
      );

      if (updated != null && mounted) {
        Navigator.pop(context, updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isIncrease
                  ? 'Добавлено: ${_quantityController.text} ${widget.material.unit.label}'
                  : 'Списано: ${_quantityController.text} ${widget.material.unit.label}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Корректировка остатка'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Material info card
              _buildMaterialCard(),
              const SizedBox(height: AppSpacing.lg),

              // Adjustment type selector
              _buildTypeSelector(),
              const SizedBox(height: AppSpacing.lg),

              // Quantity input
              _buildQuantityInput(),
              const SizedBox(height: AppSpacing.md),

              // Result preview
              _buildResultPreview(),
              const SizedBox(height: AppSpacing.lg),

              // Reason input
              _buildReasonInput(),
              const SizedBox(height: AppSpacing.xl),

              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.surfaceVariantColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.material.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${widget.material.sku}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StockIndicator(
                quantity: widget.material.quantity,
                minStockLevel: widget.material.minStockLevel,
              ),
              const SizedBox(height: 4),
              Text(
                widget.material.formattedQuantity,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              icon: Icons.add_circle_outline,
              label: 'Приход',
              color: AppColors.success,
              isSelected: _isIncrease,
              onTap: () => setState(() => _isIncrease = true),
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: context.borderColor,
          ),
          Expanded(
            child: _buildTypeOption(
              icon: Icons.remove_circle_outline,
              label: 'Списание',
              color: AppColors.error,
              isSelected: !_isIncrease,
              onTap: () => setState(() => _isIncrease = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : context.textSecondaryColor,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? color : context.textSecondaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Количество',
            style: AppTypography.labelMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTypography.h2,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTypography.h2.copyWith(
                color: context.textSecondaryColor.withOpacity(0.5),
              ),
              suffixText: widget.material.unit.label,
              suffixStyle: AppTypography.h3.copyWith(
                color: context.textSecondaryColor,
              ),
              filled: true,
              fillColor: context.surfaceVariantColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите количество';
              }
              final qty = double.tryParse(value);
              if (qty == null || qty <= 0) {
                return 'Введите корректное число';
              }
              if (!_isIncrease && qty > widget.material.computedAvailableQty) {
                return 'Недостаточно на складе (доступно: ${widget.material.computedAvailableQty.toStringAsFixed(1)})';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultPreview() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    if (qty <= 0) return const SizedBox.shrink();

    final resultQty = _resultQuantity;
    final isValid = resultQty >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (isValid ? AppColors.primary : AppColors.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.material.quantity.toStringAsFixed(1)}',
            style: AppTypography.bodyLarge.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            _isIncrease ? Icons.add : Icons.remove,
            size: 20,
            color: _isIncrease ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            qty.toStringAsFixed(1),
            style: AppTypography.bodyLarge.copyWith(
              color: _isIncrease ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 8),
          const Text('='),
          const SizedBox(width: 8),
          Text(
            '${resultQty.toStringAsFixed(1)} ${widget.material.unit.label}',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: isValid ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Причина',
            style: AppTypography.labelMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: _isIncrease
                  ? 'Например: Поступление от поставщика'
                  : 'Например: Брак, использование в заказе',
              filled: true,
              fillColor: context.surfaceVariantColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _submit,
        style: FilledButton.styleFrom(
          backgroundColor: _isIncrease ? AppColors.success : AppColors.error,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isIncrease ? 'Добавить на склад' : 'Списать со склада',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
