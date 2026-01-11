import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/order.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/widgets/styled_dropdown.dart';
import '../../core/widgets/image_picker_widget.dart';

class ModelFormScreen extends StatefulWidget {
  final OrderModel? model; // null for create, not null for edit

  const ModelFormScreen({super.key, this.model});

  @override
  State<ModelFormScreen> createState() => _ModelFormScreenState();
}

class _ModelFormScreenState extends State<ModelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool _isSubmitting = false;
  File? _selectedImage;
  bool _imageRemoved = false;

  List<String> _categories = [
    'Платье',
    'Костюм',
    'Костюмы',
    'Брюки',
    'Рубашка',
    'Юбка',
    'Пальто',
    'Другое',
  ];

  bool get isEditMode => widget.model != null;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _nameController.text = widget.model!.name;
      _priceController.text = widget.model!.basePrice.toStringAsFixed(0);
      _descriptionController.text = widget.model!.description ?? '';

      // Handle custom categories that might not be in the predefined list
      final modelCategory = widget.model!.category;
      if (modelCategory != null && !_categories.contains(modelCategory)) {
        _categories = [..._categories, modelCategory];
      }
      _selectedCategory = modelCategory;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final api = ApiService(StorageService());
      final price = double.tryParse(_priceController.text.trim()) ?? 0;

      OrderModel result;
      if (isEditMode) {
        result = await api.updateModel(
          id: widget.model!.id,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          basePrice: price,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
        );
      } else {
        result = await api.createModel(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          basePrice: price,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
        );
      }

      // Handle image upload/delete
      if (_selectedImage != null) {
        await api.uploadModelImage(result.id, _selectedImage!);
      } else if (_imageRemoved && isEditMode && widget.model?.imageUrl != null) {
        await api.deleteModelImage(result.id);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Модель обновлена' : 'Модель добавлена'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
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
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(isEditMode ? 'Редактировать модель' : 'Новая модель'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Image
            Center(
              child: ModelImagePickerWidget(
                currentImageUrl: _imageRemoved ? null : widget.model?.imageUrl,
                size: 150,
                onImageSelected: (file) {
                  setState(() {
                    _selectedImage = file;
                    _imageRemoved = false;
                  });
                },
                onImageRemoved: () {
                  setState(() {
                    _selectedImage = null;
                    _imageRemoved = true;
                  });
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Name
            _buildSectionTitle('Название *'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                hint: 'Платье вечернее',
                icon: Icons.checkroom_outlined,
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название модели';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Category
            _buildSectionTitle('Категория'),
            const SizedBox(height: AppSpacing.sm),
            CategoryDropdown(
              value: _selectedCategory,
              categories: _categories,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Price
            _buildSectionTitle('Базовая цена *'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _priceController,
              decoration: _inputDecoration(
                hint: '5000',
                icon: Icons.attach_money_outlined,
              ).copyWith(
                suffixText: '₽',
                suffixStyle: AppTypography.bodyLarge.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите цену';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Введите корректную цену';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Description
            _buildSectionTitle('Описание'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration(
                hint: 'Дополнительная информация о модели...',
                icon: Icons.description_outlined,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Submit button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEditMode ? 'Сохранить' : 'Добавить модель'),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: context.textTertiaryColor),
      filled: true,
      fillColor: context.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
