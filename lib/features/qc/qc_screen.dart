import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/riverpod/providers.dart';
import '../../core/models/models.dart';
import 'widgets/check_card.dart';
import 'widgets/defect_card.dart';
import 'widgets/template_card.dart';

/// Main QC screen with tabs for Checks, Templates, and Defects
class QcScreen extends ConsumerStatefulWidget {
  final VoidCallback? onMenuPressed;
  final int initialTabIndex;
  final String? highlightCheckId;
  final String? highlightDefectId;

  const QcScreen({
    super.key,
    this.onMenuPressed,
    this.initialTabIndex = 0,
    this.highlightCheckId,
    this.highlightDefectId,
  });

  @override
  ConsumerState<QcScreen> createState() => _QcScreenState();
}

class _QcScreenState extends ConsumerState<QcScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadInitialData();

    // If we have a highlight ID, navigate to the appropriate detail screen
    if (widget.highlightCheckId != null || widget.highlightDefectId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeepLink();
      });
    }
  }

  void _handleDeepLink() {
    if (widget.highlightCheckId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckDetailScreen(checkId: widget.highlightCheckId!),
        ),
      );
    } else if (widget.highlightDefectId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DefectDetailScreen(defectId: widget.highlightDefectId!),
        ),
      );
    }
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = ref.read(qcNotifierProvider);
      provider.refreshChecks();
      provider.loadPendingChecks();
      provider.loadStats();
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
        title: const Text('Контроль качества'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Проверки', icon: Icon(Icons.fact_check)),
            Tab(text: 'Шаблоны', icon: Icon(Icons.description)),
            Tab(text: 'Дефекты', icon: Icon(Icons.bug_report)),
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
          _ChecksTab(),
          _TemplatesTab(),
          _DefectsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateOptions,
        icon: const Icon(Icons.add),
        label: const Text('Создать'),
      ),
    );
  }

  void _refreshCurrentTab() {
    final provider = ref.read(qcNotifierProvider);
    switch (_tabController.index) {
      case 0:
        provider.refreshChecks();
        provider.loadPendingChecks();
        break;
      case 1:
        provider.refreshTemplates();
        break;
      case 2:
        provider.refreshDefects();
        break;
    }
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fact_check),
              title: const Text('Новая проверка'),
              subtitle: const Text('Создать проверку по шаблону'),
              onTap: () {
                Navigator.pop(context);
                _showCreateCheckDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Новый шаблон'),
              subtitle: const Text('Создать шаблон проверки'),
              onTap: () {
                Navigator.pop(context);
                _showCreateTemplateDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Новый дефект'),
              subtitle: const Text('Зарегистрировать дефект'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateDefectScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateCheckDialog() async {
    final templates = ref.read(qcNotifierProvider.notifier).templates;
    if (templates.isEmpty) {
      await ref.read(qcNotifierProvider.notifier).refreshTemplates();
    }

    if (!mounted) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _CreateCheckDialog(),
    );

    if (result != null && mounted) {
      try {
        await ref.read(qcNotifierProvider.notifier).createCheck(
              templateId: result['templateId']!,
              orderId: result['orderId'],
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Проверка создана')),
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

  Future<void> _showCreateTemplateDialog() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Создание шаблонов доступно в веб-интерфейсе')),
    );
  }
}

// ==================== CHECKS TAB ====================

class _ChecksTab extends ConsumerWidget {
  const _ChecksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(qcNotifierProvider);

    if (provider.isLoading && provider.checks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.checks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка загрузки', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(qcNotifierProvider.notifier).refreshChecks(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (provider.checks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fact_check_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Нет проверок', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Создайте первую проверку'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(qcNotifierProvider.notifier).refreshChecks(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pending checks section
          if (provider.pendingChecks.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.pending_actions, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Ожидают проверки (${provider.pendingChecks.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...provider.pendingChecks.map((check) => CheckCard(
                  check: check,
                  onTap: () => _openCheckDetail(context, ref, check),
                  onStart: () => _startCheck(context, ref, check.id),
                )),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // All checks
          Text('Все проверки', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...provider.checks.map((check) => CheckCard(
                check: check,
                onTap: () => _openCheckDetail(context, ref, check),
                onStart: check.status == QcStatus.pending
                    ? () => _startCheck(context, ref, check.id)
                    : null,
              )),
        ],
      ),
    );
  }

  void _openCheckDetail(BuildContext context, WidgetRef ref, QcCheck check) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckDetailScreen(checkId: check.id)),
    );
  }

  Future<void> _startCheck(BuildContext context, WidgetRef ref, String checkId) async {
    try {
      await ref.read(qcNotifierProvider.notifier).startCheck(checkId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Проверка начата')),
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

// ==================== TEMPLATES TAB ====================

class _TemplatesTab extends ConsumerStatefulWidget {
  const _TemplatesTab();

  @override
  ConsumerState<_TemplatesTab> createState() => _TemplatesTabState();
}

class _TemplatesTabState extends ConsumerState<_TemplatesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qcNotifierProvider.notifier).refreshTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(qcNotifierProvider);

    if (provider.isLoading && provider.templates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Нет шаблонов', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Создайте шаблон проверки'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(qcNotifierProvider.notifier).refreshTemplates(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.templates.length,
        itemBuilder: (context, index) {
          final template = provider.templates[index];
          return TemplateCard(
            template: template,
            onTap: () => _openTemplateDetail(template),
          );
        },
      ),
    );
  }

  void _openTemplateDetail(QcTemplate template) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TemplateDetailScreen(templateId: template.id)),
    );
  }
}

