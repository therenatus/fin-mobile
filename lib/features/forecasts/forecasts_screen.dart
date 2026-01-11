import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/app_drawer.dart';

class ForecastsScreen extends StatefulWidget {
  const ForecastsScreen({super.key});

  @override
  State<ForecastsScreen> createState() => _ForecastsScreenState();
}

class _ForecastsScreenState extends State<ForecastsScreen> {
  late final ApiService _api;

  bool _isLoading = true;
  String? _error;
  String? _limitError;

  Forecast? _ordersForecast;
  Forecast? _revenueForecast;
  BusinessInsights? _insights;
  List<MlReport> _reportHistory = [];
  MlUsageInfo? _usageInfo;

  int _selectedDays = 7;
  bool _isGeneratingReport = false;
  String _selectedReportType = 'monthly_summary';

  final List<Map<String, String>> _reportTypes = [
    {'value': 'monthly_summary', 'label': 'Месячный обзор'},
    {'value': 'order_analysis', 'label': 'Анализ заказов'},
    {'value': 'client_insights', 'label': 'Заказчикская аналитика'},
    {'value': 'revenue_forecast', 'label': 'Прогноз выручки'},
    {'value': 'efficiency_report', 'label': 'Эффективность'},
  ];

  @override
  void initState() {
    super.initState();
    _api = ApiService(StorageService());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _limitError = null;
    });

    try {
      // First load usage info
      final usageInfo = await _api.getMlUsageInfo();
      setState(() => _usageInfo = usageInfo);

      // Load report history (doesn't count against limits)
      final reportHistory = await _api.getReportHistory(limit: 5);
      setState(() => _reportHistory = reportHistory);

      // Try to load forecasts and insights (may fail due to limits)
      try {
        final ordersForecast = await _api.getOrdersForecast(days: _selectedDays);
        setState(() => _ordersForecast = ordersForecast);
      } on ApiException catch (e) {
        if (e.statusCode == 403) {
          setState(() => _limitError = 'Достигнут лимит прогнозов');
        }
      }

      try {
        final revenueForecast = await _api.getRevenueForecast(days: _selectedDays);
        setState(() => _revenueForecast = revenueForecast);
      } on ApiException catch (e) {
        if (e.statusCode == 403) {
          setState(() => _limitError = 'Достигнут лимит прогнозов');
        }
      }

      try {
        final insights = await _api.getBusinessInsights();
        setState(() => _insights = insights);
      } on ApiException catch (e) {
        if (e.statusCode == 403) {
          setState(() => _limitError ??= 'Достигнут лимит инсайтов');
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGeneratingReport = true);

    try {
      final now = DateTime.now();
      final monthAgo = now.subtract(const Duration(days: 30));

      await _api.generateMlReport(
        type: _selectedReportType,
        periodStart: monthAgo.toIso8601String(),
        periodEnd: now.toIso8601String(),
      );

      // Refresh report history and usage info
      final results = await Future.wait([
        _api.getReportHistory(limit: 5),
        _api.getMlUsageInfo(),
      ]);
      setState(() {
        _reportHistory = results[0] as List<MlReport>;
        _usageInfo = results[1] as MlUsageInfo;
        _isGeneratingReport = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Отчёт сгенерирован'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() => _isGeneratingReport = false);
      if (mounted) {
        final message = e.statusCode == 403
            ? 'Достигнут лимит отчётов. Обновите тариф.'
            : 'Ошибка: ${e.message}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGeneratingReport = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      drawer: const AppDrawer(currentRoute: 'forecasts'),
      appBar: AppBar(
        title: const Text('Прогнозы'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_selectedDays дн.',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              ],
            ),
            onSelected: (value) {
              setState(() => _selectedDays = value);
              _loadData();
            },
            itemBuilder: (context) => [
              _buildDaysOption(7, '7 дней'),
              _buildDaysOption(14, '14 дней'),
              _buildDaysOption(30, '30 дней'),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  PopupMenuItem<int> _buildDaysOption(int value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            _selectedDays == value ? Icons.check : Icons.calendar_today_outlined,
            size: 18,
            color: _selectedDays == value ? AppColors.primary : context.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: _selectedDays == value ? AppColors.primary : context.textPrimaryColor,
              fontWeight: _selectedDays == value ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки данных',
              style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usage info card
            if (_usageInfo != null) _buildUsageCard(),
            if (_usageInfo != null) const SizedBox(height: AppSpacing.md),

            // Limit warning
            if (_limitError != null) _buildLimitWarning(),
            if (_limitError != null) const SizedBox(height: AppSpacing.md),

            // Forecast cards
            _buildForecastSection(),
            const SizedBox(height: AppSpacing.xl),

            // Business insights
            _buildInsightsSection(),
            const SizedBox(height: AppSpacing.xl),

            // Generate report
            _buildReportGeneratorSection(),
            const SizedBox(height: AppSpacing.xl),

            // Report history
            _buildReportHistorySection(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard() {
    final usage = _usageInfo!;
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
              Icon(Icons.data_usage, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Использование ML в этом месяце',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _UsageItem(
                  label: 'Прогнозы',
                  value: usage.forecastUsageText,
                  icon: Icons.auto_graph,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _UsageItem(
                  label: 'Отчёты',
                  value: usage.reportUsageText,
                  icon: Icons.description,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _UsageItem(
                  label: 'Инсайты',
                  value: usage.insightUsageText,
                  icon: Icons.lightbulb,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLimitWarning() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning.withAlpha(75)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _limitError!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Обновите тарифный план для увеличения лимитов',
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

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Прогнозы'),
        Row(
          children: [
            Expanded(
              child: _ForecastCard(
                title: 'Заказы',
                forecast: _ordersForecast,
                icon: Icons.receipt_long,
                color: AppColors.primary,
                formatValue: (v) => v.toStringAsFixed(0),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ForecastCard(
                title: 'Выручка',
                forecast: _revenueForecast,
                icon: Icons.trending_up,
                color: AppColors.success,
                formatValue: (v) => _formatCurrency(v),
              ),
            ),
          ],
        ),
        if (_ordersForecast?.insights.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.md),
          _buildForecastInsights(_ordersForecast!.insights),
        ],
      ],
    );
  }

  Widget _buildForecastInsights(List<String> insights) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.info.withAlpha(75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                'Рекомендации',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppColors.info)),
                Expanded(
                  child: Text(
                    insight,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    if (_insights == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'AI-Инсайты'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [AppShadows.sm],
          ),
          child: Column(
            children: [
              // Metrics row
              Row(
                children: [
                  _MetricBadge(
                    label: 'Заказов',
                    value: '${_insights!.metrics.recentOrders}',
                    icon: Icons.shopping_bag,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _MetricBadge(
                    label: 'Просроч.',
                    value: '${_insights!.metrics.overdueOrders}',
                    icon: Icons.warning_amber,
                    color: _insights!.metrics.overdueOrders > 0
                        ? AppColors.error
                        : AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _MetricBadge(
                    label: 'Выручка',
                    value: '${_insights!.metrics.revenueChange > 0 ? '+' : ''}${_insights!.metrics.revenueChange.toStringAsFixed(0)}%',
                    icon: _insights!.metrics.revenueChange >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: _insights!.metrics.revenueChange >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              // Insights list
              ..._insights!.insights.map((insight) => _InsightItem(insight: insight)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportGeneratorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Генерация отчёта'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [AppShadows.sm],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Тип отчёта',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: context.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedReportType,
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedReportType = value);
                      }
                    },
                    items: _reportTypes.map((type) {
                      return DropdownMenuItem(
                        value: type['value'],
                        child: Text(type['label']!),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingReport ? null : _generateReport,
                  icon: _isGeneratingReport
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGeneratingReport
                      ? 'Генерация...'
                      : 'Сгенерировать отчёт'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'История отчётов'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [AppShadows.sm],
          ),
          child: _reportHistory.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 48,
                          color: context.textTertiaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Нет сохранённых отчётов',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: _reportHistory.asMap().entries.map((entry) {
                    final index = entry.key;
                    final report = entry.value;
                    return Column(
                      children: [
                        _ReportHistoryItem(
                          report: report,
                          onTap: () => _showReportDetails(report),
                        ),
                        if (index < _reportHistory.length - 1)
                          const Divider(height: AppSpacing.md),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  void _showReportDetails(MlReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.typeLabel,
                            style: AppTypography.h4.copyWith(
                              color: context.textPrimaryColor,
                            ),
                          ),
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm').format(report.createdAt),
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    report.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimaryColor,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

class _ForecastCard extends StatelessWidget {
  final String title;
  final Forecast? forecast;
  final IconData icon;
  final Color color;
  final String Function(double) formatValue;

  const _ForecastCard({
    required this.title,
    required this.forecast,
    required this.icon,
    required this.color,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [AppShadows.sm],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final trendIcon = forecast!.isUpTrend
        ? Icons.trending_up
        : forecast!.isDownTrend
            ? Icons.trending_down
            : Icons.trending_flat;

    final trendColor = forecast!.isUpTrend
        ? AppColors.success
        : forecast!.isDownTrend
            ? AppColors.error
            : context.textSecondaryColor;

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
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, size: 14, color: trendColor),
                    const SizedBox(width: 2),
                    Text(
                      '${forecast!.trendPercentage > 0 ? '+' : ''}${forecast!.trendPercentage.toStringAsFixed(0)}%',
                      style: AppTypography.labelSmall.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            formatValue(forecast!.predictedValue),
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
          const SizedBox(height: 4),
          Text(
            '${forecast!.confidenceInterval.low.toStringAsFixed(0)} - ${forecast!.confidenceInterval.high.toStringAsFixed(0)}',
            style: AppTypography.labelSmall.copyWith(
              color: context.textTertiaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final String insight;

  const _InsightItem({required this.insight});

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.lightbulb_outline;
    Color iconColor = AppColors.info;

    // Determine icon based on insight content
    if (insight.contains('Внимание') || insight.contains('просроч')) {
      iconData = Icons.warning_amber;
      iconColor = AppColors.warning;
    } else if (insight.contains('вырос') || insight.contains('отлич')) {
      iconData = Icons.thumb_up;
      iconColor = AppColors.success;
    } else if (insight.contains('сниз')) {
      iconData = Icons.thumb_down;
      iconColor = AppColors.error;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight,
              style: AppTypography.bodySmall.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportHistoryItem extends StatelessWidget {
  final MlReport report;
  final VoidCallback onTap;

  const _ReportHistoryItem({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.typeLabel,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(report.createdAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.textTertiaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _UsageItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondaryColor,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
