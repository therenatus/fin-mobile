import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

class TemplateCard extends StatelessWidget {
  final QcTemplate template;
  final VoidCallback? onTap;

  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _TypeChip(type: template.type),
                ],
              ),
              if (template.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  template.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.checklist, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${template.items.length} пунктов',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${template.requiredItemsCount} обязательных',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    template.isActive ? Icons.check_circle : Icons.pause_circle,
                    size: 16,
                    color: template.isActive ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    template.isActive ? 'Активен' : 'Неактивен',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: template.isActive ? Colors.green : Colors.grey,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final QcType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case QcType.incoming:
        color = Colors.blue;
        break;
      case QcType.inProcess:
        color = Colors.orange;
        break;
      case QcType.final_:
        color = Colors.green;
        break;
    }

    return Chip(
      label: Text(
        type.label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