// ==================== DEFECTS TAB ====================

class _DefectsTab extends ConsumerStatefulWidget {
  const _DefectsTab();

  @override
  ConsumerState<_DefectsTab> createState() => _DefectsTabState();
}

class _DefectsTabState extends ConsumerState<_DefectsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qcNotifierProvider.notifier).refreshDefects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(qcNotifierProvider);

    if (provider.isLoading && provider.defects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.defects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bug_report_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Нет дефектов', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Дефекты не зарегистрированы'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(qcNotifierProvider.notifier).refreshDefects(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.defects.length + (provider.hasMoreDefects ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.defects.length) {
            ref.read(qcNotifierProvider.notifier).loadDefects();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final defect = provider.defects[index];
          return DefectCard(
            defect: defect,
            onTap: () => _openDefectDetail(defect),
          );
        },
      ),
    );
  }

  void _openDefectDetail(Defect defect) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DefectDetailScreen(defectId: defect.id)),
    );
  }
}

// ==================== CREATE CHECK DIALOG ====================

class _CreateCheckDialog extends ConsumerStatefulWidget {
  const _CreateCheckDialog();

  @override
  ConsumerState<_CreateCheckDialog> createState() => _CreateCheckDialogState();
}

class _CreateCheckDialogState extends ConsumerState<_CreateCheckDialog> {
  final _orderIdController = TextEditingController();
  String? _selectedTemplateId;

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(qcNotifierProvider).templates;

