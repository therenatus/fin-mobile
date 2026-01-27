import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/models/models.dart';
import 'worklog_form_screen.dart';

class WorkLogScreen extends ConsumerStatefulWidget {
  const WorkLogScreen({super.key});

  @override
  ConsumerState<WorkLogScreen> createState() => _WorkLogScreenState();
}

class _WorkLogScreenState extends ConsumerState<WorkLogScreen> {
  bool _isLoading = true;
  List<WorkLog> _workLogs = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => _loadWorkLogs());
    }
  }

  Future<void> _loadWorkLogs() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final logs = await api.getWorkLogs();
      setState(() {
        _workLogs = logs..sort((a, b) => b.date.compareTo(a.date));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: $e'),
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
      appBar: AppBar(
        title: const Text('Учёт работы'),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workLogs.isEmpty
              ? _buildEmptyState()
              : _buildWorkLogsList(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'worklog_fab',
        onPressed: _addWorkLog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Добавить запись'),
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
              Icons.work_history_outlined,
              size: 64,
              color: context.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Нет записей о работе',
              style: AppTypography.h4.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Добавьте первую запись для учёта выполненной работы',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkLogsList() {
    // Group by date
    final groupedLogs = <String, List<WorkLog>>{};
    for (final log in _workLogs) {
      final dateKey = DateFormat('d MMMM yyyy', 'ru').format(log.date);
      groupedLogs.putIfAbsent(dateKey, () => []).add(log);
    }

    return RefreshIndicator(
      onRefresh: _loadWorkLogs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          100,
        ),
        itemCount: groupedLogs.length,
        itemBuilder: (context, index) {
          final date = groupedLogs.keys.elementAt(index);
          final logs = groupedLogs[date]!;
          return _buildDateGroup(date, logs);
        },
      ),
    );
  }

  Widget _buildDateGroup(String date, List<WorkLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            date,
            style: AppTypography.labelLarge.copyWith(
              color: context.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...logs.map((log) => _WorkLogCard(log: log)),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Future<void> _addWorkLog() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkLogFormScreen(),
      ),
    );
    if (result == true) {
      _loadWorkLogs();
    }
  }
}

class _WorkLogCard extends StatelessWidget {
  final WorkLog log;

  const _WorkLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    log.step,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (log.quantity > 0)
                  _InfoChip(
                    icon: Icons.inventory_2_outlined,
                    label: '${log.quantity} шт',
                  ),
                if (log.hours > 0) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.schedule,
                    label: '${log.hours} ч',
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (log.employee != null)
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: context.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    log.employee!.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            if (log.order?.model != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 16,
                    color: context.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      log.order!.model!.name,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.textSecondaryColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
