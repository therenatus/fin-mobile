import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/widgets/info_row.dart';
import '../widgets/defect_status_chip.dart';
import '../widgets/severity_chip.dart';

/// Screen showing defect details
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
                        Text(
                          defect.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            DefectStatusChip(status: defect.status),
                            const SizedBox(width: 8),
                            SeverityChip(severity: defect.severity),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (defect.description != null)
                          Text(defect.description!),
                        const SizedBox(height: 16),
                        InfoRow('Тип:', defect.type.label),
                        if (defect.location != null)
                          InfoRow('Местоположение:', defect.location!),
                        if (defect.assignee != null)
                          InfoRow('Исполнитель:', defect.assignee!.name),
                        if (defect.resolution != null)
                          InfoRow('Решение:', defect.resolution!),
                        InfoRow('Создан:', '${defect.daysSinceCreation} дн. назад'),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
