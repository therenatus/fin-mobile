import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';

/// Dialog for selecting which models to assign to a client
class ModelAssignmentDialog extends ConsumerStatefulWidget {
  final String clientId;
  final List<String> assignedModelIds;

  const ModelAssignmentDialog({
    super.key,
    required this.clientId,
    required this.assignedModelIds,
  });

  @override
  ConsumerState<ModelAssignmentDialog> createState() => _ModelAssignmentDialogState();
}

class _ModelAssignmentDialogState extends ConsumerState<ModelAssignmentDialog> {
  List<OrderModel> _allModels = [];
  Set<String> _selectedModelIds = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _selectedModelIds = Set.from(widget.assignedModelIds);
      Future.microtask(() => _loadModels());
    }
  }

  Future<void> _loadModels() async {
    try {
      final api = ref.read(apiServiceProvider);
      final models = await api.getModels();
      if (mounted) {
        setState(() {
          _allModels = models;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить модели';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAssignments() async {
    setState(() => _isSaving = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.setClientAssignedModels(widget.clientId, _selectedModelIds.toList());
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const Icon(Icons.checkroom, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.l10n.availableModels,
                      style: AppTypography.h4.copyWith(
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Info text
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                context.l10n.selectModelsHint,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),

            // Content
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            context.l10n.couldNotLoadModels,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        )
                      : _allModels.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Text(
                                  context.l10n.noAvailableModels,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              itemCount: _allModels.length,
                              itemBuilder: (context, index) {
                                final model = _allModels[index];
                                final isSelected = _selectedModelIds.contains(model.id);
                                return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedModelIds.add(model.id);
                                      } else {
                                        _selectedModelIds.remove(model.id);
                                      }
                                    });
                                  },
                                  title: Text(
                                    model.name,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      if (model.category != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(25),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            model.category!,
                                            style: AppTypography.labelSmall.copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        '${model.basePrice.toStringAsFixed(0)} сом',
                                        style: AppTypography.labelMedium.copyWith(
                                          color: context.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  secondary: Icon(
                                    Icons.checkroom_outlined,
                                    color: isSelected
                                        ? AppColors.primary
                                        : context.textTertiaryColor,
                                  ),
                                  activeColor: AppColors.primary,
                                  checkColor: Colors.white,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                );
                              },
                            ),
            ),

            const Divider(height: 1),

            // Actions
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAssignments,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _selectedModelIds.isEmpty
                                  ? context.l10n.reset
                                  : context.l10n.saveWithCount(_selectedModelIds.length),
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
