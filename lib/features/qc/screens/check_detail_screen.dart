import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/info_row.dart';
import '../widgets/qc_status_chip.dart';
import '../widgets/decision_chip.dart';

/// Screen showing QC check details
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
                _buildInfoCard(context, check),
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

  Widget _buildInfoCard(BuildContext context, QcCheck check) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(check.displayName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            QcStatusChip(status: check.status),
            if (check.decision != null) ...[
              const SizedBox(height: 8),
              DecisionChip(decision: check.decision!),
            ],
            const SizedBox(height: 16),
            if (check.inspector != null)
              InfoRow('Инспектор:', check.inspector!.name),
            InfoRow('Прогресс:', '${check.progressPercent}%'),
            InfoRow('Принято:', '${check.passedCount}'),
            InfoRow('Отклонено:', '${check.failedCount}'),
            InfoRow('Ожидает:', '${check.pendingCount}'),
          ],
        ),
      ),
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
    final check = ref.read(qcNotifierProvider).currentCheck;
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
