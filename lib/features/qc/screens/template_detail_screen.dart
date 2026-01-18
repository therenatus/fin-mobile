import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/widgets/info_row.dart';
import '../widgets/qc_type_chip.dart';

/// Screen showing QC template details
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
                        Text(
                          template.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        QcTypeChip(type: template.type),
                        if (template.description != null) ...[
                          const SizedBox(height: 8),
                          Text(template.description!),
                        ],
                        const SizedBox(height: 8),
                        InfoRow('Пунктов:', '${template.items.length}'),
                        InfoRow('Обязательных:', '${template.requiredItemsCount}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Пункты проверки',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...template.items.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${item.sequence}')),
                        title: Text(item.name),
                        subtitle: item.description != null
                            ? Text(item.description!)
                            : null,
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
