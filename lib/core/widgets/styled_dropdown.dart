import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DropdownOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const DropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });
}

class StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: context.surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
      ),
      dropdownColor: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      isExpanded: true,
      items: options.map((option) {
        return DropdownMenuItem<T>(
          value: option.value,
          child: Row(
            children: [
              if (option.icon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (option.iconColor ?? AppColors.primary).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    option.icon,
                    size: 18,
                    color: option.iconColor ?? AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  option.label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      selectedItemBuilder: (context) {
        return options.map((option) {
          return Row(
            children: [
              if (option.icon != null) ...[
                Icon(
                  option.icon,
                  size: 18,
                  color: option.iconColor ?? AppColors.primary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                option.label,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          );
        }).toList();
      },
      onChanged: onChanged,
    );
  }
}

/// Роли исполнителей с иконками
class ExecutorRoleDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const ExecutorRoleDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const List<DropdownOption<String>> roles = [
    DropdownOption(
      value: 'tailor',
      label: 'Портной',
      icon: Icons.content_cut,
      iconColor: AppColors.primary,
    ),
    DropdownOption(
      value: 'designer',
      label: 'Дизайнер',
      icon: Icons.design_services,
      iconColor: Colors.purple,
    ),
    DropdownOption(
      value: 'cutter',
      label: 'Раскройщик',
      icon: Icons.carpenter,
      iconColor: Colors.orange,
    ),
    DropdownOption(
      value: 'seamstress',
      label: 'Швея',
      icon: Icons.checkroom,
      iconColor: Colors.pink,
    ),
    DropdownOption(
      value: 'finisher',
      label: 'Отделочник',
      icon: Icons.auto_fix_high,
      iconColor: Colors.teal,
    ),
    DropdownOption(
      value: 'presser',
      label: 'Гладильщик',
      icon: Icons.iron,
      iconColor: Colors.brown,
    ),
    DropdownOption(
      value: 'quality',
      label: 'ОТК',
      icon: Icons.verified,
      iconColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StyledDropdown<String>(
      value: value,
      options: roles,
      onChanged: onChanged,
      label: 'Исполнитель *',
      prefixIcon: Icons.person_outline,
    );
  }
}

/// Категории моделей — горизонтальные чипсы с иконками
class CategoryDropdown extends StatelessWidget {
  final String? value;
  final List<String> categories;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.value,
    required this.categories,
    required this.onChanged,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'платье':
        return Icons.checkroom;
      case 'костюм':
      case 'костюмы':
        return Icons.business_center;
      case 'брюки':
        return Icons.straighten;
      case 'рубашка':
        return Icons.dry_cleaning;
      case 'юбка':
        return Icons.woman;
      case 'пальто':
        return Icons.severe_cold;
      default:
        return Icons.style;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'платье':
        return Colors.pink;
      case 'костюм':
      case 'костюмы':
        return Colors.indigo;
      case 'брюки':
        return Colors.brown;
      case 'рубашка':
        return Colors.blue;
      case 'юбка':
        return Colors.purple;
      case 'пальто':
        return Colors.blueGrey;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = value == category;
        final color = _getCategoryColor(category);
        final icon = _getCategoryIcon(category);

        return ChoiceChip(
          label: Text(category),
          avatar: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : color,
          ),
          selected: isSelected,
          onSelected: (selected) {
            onChanged(selected ? category : null);
          },
          selectedColor: color,
          backgroundColor: context.surfaceColor,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : context.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            side: BorderSide(
              color: isSelected ? color : context.borderColor,
            ),
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        );
      }).toList(),
    );
  }
}