    return AlertDialog(
      title: const Text('Создать проверку'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedTemplateId,
            decoration: const InputDecoration(
              labelText: 'Шаблон',
              border: OutlineInputBorder(),
            ),
            items: templates.map((t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(t.name),
                )).toList(),
            onChanged: (value) => setState(() => _selectedTemplateId = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _orderIdController,
            decoration: const InputDecoration(
              labelText: 'ID заказа (опционально)',
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
          onPressed: _selectedTemplateId != null
              ? () {
                  Navigator.pop(context, {
                    'templateId': _selectedTemplateId!,
                    if (_orderIdController.text.trim().isNotEmpty)
                      'orderId': _orderIdController.text.trim(),
                  });
                }
              : null,
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

// ==================== DETAIL SCREENS (STUBS) ====================

class CheckDetailScreen extends ConsumerStatefulWidget {
  final String checkId;

  const CheckDetailScreen({super.key, required this.checkId});

  @override
  ConsumerState<CheckDetailScreen> createState() => _CheckDetailScreenState();
}

class _CheckDetailScreenState extends ConsumerState<CheckDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qcNotifierProvider.notifier).getCheck(widget.checkId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(qcNotifierProvider);
    final check = provider.currentCheck;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали проверки'),
        actions: [
          if (check?.status == QcStatus.inProgress)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () => _showSubmitDialog(),
              tooltip: 'Завершить проверку',
            ),
        ],
      ),
      body: check == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          check.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _QcStatusChip(status: check.status),
                        if (check.decision != null) ...[
                          const SizedBox(height: 8),
                          _DecisionChip(decision: check.decision!),
                        ],
                        const SizedBox(height: 16),
                        if (check.inspector != null)
                          _InfoRow('Инспектор:', check.inspector!.name),
                        _InfoRow('Прогресс:', '${check.progressPercent}%'),
                        _InfoRow('Принято:', '${check.passedCount}'),
                        _InfoRow('Отклонено:', '${check.failedCount}'),
                        _InfoRow('Ожидает:', '${check.pendingCount}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Пункты проверки', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...check.results.map((result) => _CheckResultCard(
                      result: result,
                      editable: check.status == QcStatus.inProgress,
                    )),
              ],
            ),
      floatingActionButton: check?.status == QcStatus.pending
          ? FloatingActionButton.extended(
              onPressed: _startCheck,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Начать проверку'),
            )
          : null,
    );
  }

  Future<void> _startCheck() async {
    try {
      await ref.read(qcNotifierProvider.notifier).startCheck(widget.checkId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Проверка начата')),
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

  Future<void> _showSubmitDialog() async {
    final check = ref.read(qcNotifierProvider.notifier).currentCheck;
    if (check == null) return;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Завершить проверку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Принято'),
              onTap: () => Navigator.pop(context, 'PASS'),
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Отклонено'),
              onTap: () => Navigator.pop(context, 'FAIL'),
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text('Принято условно'),
              onTap: () => Navigator.pop(context, 'CONDITIONAL'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        await ref.read(qcNotifierProvider.notifier).submitCheckResults(
          widget.checkId,
          decision: result,
          results: check.results.map((r) => {
            'itemId': r.itemId,
            'passed': r.passed,
            'notes': r.notes,
          }).toList(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Проверка завершена')),
          );
          Navigator.pop(context);
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
}

class _CheckResultCard extends StatelessWidget {
  final QcCheckResult result;
  final bool editable;

  const _CheckResultCard({required this.result, this.editable = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          result.passed == true
              ? Icons.check_circle
              : result.passed == false
                  ? Icons.cancel
                  : Icons.radio_button_unchecked,
          color: result.passed == true
              ? Colors.green
              : result.passed == false
                  ? Colors.red
                  : Colors.grey,
        ),
        title: Text(result.item?.name ?? 'Пункт ${result.itemId}'),
        subtitle: result.item?.description != null
            ? Text(result.item!.description!)
            : null,
        trailing: result.item?.isRequired == true
            ? const Icon(Icons.star, color: Colors.amber, size: 16)
            : null,
      ),
    );
  }
}

class TemplateDetailScreen extends ConsumerStatefulWidget {
  final String templateId;

  const TemplateDetailScreen({super.key, required this.templateId});

  @override
  ConsumerState<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qcNotifierProvider.notifier).getTemplate(widget.templateId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(qcNotifierProvider);
    final template = provider.currentTemplate;

    return Scaffold(
      appBar: AppBar(title: const Text('Шаблон проверки')),
      body: template == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(template.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        _QcTypeChip(type: template.type),
                        if (template.description != null) ...[
                          const SizedBox(height: 8),
                          Text(template.description!),
                        ],
                        const SizedBox(height: 8),
                        _InfoRow('Пунктов:', '${template.items.length}'),
                        _InfoRow('Обязательных:', '${template.requiredItemsCount}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Пункты проверки', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...template.items.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${item.sequence}')),
                        title: Text(item.name),
                        subtitle: item.description != null ? Text(item.description!) : null,
                        trailing: item.isRequired
                            ? const Icon(Icons.star, color: Colors.amber)
                            : null,
                      ),
                    )),
              ],
            ),
    );
  }
}

class DefectDetailScreen extends ConsumerStatefulWidget {
  final String defectId;

  const DefectDetailScreen({super.key, required this.defectId});

  @override
  ConsumerState<DefectDetailScreen> createState() => _DefectDetailScreenState();
}

