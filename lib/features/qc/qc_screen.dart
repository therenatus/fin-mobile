import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/riverpod/providers.dart';
import 'screens/screens.dart';
import 'tabs/tabs.dart';
import 'widgets/create_check_dialog.dart';

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
      final notifier = ref.read(qcNotifierProvider.notifier);
      notifier.refreshChecks();
      notifier.loadPendingChecks();
      notifier.loadStats();
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
          ChecksTab(),
          TemplatesTab(),
          DefectsTab(),
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
    final notifier = ref.read(qcNotifierProvider.notifier);
    switch (_tabController.index) {
      case 0:
        notifier.refreshChecks();
        notifier.loadPendingChecks();
        break;
      case 1:
        notifier.refreshTemplates();
        break;
      case 2:
        notifier.refreshDefects();
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
    final templates = ref.read(qcNotifierProvider).templates;
    if (templates.isEmpty) {
      await ref.read(qcNotifierProvider.notifier).refreshTemplates();
    }

    if (!mounted) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const CreateCheckDialog(),
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
