import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/app_provider.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee; // null for create, not null for edit

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedRoleCode;
  bool _isSubmitting = false;

  bool get isEditMode => widget.employee != null;

  ApiService get _api => context.read<AppProvider>().api;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _selectedRoleCode = widget.employee!.role;
      _phoneController.text = widget.employee!.phone ?? '';
      _emailController.text = widget.employee!.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoleCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите роль сотрудника'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (isEditMode) {
        await _api.updateEmployee(
          id: widget.employee!.id,
          name: _nameController.text.trim(),
          role: _selectedRoleCode!,
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
        );
      } else {
        await _api.createEmployee(
          name: _nameController.text.trim(),
          role: _selectedRoleCode!,
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Сотрудник обновлён' : 'Сотрудник добавлен'),
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
        title: Text(isEditMode ? 'Редактировать' : 'Новый сотрудник'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Name
            _buildSectionTitle('Имя *'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                hint: 'Иван Петров',
                icon: Icons.person_outlined,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите имя сотрудника';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Role
            _buildSectionTitle('Роль *'),
            const SizedBox(height: AppSpacing.sm),
            Consumer<AppProvider>(
              builder: (context, provider, _) {
                final roles = provider.employeeRoles;
                return DropdownButtonFormField<String>(
                  value: _selectedRoleCode,
                  decoration: _inputDecoration(
                    hint: 'Выберите роль',
                    icon: Icons.work_outline,
                  ),
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role.code,
                      child: Text(role.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleCode = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Выберите роль';
                    }
                    return null;
                  },
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Phone
            _buildSectionTitle('Телефон'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _phoneController,
              decoration: _inputDecoration(
                hint: '+7 999 123-45-67',
                icon: Icons.phone_outlined,
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Email
            _buildSectionTitle('Email'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration(
                hint: 'employee@mail.ru',
                icon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return 'Некорректный email';
                }
                return null;
              },
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
                    : Text(isEditMode ? 'Сохранить' : 'Добавить сотрудника'),
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
