import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Subscription info card widget
class SubscriptionCard extends StatelessWidget {
  final String planName;
  final String status;
  final DateTime? expiresAt;
  final int currentClients;
  final int clientLimit;
  final int currentEmployees;
  final int employeeLimit;
  final VoidCallback onUpgrade;

  const SubscriptionCard({
    super.key,
    required this.planName,
    required this.status,
    this.expiresAt,
    required this.currentClients,
    required this.clientLimit,
    required this.currentEmployees,
    required this.employeeLimit,
    required this.onUpgrade,
  });

  String get _statusText {
    switch (status) {
      case 'active':
        return 'Активна';
      case 'trial':
        return 'Пробный период';
      case 'expired':
        return 'Истекла';
      default:
        return 'Бесплатный план';
    }
  }

  Color get _statusColor {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'trial':
        return AppColors.warning;
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _planIcon {
    switch (planName.toLowerCase()) {
      case 'max':
        return Icons.rocket_launch;
      case 'ultra':
        return Icons.bolt;
      case 'pro':
        return Icons.workspace_premium;
      default:
        return Icons.star_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlimitedClients = clientLimit == 0;
    final isUnlimitedEmployees = employeeLimit == 0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _planIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _statusText,
                        style: AppTypography.labelSmall.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (expiresAt != null)
                Text(
                  'до ${expiresAt!.day.toString().padLeft(2, '0')}.${expiresAt!.month.toString().padLeft(2, '0')}.${expiresAt!.year}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Usage stats
          Row(
            children: [
              Expanded(
                child: _UsageStat(
                  label: 'Заказчики',
                  current: currentClients,
                  limit: clientLimit,
                  isUnlimited: isUnlimitedClients,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UsageStat(
                  label: 'Сотрудники',
                  current: currentEmployees,
                  limit: employeeLimit,
                  isUnlimited: isUnlimitedEmployees,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Upgrade button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Управление подпиской'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageStat extends StatelessWidget {
  final String label;
  final int current;
  final int limit;
  final bool isUnlimited;

  const _UsageStat({
    required this.label,
    required this.current,
    required this.limit,
    required this.isUnlimited,
  });

  @override
  Widget build(BuildContext context) {
    final progress = isUnlimited ? 0.3 : (current / limit).clamp(0.0, 1.0);
    final isNearLimit = !isUnlimited && current >= limit * 0.8;
    final color = isNearLimit ? AppColors.warning : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUnlimited ? '$current / ∞' : '$current / $limit',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isNearLimit ? AppColors.warning : context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.borderColor,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
