import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/models/models.dart';

/// Card displaying client information in order detail
class ClientSectionCard extends StatelessWidget {
  final Client? client;

  const ClientSectionCard({super.key, this.client});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Заказчик',
      icon: Icons.person_outline,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            radius: 24,
            child: Text(
              (client?.name.isNotEmpty == true
                  ? client!.name.substring(0, 1).toUpperCase()
                  : '?'),
              style: AppTypography.h4.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client?.name ?? 'Неизвестный заказчик',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (client?.contacts.phone != null)
                  Text(
                    client!.contacts.phone!,
                    style: AppTypography.bodyMedium.copyWith(
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
}
