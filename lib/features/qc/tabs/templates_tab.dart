import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';
import '../widgets/template_card.dart';
import '../screens/template_detail_screen.dart';

/// Tab displaying QC templates list
class TemplatesTab extends ConsumerStatefulWidget {
  const TemplatesTab({super.key});

  @override
  ConsumerState<TemplatesTab> createState() => _TemplatesTabState();
}

class _TemplatesTabState extends ConsumerState<TemplatesTab> {
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
