import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';
import '../widgets/defect_card.dart';
import '../screens/defect_detail_screen.dart';

/// Tab displaying defects list
class DefectsTab extends ConsumerStatefulWidget {
  const DefectsTab({super.key});

  @override
  ConsumerState<DefectsTab> createState() => _DefectsTabState();
}

class _DefectsTabState extends ConsumerState<DefectsTab> {
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
