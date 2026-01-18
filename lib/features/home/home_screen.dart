import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/haptic_feedback.dart';
import '../../core/utils/page_transitions.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback? onMenuPressed;

  const HomeScreen({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardNotifierProvider.notifier).refreshDashboard(),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, ref),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildWelcomeSection(context, ref),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatsGrid(context, ref),
                  const SizedBox(height: AppSpacing.xl),
                  _buildFinanceSummary(context, ref),
                  const SizedBox(height: AppSpacing.xl),
                  _buildRecentOrders(context, ref),
                  const SizedBox(height: AppSpacing.xl),
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.lg),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: context.surfaceColor,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed,
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.notificationsComingSoon)),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          user?.tenant?.name ?? 'AteliePro',
          style: AppTypography.h4.copyWith(
            color: context.textPrimaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = context.l10n.goodMorning;
    } else if (hour < 18) {
      greeting = context.l10n.goodAfternoon;
    } else {
      greeting = context.l10n.goodEvening;
    }

    final stats = ref.watch(dashboardStatsProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [AppShadows.lg],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting!',
                  style: AppTypography.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.youHaveOrdersInProgress(_formatOrdersCount(context, stats?.activeOrders ?? 0)),
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  String _formatOrdersCount(BuildContext context, int count) {
    return context.l10n.ordersInProgress(count);
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final isLoading = ref.watch(isDashboardLoadingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.l10n.indicators),
        if (isLoading && stats == null)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
            children: const [
              ShimmerStatCard(),
              ShimmerStatCard(),
              ShimmerStatCard(),
              ShimmerStatCard(),
            ],
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
            children: [
              StaggeredListItem(
                index: 0,
                child: StatCard(
                  title: context.l10n.activeOrders,
                  value: '${stats?.activeOrders ?? 0}',
                  icon: Icons.receipt_long,
                  iconColor: AppColors.primary,
                ),
              ),
              StaggeredListItem(
                index: 1,
                child: StatCard(
                  title: context.l10n.customers,
                  value: '${stats?.totalClients ?? 0}',
                  icon: Icons.people,
                  iconColor: AppColors.secondary,
                ),
              ),
              StaggeredListItem(
                index: 2,
                child: StatCard(
                  title: context.l10n.monthlyIncome,
                  value: _formatCurrency(stats?.monthlyRevenue ?? 0),
                  icon: Icons.account_balance_wallet,
                  iconColor: AppColors.warning,
                ),
              ),
              StaggeredListItem(
                index: 3,
                child: StatCard(
                  title: context.l10n.overdue,
                  value: '${stats?.overdueOrders ?? 0}',
                  icon: Icons.warning_amber,
                  iconColor: AppColors.error,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₽';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₽';
    }
    return '${amount.toStringAsFixed(0)} ₽';
  }

  Widget _buildFinanceSummary(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeReportProvider);
    final isLoading = ref.watch(isDashboardLoadingProvider);

    if (isLoading && finance == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: context.l10n.monthlyFinance),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.borderColor),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    final income = finance?.totalIncome ?? 0;
    final expense = finance?.totalExpense ?? 0;
    final profit = finance?.profit ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.l10n.monthlyFinance),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.borderColor),
            boxShadow: context.cardShadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _FinanceItem(
                      icon: Icons.arrow_upward,
                      label: context.l10n.income,
                      value: income,
                      color: AppColors.success,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: context.borderColor,
                  ),
                  Expanded(
                    child: _FinanceItem(
                      icon: Icons.arrow_downward,
                      label: context.l10n.expenses,
                      value: expense,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: profit >= 0
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      profit >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: profit >= 0 ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${context.l10n.profit}: ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###', 'ru').format(profit)} ₽',
                      style: AppTypography.h4.copyWith(
                        color: profit >= 0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(recentOrdersProvider);
    final isLoading = ref.watch(isDashboardLoadingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.recentOrders,
          actionLabel: context.l10n.all,
          onAction: () {
            // Navigate to orders tab
          },
        ),
        if (isLoading && orders.isEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, __) => const ShimmerOrderCard(),
          )
        else if (orders.isEmpty)
          AnimatedEmptyState(
            icon: Icons.receipt_long_outlined,
            title: context.l10n.noOrders,
            subtitle: context.l10n.ordersWillAppearHere,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length.clamp(0, 3),
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              return StaggeredListItem(
                index: index,
                child: OrderCard(
                  order: orders[index],
                  onTap: () {
                    // Navigate to order details
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.l10n.quickActions),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_outline,
                label: context.l10n.newOrder,
                color: AppColors.primary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.orderCreationComingSoon)),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.person_add_outlined,
                label: context.l10n.newCustomer,
                color: AppColors.secondary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.customerAdditionComingSoon)),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        AppHaptics.mediumTap();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.borderColor),
            boxShadow: context.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const _FinanceItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${NumberFormat('#,###', 'ru').format(value)} ₽',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
