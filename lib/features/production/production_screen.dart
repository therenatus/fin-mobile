import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/riverpod/providers.dart';
import '../../core/riverpod/production_provider.dart';
import '../../core/models/models.dart';
import 'widgets/plan_card.dart';

/// Main production screen with tabs for Plans and Tasks
class ProductionScreen extends ConsumerStatefulWidget {
  final VoidCallback? onMenuPressed;
  final String? highlightTaskId;

  const ProductionScreen({
    super.key,
    this.onMenuPressed,
    this.highlightTaskId,
  });

  @override
  ConsumerState<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends ConsumerState<ProductionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // If we have a highlight task, start on Tasks tab
    final initialIndex = widget.highlightTaskId != null ? 1 : 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );
    _loadInitialData();

    // Show info about the task if navigated from notification
    if (widget.highlightTaskId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTaskHighlightInfo();
      });
    }
  }

  void _showTaskHighlightInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Задача: ${widget.highlightTaskId}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productionNotifierProvider.notifier).refreshPlans();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuPressed,
              )
            : null,
        title: const Text('Производство'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Планы', icon: Icon(Icons.assignment)),
            Tab(text: 'Задачи', icon: Icon(Icons.task_alt)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCurrentTab,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PlansTab(),
          _TasksTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showScheduleDialog,
        icon: const Icon(Icons.auto_fix_high),
        label: const Text('Автопланирование'),
      ),
    );
  }

  void _refreshCurrentTab() {
    final notifier = ref.read(productionNotifierProvider.notifier);
    switch (_tabController.index) {
      case 0:
        notifier.refreshPlans();
        break;
      case 1:
        notifier.loadMyTasks();
        break;
    }
  }

  Future<void> _showScheduleDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _ScheduleOrderDialog(),
    );

    if (result != null && mounted) {
      try {
        await ref.read(productionNotifierProvider.notifier).scheduleOrder(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('План создан успешно')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// ==================== PLANS TAB ====================

class _PlansTab extends ConsumerWidget {
  const _PlansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(productionNotifierProvider);

    if (provider.isLoading && provider.plans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ошибка загрузки',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(productionNotifierProvider.notifier).refreshPlans(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (provider.plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Нет планов производства',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Создайте план через автопланирование'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(productionNotifierProvider.notifier).refreshPlans(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.plans.length + (provider.hasMorePlans ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.plans.length) {
            // Load more indicator
            ref.read(productionNotifierProvider.notifier).loadMorePlans();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final plan = provider.plans[index];
          return PlanCard(
            plan: plan,
            onTap: () => _openPlanDetail(context, plan),
            onStart: plan.status == PlanStatus.scheduled
                ? () => _startPlan(context, ref, plan.id)
                : null,
          );
        },
      ),
    );
  }

  void _openPlanDetail(BuildContext context, ProductionPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PlanDetailScreen(planId: plan.id),
      ),
    );
  }

  Future<void> _startPlan(BuildContext context, WidgetRef ref, String planId) async {
    try {
      await ref.read(productionNotifierProvider.notifier).startPlan(planId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('План запущен')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ==================== TASKS TAB ====================

class _TasksTab extends ConsumerStatefulWidget {
  const _TasksTab();

  @override
  ConsumerState<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends ConsumerState<_TasksTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productionNotifierProvider.notifier).loadMyTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(productionNotifierProvider);
    final tasks = provider.myTasks;

    if (provider.isLoading && tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Нет задач',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Задачи появятся после создания планов'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(productionNotifierProvider.notifier).loadMyTasks(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _TaskCard(
            task: task,
            onStart: task.status == TaskStatus.pending ||
                    task.status == TaskStatus.ready
                ? () => _startTask(task.id)
                : null,
            onComplete: task.status == TaskStatus.inProgress
                ? () => _completeTask(task.id)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _startTask(String taskId) async {
    try {
      await ref.read(productionNotifierProvider.notifier).startTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Задача начата')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeTask(String taskId) async {
    try {
      await ref.read(productionNotifierProvider.notifier).completeTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Задача завершена')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _TaskCard extends StatelessWidget {
  final ProductionTask task;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  const _TaskCard({
    required this.task,
    this.onStart,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.operationName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: task.status),
              ],
            ),
            const SizedBox(height: 8),
            if (task.assignee != null)
              Text(
                'Исполнитель: ${task.assignee!.name}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            Text(
              'Плановые часы: ${task.plannedHours.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: task.progressPercent / 100),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onStart != null)
                  ElevatedButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Начать'),
                  ),
                if (onComplete != null)
                  ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check),
                    label: const Text('Завершить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TaskStatus.pending:
        color = Colors.grey;
        break;
      case TaskStatus.ready:
        color = Colors.blue;
        break;
      case TaskStatus.inProgress:
        color = Colors.orange;
        break;
      case TaskStatus.completed:
        color = Colors.green;
        break;
      case TaskStatus.blocked:
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// ==================== SCHEDULE DIALOG ====================

class _ScheduleOrderDialog extends StatefulWidget {
  const _ScheduleOrderDialog();

  @override
  State<_ScheduleOrderDialog> createState() => _ScheduleOrderDialogState();
}

class _ScheduleOrderDialogState extends State<_ScheduleOrderDialog> {
  final _orderIdController = TextEditingController();

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Автопланирование заказа'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Введите ID заказа для автоматического создания плана производства',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _orderIdController,
            decoration: const InputDecoration(
              labelText: 'ID заказа',
              hintText: 'Введите ID заказа',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final orderId = _orderIdController.text.trim();
            if (orderId.isNotEmpty) {
              Navigator.pop(context, orderId);
            }
          },
          child: const Text('Создать план'),
        ),
      ],
    );
  }
}

// ==================== PLAN DETAIL SCREEN ====================

class _PlanDetailScreen extends ConsumerStatefulWidget {
  final String planId;

  const _PlanDetailScreen({required this.planId});

  @override
  ConsumerState<_PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<_PlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productionNotifierProvider.notifier).getPlan(widget.planId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(productionNotifierProvider);
    final plan = provider.currentPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали плана'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'start',
                child: Text('Запустить'),
              ),
              const PopupMenuItem(
                value: 'complete',
                child: Text('Завершить'),
              ),
              const PopupMenuItem(
                value: 'reschedule',
                child: Text('Пересчитать'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Удалить'),
              ),
            ],
          ),
        ],
      ),
      body: plan == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Plan info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.orderInfo,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _PlanStatusChip(status: plan.status),
                        const SizedBox(height: 16),
                        _InfoRow('Начало:', _formatDate(plan.plannedStart)),
                        _InfoRow('Окончание:', _formatDate(plan.plannedEnd)),
                        _InfoRow('Всего задач:', '${plan.tasks.length}'),
                        _InfoRow('Выполнено:', '${plan.completedTasksCount}/${plan.tasks.length}'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: plan.progressPercent / 100),
                        Text('${plan.progressPercent}%'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tasks list
                Text(
                  'Задачи',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...plan.tasks.map((task) => _TaskCard(
                      task: task,
                      onStart: task.status == TaskStatus.pending ||
                              task.status == TaskStatus.ready
                          ? () => _startTask(task.id)
                          : null,
                      onComplete: task.status == TaskStatus.inProgress
                          ? () => _completeTask(task.id)
                          : null,
                    )),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _onMenuAction(String action) async {
    final notifier = ref.read(productionNotifierProvider.notifier);

    try {
      switch (action) {
        case 'start':
          await notifier.startPlan(widget.planId);
          break;
        case 'complete':
          await notifier.completePlan(widget.planId);
          break;
        case 'reschedule':
          await notifier.reschedulePlan(widget.planId);
          break;
        case 'delete':
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Удалить план?'),
              content: const Text('Это действие нельзя отменить'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Удалить'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await notifier.deletePlan(widget.planId);
            if (mounted) Navigator.pop(context);
          }
          return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Операция выполнена')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _startTask(String taskId) async {
    try {
      await ref.read(productionNotifierProvider.notifier).startTask(taskId);
      await ref.read(productionNotifierProvider.notifier).getPlan(widget.planId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeTask(String taskId) async {
    try {
      await ref.read(productionNotifierProvider.notifier).completeTask(taskId);
      await ref.read(productionNotifierProvider.notifier).getPlan(widget.planId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}

class _PlanStatusChip extends StatelessWidget {
  final PlanStatus status;

  const _PlanStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case PlanStatus.draft:
        color = Colors.grey;
        break;
      case PlanStatus.scheduled:
        color = Colors.blue;
        break;
      case PlanStatus.inProgress:
        color = Colors.orange;
        break;
      case PlanStatus.completed:
        color = Colors.green;
        break;
      case PlanStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}

