import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/riverpod/providers.dart';
import '../../../core/models/models.dart';

/// Screen for creating a new defect
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
              items: DefectType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DefectSeverity>(
              value: _severity,
              decoration: const InputDecoration(
                labelText: 'Серьёзность',
                border: OutlineInputBorder(),
              ),
              items: DefectSeverity.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      ))
                  .toList(),
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
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            location: _locationController.text.isEmpty
                ? null
                : _locationController.text,
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
