import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

class CheckCard extends StatelessWidget {
  final QcCheck check;
  final VoidCallback? onTap;
  final VoidCallback? onStart;

  const CheckCard({
    super.key,
    required this.check,
    this.onTap,
    this.onStart,
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
                      check.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _StatusChip(status: check.status),
                ],
              ),
              const SizedBox(height: 8),
              if (check.template != null)
                Row(
                  children: [
                    const Icon(Icons.description, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      check.template!.type.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              if (check.inspector != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      check.inspector!.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(value: check.progressPercent / 100),
                  ),
                  const SizedBox(width: 8),
                  Text('${check.progressPercent}%'),
                ],
              ),
              if (check.decision != null) ...[
                const SizedBox(height: 8),
                _DecisionChip(decision: check.decision!),
              ],
              if (onStart != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onStart,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Начать'),
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
  final QcStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case QcStatus.pending:
        color = Colors.grey;
        break;
      case QcStatus.inProgress:
        color = Colors.orange;
        break;
      case QcStatus.completed:
        color = Colors.green;
        break;
      case QcStatus.cancelled:
        color = Colors.red;
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

class _DecisionChip extends StatelessWidget {
  final QcDecision decision;

  const _DecisionChip({required this.decision});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (decision) {
      case QcDecision.pass:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case QcDecision.fail:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case QcDecision.conditional:
        color = Colors.orange;
        icon = Icons.warning;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          decision.label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
