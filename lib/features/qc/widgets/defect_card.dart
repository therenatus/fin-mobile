import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

class DefectCard extends StatelessWidget {
  final Defect defect;
  final VoidCallback? onTap;

  const DefectCard({
    super.key,
    required this.defect,
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
                      defect.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _SeverityBadge(severity: defect.severity),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatusChip(status: defect.status),
                  const SizedBox(width: 8),
                  _TypeChip(type: defect.type),
                ],
              ),
              if (defect.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  defect.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (defect.location != null) ...[
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      defect.location!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                  ],
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${defect.daysSinceCreation} дн.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (defect.assignee != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      defect.assignee!.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DefectStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case DefectStatus.open:
        color = Colors.red;
        break;
      case DefectStatus.inProgress:
        color = Colors.orange;
        break;
      case DefectStatus.resolved:
        color = Colors.blue;
        break;
      case DefectStatus.closed:
        color = Colors.green;
        break;
      case DefectStatus.wontFix:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        status.label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _TypeChip extends StatelessWidget {
  final DefectType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        type.label,
        style: const TextStyle(fontSize: 12),
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final DefectSeverity severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (severity) {
      case DefectSeverity.critical:
        color = Colors.red;
        icon = Icons.error;
        break;
      case DefectSeverity.major:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case DefectSeverity.minor:
        color = Colors.yellow.shade700;
        icon = Icons.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            severity.label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
