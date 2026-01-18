import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/employee_user.dart';
import '../../../core/widgets/date_range_picker_button.dart';
import '../../../core/widgets/infinite_scroll_list.dart';
import 'record_work_screen.dart';

class MyTasksScreen extends ConsumerStatefulWidget {
  const MyTasksScreen({super.key});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeAuthNotifierProvider.notifier).refreshAssignments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(employeeAuthNotifierProvider.notifier).refreshAssignments();
  }

  List<EmployeeAssignment> _filterAssignments(List<EmployeeAssignment> assignments) {
    return assignments.where((a) {
      // Status filter based on TOTAL work completion (all employees for this step)
      // isStepCompleted checks if totalCompletedQuantity >= quantity
      final isTaskCompleted = a.order.isStepCompleted;

      // Tab 1: "В работе" - only show tasks with remaining work
      if (_tabController.index == 1 && isTaskCompleted) return false;
      // Tab 2: "Готовые" - only show completed tasks (step is fully done)
      if (_tabController.index == 2 && !isTaskCompleted) return false;

      // Date range filter
      if (_dateRange != null && a.order.dueDate != null) {
        final dueDate = a.order.dueDate!;
        if (dueDate.isBefore(_dateRange!.start) ||
            dueDate.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(employeeAuthNotifierProvider);
    final notifier = ref.read(employeeAuthNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.myTasks),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: context.l10n.all),
              Tab(text: context.l10n.inWork),
              Tab(text: context.l10n.ready),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: context.textSecondaryColor,
            indicatorColor: AppColors.primary,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (authState.isLoading && authState.assignments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _filterAssignments(authState.assignments);

          return Column(
            children: [
              // Date range filter
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    DateRangePickerButton(
                      dateRange: _dateRange,
                      onChanged: (range) => setState(() => _dateRange = range),
                      placeholder: context.l10n.dateFilter,
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.tasksCount(filtered.length),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InfiniteScrollList<EmployeeAssignment>(
                  items: filtered,
                  hasMore: authState.hasMoreAssignments,
                  isLoading: authState.isLoadingMoreAssignments,
                  onLoadMore: () => notifier.loadMoreAssignments(
                    includeCompleted: _tabController.index == 2,
                  ),
                  onRefresh: _onRefresh,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  separatorHeight: 0,
                  emptyWidget: _buildEmptyContent(),
                  itemBuilder: (context, assignment, index) {
                    return _AssignmentCard(
                      assignment: assignment,
                      roleLabel: notifier.getRoleLabel(authState.user?.role ?? ''),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.surfaceVariantColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 64,
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.noActiveTasks,
            style: AppTypography.h3.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              context.l10n.tasksWillAppearHere,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textTertiaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final EmployeeAssignment assignment;
  final String roleLabel;

  const _AssignmentCard({
    required this.assignment,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    final order = assignment.order;
    final isCompleted = order.isStepCompleted;
    final isOverdue = order.dueDate != null &&
        order.dueDate!.isBefore(DateTime.now()) &&
        !isCompleted;
    final totalProgress = order.totalProgressPercent;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isOverdue ? AppColors.error.withOpacity(0.5) : context.borderColor,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordWorkScreen(assignment: assignment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Icon/image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.assignment_outlined,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.modelName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            assignment.stepName,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.clientName,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStatusBadge(context, order.status),
                        const SizedBox(width: AppSpacing.sm),
                        if (order.dueDate != null) ...[
                          Icon(
                            isOverdue ? Icons.warning_amber_rounded : Icons.schedule,
                            size: 14,
                            color: isOverdue ? AppColors.error : context.textTertiaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('d MMM', 'ru').format(order.dueDate!),
                            style: AppTypography.labelSmall.copyWith(
                              color: isOverdue ? AppColors.error : context.textTertiaryColor,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${order.totalCompletedQuantity}/${order.quantity}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: totalProgress >= 1 ? AppColors.success : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final (color, label) = switch (status) {
      'in_progress' => (AppColors.info, context.l10n.statusInWork),
      'completed' => (AppColors.success, context.l10n.statusReady),
      'pending' => (AppColors.warning, context.l10n.statusWaiting),
      _ => (context.textSecondaryColor, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
