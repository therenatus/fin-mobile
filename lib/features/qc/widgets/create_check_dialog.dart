import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/riverpod/providers.dart';

/// Dialog for creating a new QC check
class CreateCheckDialog extends ConsumerStatefulWidget {
  const CreateCheckDialog({super.key});

  @override
  ConsumerState<CreateCheckDialog> createState() => _CreateCheckDialogState();
}

class _CreateCheckDialogState extends ConsumerState<CreateCheckDialog> {
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
            items: templates
                .map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.name),
                    ))
                .toList(),
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
