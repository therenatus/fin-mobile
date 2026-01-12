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
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Custom App Bar with gradient
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                leading: widget.onMenuPressed != null
                    ? IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: widget.onMenuPressed,
                      )
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderBackground(provider.usage),
                ),
                backgroundColor: AppColors.primary,
              ),

              // Content
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  onRefresh: provider.loadUsage,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderBackground(ResourceUsage? usage) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
            const Color(0xFF6366F1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getPlanIcon(usage?.planName),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Текущий план',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatusChip(usage?.statusText ?? 'Бесплатный план'),
                  if (usage?.expiresAt != null) ...[
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      'до ${_formatDate(usage!.expiresAt!)}',
                      isSecondary: true,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, {bool isSecondary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSecondary
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getPlanIcon(String? planName) {
    if (planName == null) return Icons.card_giftcard_rounded;
    final name = planName.toLowerCase();
    if (name.contains('pro') || name.contains('premium')) {
      return Icons.workspace_premium_rounded;
    } else if (name.contains('business') || name.contains('enterprise')) {
      return Icons.diamond_rounded;
    } else if (name.contains('starter') || name.contains('basic')) {
      return Icons.star_rounded;
    }
    return Icons.card_giftcard_rounded;
  }

  Widget _buildErrorState(SubscriptionProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Что-то пошло не так',
              style: AppTypography.h4.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Произошла ошибка',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                provider.init();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSection(ResourceUsage usage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 20,
              color: context.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Использование ресурсов',
              style: AppTypography.h4.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildUsageCard(
                icon: Icons.people_alt_rounded,
                label: 'Заказчики',
                current: usage.currentClients,
                limit: usage.limits.clientLimit,
                isNearLimit: usage.isNearClientLimit,
                isLimitReached: usage.isClientLimitReached,
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUsageCard(
                icon: Icons.badge_rounded,
                label: 'Сотрудники',
                current: usage.currentEmployees,
                limit: usage.limits.employeeLimit,
                isNearLimit: usage.isNearEmployeeLimit,
                isLimitReached: usage.isEmployeeLimitReached,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageCard({
    required IconData icon,
    required String label,
    required int current,
    required int limit,
    required bool isNearLimit,
    required bool isLimitReached,
    required Color color,
  }) {
    final isUnlimited = limit == 0;
    final progress = isUnlimited ? 0.0 : (current / limit).clamp(0.0, 1.0);
    final statusColor = isLimitReached
        ? AppColors.error
        : isNearLimit
            ? AppColors.warning
            : color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLimitReached
              ? AppColors.error.withValues(alpha: 0.5)
              : context.borderColor,
          width: isLimitReached ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: statusColor),
              ),
              const Spacer(),
              if (isLimitReached)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'MAX',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUnlimited ? '$current' : '$current / $limit',
            style: AppTypography.h4.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: isUnlimited ? 0 : progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          if (isUnlimited) ...[
            const SizedBox(height: 8),
            Text(
              'Безлимит',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
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
        Row(
          children: [
            Icon(
              Icons.style_rounded,
              size: 20,
              color: context.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Доступные планы',
              style: AppTypography.h4.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.plans.isEmpty)
          _buildEmptyPlans()
        else
          ...provider.plans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            final isPopular = index == 1 && provider.plans.length > 2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPlanCard(plan, provider, isPopular: isPopular),
            );
          }),
      ],
    );
  }

  Widget _buildEmptyPlans() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 48,
            color: context.textTertiaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Загрузка планов...',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    SubscriptionPlan plan,
    SubscriptionProvider provider, {
    bool isPopular = false,
  }) {
    final isCurrentPlan = provider.usage?.planName == plan.name;
    final price = provider.getPlanPrice(plan);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrentPlan
                  ? AppColors.primary
                  : isPopular
                      ? const Color(0xFF8B5CF6)
                      : context.borderColor,
              width: isCurrentPlan || isPopular ? 2 : 1,
            ),
            boxShadow: [
              if (isPopular || isCurrentPlan)
                BoxShadow(
                  color: (isCurrentPlan
                          ? AppColors.primary
                          : const Color(0xFF8B5CF6))
                      .withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isCurrentPlan
                              ? AppColors.primary
                              : isPopular
                                  ? const Color(0xFF8B5CF6)
                                  : context.textTertiaryColor)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getPlanIcon(plan.name),
                      color: isCurrentPlan
                          ? AppColors.primary
                          : isPopular
                              ? const Color(0xFF8B5CF6)
                              : context.textSecondaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Активен',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
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
                            color: isPopular
                                ? const Color(0xFF8B5CF6)
                                : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildLimitItem(
                        Icons.people_outline_rounded,
                        plan.clientLimitText,
                        'заказчиков',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: context.borderColor,
                    ),
                    Expanded(
                      child: _buildLimitItem(
                        Icons.badge_outlined,
                        plan.employeeLimitText,
                        'сотрудников',
                      ),
                    ),
                  ],
                ),
              ),
              if (plan.features.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...plan.features.take(4).map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 10),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isCurrentPlan || provider.isPurchasing
                      ? null
                      : () => _handlePurchase(provider, plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentPlan
                        ? context.borderColor
                        : isPopular
                            ? const Color(0xFF8B5CF6)
                            : AppColors.primary,
                    foregroundColor: isCurrentPlan
                        ? context.textSecondaryColor
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      : Text(
                          isCurrentPlan ? 'Текущий план' : 'Выбрать план',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: -10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Популярный',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLimitItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: context.textSecondaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.textTertiaryColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRestoreButton(SubscriptionProvider provider) {
    return Center(
      child: TextButton.icon(
        onPressed: provider.isLoading ? null : provider.restorePurchases,
        icon: Icon(
          Icons.restore_rounded,
          size: 18,
          color: context.textSecondaryColor,
        ),
        label: Text(
          'Восстановить покупки',
          style: TextStyle(color: context.textSecondaryColor),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
