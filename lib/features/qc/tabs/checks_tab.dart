import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';
import '../widgets/check_card.dart';
import '../screens/check_detail_screen.dart';

/// Tab displaying QC checks list
class ChecksTab extends ConsumerWidget {
  const ChecksTab({super.key});

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
                  onTap: () => _openCheckDetail(context, check),
                  onStart: () => _startCheck(context, ref, check.id),
                )),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],
          Text('Все проверки', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...provider.checks.map((check) => CheckCard(
                check: check,
                onTap: () => _openCheckDetail(context, check),
                onStart: check.status == QcStatus.pending
                    ? () => _startCheck(context, ref, check.id)
                    : null,
              )),
        ],
      ),
    );
  }

  void _openCheckDetail(BuildContext context, QcCheck check) {
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
