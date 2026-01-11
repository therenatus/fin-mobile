import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/subscription.dart';
import '../../core/providers/subscription_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const SubscriptionScreen({super.key, this.onMenuPressed});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SubscriptionProvider>();
      if (!provider.isInitialized) {
        provider.init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        leading: widget.onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuPressed,
              )
            : null,
        title: Text(
          'Подписка',
          style: AppTypography.h3.copyWith(
            color: context.textPrimaryColor,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          return RefreshIndicator(
            onRefresh: provider.loadUsage,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentPlanCard(provider.usage),
                  const SizedBox(height: 24),
                  if (provider.usage != null) ...[
                    _buildUsageSection(provider.usage!),
                    const SizedBox(height: 24),
                  ],
                  _buildPlansSection(provider),
                  const SizedBox(height: 16),
                  _buildRestoreButton(provider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(SubscriptionProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'Произошла ошибка',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.init();
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(ResourceUsage? usage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Текущий план',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            usage?.planName ?? 'Free',
            style: AppTypography.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  usage?.statusText ?? 'Бесплатный план',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              if (usage?.expiresAt != null) ...[
                const SizedBox(width: 8),
                Text(
                  'до ${_formatDate(usage!.expiresAt!)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSection(ResourceUsage usage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Использование',
          style: AppTypography.h4.copyWith(
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildUsageBar(
          label: 'Заказчики',
          current: usage.currentClients,
          limit: usage.limits.clientLimit,
          isNearLimit: usage.isNearClientLimit,
          isLimitReached: usage.isClientLimitReached,
        ),
        const SizedBox(height: 12),
        _buildUsageBar(
          label: 'Сотрудники',
          current: usage.currentEmployees,
          limit: usage.limits.employeeLimit,
          isNearLimit: usage.isNearEmployeeLimit,
          isLimitReached: usage.isEmployeeLimitReached,
        ),
      ],
    );
  }

  Widget _buildUsageBar({
    required String label,
    required int current,
    required int limit,
    required bool isNearLimit,
    required bool isLimitReached,
  }) {
    final isUnlimited = limit == 0;
    final progress = isUnlimited ? 0.0 : (current / limit).clamp(0.0, 1.0);
    final color = isLimitReached
        ? AppColors.error
        : isNearLimit
            ? AppColors.warning
            : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: isLimitReached
            ? Border.all(color: AppColors.error.withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textPrimaryColor,
                ),
              ),
              Text(
                isUnlimited ? '$current / неограничено' : '$current / $limit',
                style: AppTypography.bodyMedium.copyWith(
                  color: isLimitReached
                      ? AppColors.error
                      : context.textSecondaryColor,
                  fontWeight: isLimitReached ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: isUnlimited ? 0 : progress,
              backgroundColor: context.borderColor,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          if (isLimitReached) ...[
            const SizedBox(height: 8),
            Text(
              'Лимит достигнут. Обновите план для добавления.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlansSection(SubscriptionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Доступные планы',
          style: AppTypography.h4.copyWith(
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        if (provider.plans.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Планы загружаются...',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
          )
        else
          ...provider.plans.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPlanCard(plan, provider),
              )),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, SubscriptionProvider provider) {
    final isCurrentPlan = provider.usage?.planName == plan.name;
    final price = provider.getPlanPrice(plan);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentPlan
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name,
                          style: AppTypography.h4.copyWith(
                            color: context.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isCurrentPlan) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Активен',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'До ${plan.clientLimitText} заказчиков, ${plan.employeeLimitText} сотрудников',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan || provider.isPurchasing
                  ? null
                  : () => _handlePurchase(provider, plan),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCurrentPlan ? context.borderColor : AppColors.primary,
                foregroundColor: isCurrentPlan
                    ? context.textSecondaryColor
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: provider.isPurchasing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(isCurrentPlan ? 'Текущий план' : 'Выбрать'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton(SubscriptionProvider provider) {
    return Center(
      child: TextButton.icon(
        onPressed: provider.isLoading ? null : provider.restorePurchases,
        icon: const Icon(Icons.restore),
        label: const Text('Восстановить покупки'),
        style: TextButton.styleFrom(
          foregroundColor: context.textSecondaryColor,
        ),
      ),
    );
  }

  Future<void> _handlePurchase(
    SubscriptionProvider provider,
    SubscriptionPlan plan,
  ) async {
    await provider.purchase(plan);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