class _DefectDetailScreenState extends ConsumerState<DefectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qcNotifierProvider.notifier).getDefect(widget.defectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(qcNotifierProvider);
    final defect = provider.currentDefect;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дефект'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuAction,
            itemBuilder: (context) => [
              if (defect?.canResolve == true)
                const PopupMenuItem(value: 'resolve', child: Text('Исправлен')),
              if (defect?.canClose == true)
                const PopupMenuItem(value: 'close', child: Text('Закрыть')),
              if (defect?.canReopen == true)
                const PopupMenuItem(value: 'reopen', child: Text('Переоткрыть')),
              if (defect?.canResolve == true)
                const PopupMenuItem(value: 'wontfix', child: Text('Не исправлять')),
            ],
          ),
        ],
      ),
      body: defect == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(defect.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _DefectStatusChip(status: defect.status),
                            const SizedBox(width: 8),
                            _SeverityChip(severity: defect.severity),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (defect.description != null)
                          Text(defect.description!),
                        const SizedBox(height: 16),
                        _InfoRow('Тип:', defect.type.label),
                        if (defect.location != null)
                          _InfoRow('Местоположение:', defect.location!),
                        if (defect.assignee != null)
                          _InfoRow('Исполнитель:', defect.assignee!.name),
                        if (defect.resolution != null)
                          _InfoRow('Решение:', defect.resolution!),
                        _InfoRow('Создан:', '${defect.daysSinceCreation} дн. назад'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _onMenuAction(String action) async {
    final notifier = ref.read(qcNotifierProvider.notifier);

    try {
      switch (action) {
        case 'resolve':
          final resolution = await _showResolutionDialog();
          if (resolution != null) {
            await notifier.resolveDefect(widget.defectId, resolution);
          }
          break;
        case 'close':
          await notifier.closeDefect(widget.defectId);
          break;
        case 'reopen':
          await notifier.reopenDefect(widget.defectId);
          break;
        case 'wontfix':
          final reason = await _showReasonDialog();
          if (reason != null) {
            await notifier.wontFixDefect(widget.defectId, reason);
          }
          break;
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

  Future<String?> _showResolutionDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Как исправлен?'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Описание решения',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showReasonDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Причина'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Почему не исправляем?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

class CreateDefectScreen extends ConsumerStatefulWidget {
  const CreateDefectScreen({super.key});

  @override
  ConsumerState<CreateDefectScreen> createState() => _CreateDefectScreenState();
}

class _CreateDefectScreenState extends ConsumerState<CreateDefectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DefectType _type = DefectType.workmanship;
  DefectSeverity _severity = DefectSeverity.major;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый дефект')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? 'Обязательное поле' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DefectType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Тип дефекта',
                border: OutlineInputBorder(),
              ),
              items: DefectType.values.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.label),
                  )).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DefectSeverity>(
              value: _severity,
              decoration: const InputDecoration(
                labelText: 'Серьёзность',
                border: OutlineInputBorder(),
              ),
              items: DefectSeverity.values.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.label),
                  )).toList(),
              onChanged: (v) => setState(() => _severity = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Местоположение',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submit,
        icon: const Icon(Icons.save),
        label: const Text('Сохранить'),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(qcNotifierProvider.notifier).createDefect(
            title: _titleController.text,
            type: _type.value,
            severity: _severity.value,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            location: _locationController.text.isEmpty ? null : _locationController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дефект создан')),
        );
        Navigator.pop(context);
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

// ==================== WIDGETS ====================

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

class _QcStatusChip extends StatelessWidget {
  final QcStatus status;

  const _QcStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case QcStatus.pending:
        color = Colors.grey;
        break;
      case QcStatus.inProgress:
        color = Colors.orange;
        break;
      case QcStatus.completed:
        color = Colors.green;
        break;
      case QcStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(status.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _QcTypeChip extends StatelessWidget {
  final QcType type;

  const _QcTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(type.label, style: const TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _DecisionChip extends StatelessWidget {
  final QcDecision decision;

  const _DecisionChip({required this.decision});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (decision) {
      case QcDecision.pass:
        color = Colors.green;
        break;
      case QcDecision.fail:
        color = Colors.red;
        break;
      case QcDecision.conditional:
        color = Colors.orange;
        break;
    }

    return Chip(
      label: Text(decision.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _DefectStatusChip extends StatelessWidget {
  final DefectStatus status;

  const _DefectStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case DefectStatus.open:
        color = Colors.red;
        break;
      case DefectStatus.inProgress:
        color = Colors.orange;
        break;
      case DefectStatus.resolved:
        color = Colors.blue;
        break;
      case DefectStatus.closed:
        color = Colors.green;
        break;
      case DefectStatus.wontFix:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(status.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final DefectSeverity severity;

  const _SeverityChip({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (severity) {
      case DefectSeverity.critical:
        color = Colors.red;
        break;
      case DefectSeverity.major:
        color = Colors.orange;
        break;
      case DefectSeverity.minor:
        color = Colors.yellow.shade700;
        break;
    }

    return Chip(
      label: Text(severity.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
