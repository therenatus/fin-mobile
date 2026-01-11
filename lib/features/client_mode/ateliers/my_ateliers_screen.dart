import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/client_provider.dart';
import '../../../core/models/client_user.dart';
import 'atelier_detail_screen.dart';

class MyAteliersScreen extends StatefulWidget {
  const MyAteliersScreen({super.key});

  @override
  State<MyAteliersScreen> createState() => _MyAteliersScreenState();
}

class _MyAteliersScreenState extends State<MyAteliersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Мои ателье'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<ClientProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tenants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tenants.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshData(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: provider.tenants.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final tenant = provider.tenants[index];
                return _AtelierCard(
                  tenant: tenant,
                  ordersCount: provider.getOrdersCountForTenant(tenant.tenantId),
                  totalSpent: provider.getTotalSpentForTenant(tenant.tenantId),
                  pendingCount: provider.getPendingOrdersCountForTenant(tenant.tenantId),
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
              'Вы ещё не привязаны к ателье',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Привяжитесь к ателье, чтобы создавать заказы',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Функция скоро будет доступна'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Привязать ателье'),
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
                          label: _ordersLabel(ordersCount),
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

  String _ordersLabel(int count) {
    if (count == 0) return 'Нет заказов';
    if (count == 1) return '1 заказ';
    if (count >= 2 && count <= 4) return '$count заказа';
    return '$count заказов';
  }

  String _formatPrice(double price) {
    if (price == 0) return '0 ₽';
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}М ₽';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}К ₽';
    }
    return '${price.toStringAsFixed(0)} ₽';
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
