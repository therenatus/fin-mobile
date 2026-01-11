import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/analytics.dart';
import '../../core/widgets/widgets.dart';

class AnalyticsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const AnalyticsScreen({super.key, this.onMenuPressed});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final stats = provider.dashboardStats;
        final analytics = provider.analyticsDashboard;
        final selectedPeriod = provider.analyticsPeriod;

        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: AppBar(
            title: const Text('Аналитика'),
            backgroundColor: context.surfaceColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: widget.onMenuPressed,
            ),
            actions: [
              // Period selector
              PopupMenuButton<String>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getPeriodLabel(selectedPeriod),
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  ],
                ),
                onSelected: (value) {
                  provider.setAnalyticsPeriod(value);
                },
                itemBuilder: (context) => [
                  _buildPeriodOption(selectedPeriod, 'week', 'Неделя'),
                  _buildPeriodOption(selectedPeriod, 'month', 'Месяц'),
                  _buildPeriodOption(selectedPeriod, 'quarter', 'Квартал'),
                  _buildPeriodOption(selectedPeriod, 'year', 'Год'),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.refreshDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  _buildSummaryCards(stats),
                  const SizedBox(height: AppSpacing.xl),

                  // Revenue chart
                  _buildRevenueChart(analytics?.charts.revenueByDay ?? []),
                  const SizedBox(height: AppSpacing.xl),

                  // Orders by status
                  _buildOrdersChart(analytics?.charts.ordersByStatus),
                  const SizedBox(height: AppSpacing.xl),

                  // Top clients
                  _buildTopClients(analytics?.topClients ?? []),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildPeriodOption(String selectedPeriod, String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            selectedPeriod == value ? Icons.check : Icons.calendar_today_outlined,
            size: 18,
            color: selectedPeriod == value ? AppColors.primary : context.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: selectedPeriod == value ? AppColors.primary : context.textPrimaryColor,
              fontWeight: selectedPeriod == value ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'week':
        return 'Неделя';
      case 'month':
        return 'Месяц';
      case 'quarter':
        return 'Квартал';
      case 'year':
        return 'Год';
      default:
        return 'Месяц';
    }
  }

  Widget _buildSummaryCards(stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Обзор'),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Выручка',
                value: '${_formatCurrency(stats?.monthlyRevenue ?? 125000)}',
                change: '+12.5%',
                isPositive: true,
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SummaryCard(
                title: 'Заказов',
                value: '${stats?.totalOrders ?? 24}',
                change: '+8.3%',
                isPositive: true,
                icon: Icons.receipt_long,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Средний чек',
                value: '${_formatCurrency(stats?.avgOrderValue ?? 15200)}',
                change: '+5.2%',
                isPositive: true,
                icon: Icons.account_balance_wallet,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SummaryCard(
                title: 'Новых заказчиков',
                value: '${stats?.newClients ?? 8}',
                change: '-2.1%',
                isPositive: false,
                icon: Icons.person_add,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueChart(List<RevenueDataPoint> revenueData) {
    // If no data, show placeholder
    if (revenueData.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Выручка'),
          Container(
            height: 250,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [AppShadows.sm],
            ),
            child: Center(
              child: Text(
                'Нет данных о выручке',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Calculate chart parameters
    final maxAmount = revenueData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final double maxY = maxAmount > 0 ? (maxAmount * 1.2).ceilToDouble() : 100000.0;
    final interval = maxY / 4;

    // Create spots from data (show last 7 points for week, etc.)
    final displayData = revenueData.length > 7
        ? revenueData.sublist(revenueData.length - 7)
        : revenueData;

    final spots = displayData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Выручка'),
        Container(
          height: 250,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [AppShadows.sm],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval > 0 ? interval : 25000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: context.borderColor,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < displayData.length) {
                        // Show short date label
                        final date = displayData[index].date;
                        final parts = date.split('-');
                        if (parts.length >= 3) {
                          return Text(
                            '${parts[2]}/${parts[1]}',
                            style: AppTypography.labelSmall.copyWith(
                              color: context.textTertiaryColor,
                              fontSize: 9,
                            ),
                          );
                        }
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    interval: interval > 0 ? interval : 25000,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value / 1000).toInt()}K',
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textTertiaryColor,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (displayData.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersChart(OrdersByStatus? ordersByStatus) {
    final pending = ordersByStatus?.pending ?? 0;
    final inProgress = ordersByStatus?.inProgress ?? 0;
    final completed = ordersByStatus?.completed ?? 0;
    final cancelled = ordersByStatus?.cancelled ?? 0;
    final total = pending + inProgress + completed + cancelled;

    // Calculate percentages
    String getPercentage(int value) {
      if (total == 0) return '0%';
      return '${((value / total) * 100).toStringAsFixed(1)}%';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Заказы по статусу'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [AppShadows.sm],
          ),
          child: total == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Нет данных о заказах',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    // Pie chart
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            if (inProgress > 0)
                              PieChartSectionData(
                                value: inProgress.toDouble(),
                                color: AppColors.info,
                                radius: 20,
                                showTitle: false,
                              ),
                            if (completed > 0)
                              PieChartSectionData(
                                value: completed.toDouble(),
                                color: AppColors.success,
                                radius: 20,
                                showTitle: false,
                              ),
                            if (pending > 0)
                              PieChartSectionData(
                                value: pending.toDouble(),
                                color: AppColors.warning,
                                radius: 20,
                                showTitle: false,
                              ),
                            if (cancelled > 0)
                              PieChartSectionData(
                                value: cancelled.toDouble(),
                                color: AppColors.error,
                                radius: 20,
                                showTitle: false,
                              ),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    // Legend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendItem(
                            color: AppColors.info,
                            label: 'В работе',
                            value: getPercentage(inProgress),
                          ),
                          const SizedBox(height: 8),
                          _LegendItem(
                            color: AppColors.success,
                            label: 'Выполнено',
                            value: getPercentage(completed),
                          ),
                          const SizedBox(height: 8),
                          _LegendItem(
                            color: AppColors.warning,
                            label: 'Ожидают',
                            value: getPercentage(pending),
                          ),
                          const SizedBox(height: 8),
                          _LegendItem(
                            color: AppColors.error,
                            label: 'Отменено',
                            value: getPercentage(cancelled),
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

  Widget _buildTopClients(List<TopClient> topClients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Топ заказчики'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [AppShadows.sm],
          ),
          child: topClients.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Нет данных о заказчиках',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              )
            : Column(
                children: topClients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final client = entry.value;
                  return Column(
                    children: [
                      _TopClientItem(
                        rank: index + 1,
                        name: client.name,
                        orders: client.ordersCount,
                        spent: client.totalSpent,
                      ),
                      if (index < topClients.length - 1)
                        const Divider(height: AppSpacing.md),
                    ],
                  );
                }).toList(),
              ),
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
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [AppShadows.sm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: AppTypography.labelSmall.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.h4.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TopClientItem extends StatelessWidget {
  final int rank;
  final String name;
  final int orders;
  final double spent;

  const _TopClientItem({
    required this.rank,
    required this.name,
    required this.orders,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Rank badge
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _getRankColor(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$orders заказов',
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        // Amount
        Text(
          _formatCurrency(spent),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(BuildContext context) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return context.textTertiaryColor;
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₽';
    }
    return '${amount.toStringAsFixed(0)} ₽';
  }
}
