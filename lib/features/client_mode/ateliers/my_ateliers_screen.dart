import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/client_user.dart';
import 'atelier_detail_screen.dart';

class MyAteliersScreen extends ConsumerStatefulWidget {
  const MyAteliersScreen({super.key});

  @override
  ConsumerState<MyAteliersScreen> createState() => _MyAteliersScreenState();
}

class _MyAteliersScreenState extends ConsumerState<MyAteliersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientAuthNotifierProvider.notifier).refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(clientAuthNotifierProvider);
    final notifier = ref.read(clientAuthNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.myAteliers),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Builder(
        builder: (context) {
          if (authState.isLoading && authState.tenants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authState.tenants.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => notifier.refreshData(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: authState.tenants.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final tenant = authState.tenants[index];
                return _AtelierCard(
                  tenant: tenant,
                  ordersCount: authState.getOrdersCountForTenant(tenant.tenantId),
                  totalSpent: authState.getTotalSpentForTenant(tenant.tenantId),
                  pendingCount: authState.getPendingOrdersCountForTenant(tenant.tenantId),
                  onTap: () => _openAtelierDetail(tenant),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 80,
              color: context.textSecondaryColor,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.notLinkedToAtelier,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.linkToAtelierHint,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.featureComingSoon),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(context.l10n.linkAtelier),
            ),
          ],
        ),
      ),
    );
  }

  void _openAtelierDetail(TenantLink tenant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AtelierDetailScreen(tenant: tenant),
      ),
    );
  }
}

class _AtelierCard extends StatelessWidget {
  final TenantLink tenant;
  final int ordersCount;
  final double totalSpent;
  final int pendingCount;
  final VoidCallback onTap;

  const _AtelierCard({
    required this.tenant,
    required this.ordersCount,
    required this.totalSpent,
    required this.pendingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Atelier icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.store,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.tenantName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (tenant.tenantDomain != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        tenant.tenantDomain!,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.receipt_long,
                          label: _ordersLabel(context, ordersCount),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatChip(
                          icon: Icons.payments,
                          label: _formatPrice(totalSpent),
                        ),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _StatChip(
                            icon: Icons.hourglass_empty,
                            label: '$pendingCount',
                            color: AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ordersLabel(BuildContext context, int count) {
    if (count == 0) return context.l10n.noOrdersLabel;
    if (count == 1) return context.l10n.oneOrder;
    if (count >= 2 && count <= 4) return context.l10n.fewOrders(count);
    return context.l10n.manyOrders(count);
  }

  String _formatPrice(double price) {
    if (price == 0) return '0 сом';
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}М сом';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}К сом';
    }
    return '${price.toStringAsFixed(0)} сом';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _StatChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? context.textSecondaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? context.surfaceVariantColor).withOpacity(color != null ? 0.15 : 1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}
