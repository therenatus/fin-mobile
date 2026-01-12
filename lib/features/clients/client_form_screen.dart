import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/api_service.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client; // null for create, not null for edit

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  ApiService get _api => context.read<AppProvider>().api;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  bool _isSearchingUser = false;
  Map<String, dynamic>? _foundUser;
  Timer? _debounceTimer;
  String? _searchError;

  bool get isEditMode => widget.client != null;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _emailController.text = widget.client!.contacts.email ?? '';
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String email) {
    if (isEditMode) return;

    _debounceTimer?.cancel();
    setState(() {
      _foundUser = null;
      _searchError = null;
    });

    if (email.isEmpty || !email.contains('@')) return;

    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _isSearchingUser = true);

      try {
        final user = await _api.searchClientUserByEmail(email.trim());

        if (mounted) {
          setState(() {
            _foundUser = user;
            _isSearchingUser = false;
            if (user == null) {
              _searchError = 'Пользователь не найден. Попросите заказчика зарегистрироваться в приложении.';
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearchingUser = false;
            _searchError = 'Ошибка поиска';
          });
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // In create mode, must have found user
    if (!isEditMode && _foundUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала найдите зарегистрированного заказчика по email'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (isEditMode) {
        await _api.updateClient(id: widget.client!.id);
      } else {
        // Create client linked to found ClientUser
        await _api.createClient(
          name: _foundUser!['name'],
          email: _emailController.text.trim(),
        );
      }

      if (mounted) {
        await context.read<AppProvider>().refreshDashboard();
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Заказчик обновлён' : 'Заказчик добавлен'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
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
        title: Text(isEditMode ? 'Редактировать заказчика' : 'Добавить заказчика'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Info banner for create mode
            if (!isEditMode) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Введите email заказчика, который уже зарегистрирован в приложении',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Email search (only for create)
            if (!isEditMode) ...[
              _buildSectionTitle('Email заказчика *'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration(
                  hint: 'client@mail.ru',
                  icon: Icons.email_outlined,
                ).copyWith(
                  suffixIcon: _isSearchingUser
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _foundUser != null
                          ? const Icon(Icons.check_circle, color: AppColors.success)
                          : null,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: _onEmailChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!value.contains('@')) {
                    return 'Некорректный email';
                  }
                  return null;
                },
              ),

              // Search result
              const SizedBox(height: AppSpacing.sm),
              if (_foundUser != null)
                _buildFoundUserCard()
              else if (_searchError != null)
                _buildNotFoundCard(),

              const SizedBox(height: AppSpacing.lg),
            ],

            // Show client name in edit mode
            if (isEditMode) ...[
              _buildSectionTitle('Заказчик'),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        (widget.client!.name.isNotEmpty ? widget.client!.name.substring(0, 1).toUpperCase() : '?'),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.client!.name,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.client!.contacts.email != null)
                          Text(
                            widget.client!.contacts.email!,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Submit button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting || (!isEditMode && _foundUser == null)
                    ? null
                    : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEditMode ? 'Сохранить' : 'Добавить заказчика'),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildFoundUserCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.success.withOpacity(0.2),
            child: Icon(Icons.person, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _foundUser!['name'] ?? 'Заказчик',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  'Зарегистрирован в системе',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _buildNotFoundCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.person_off_outlined, color: AppColors.warning, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Заказчик не найден',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Попросите заказчика сначала зарегистрироваться в приложении',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
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
