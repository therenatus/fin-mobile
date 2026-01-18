import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

/// Card widget for displaying workload for a single day
class WorkloadDayCard extends StatelessWidget {
  final WorkloadDay day;

  const WorkloadDayCard({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: _buildLoadIndicator(),
        title: Row(
          children: [
            Text(
              day.dayOfWeek,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(day.dateTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              '${day.loadPercentage}% загрузки',
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${day.plannedHours.toStringAsFixed(1)}ч план / ${day.actualHours.toStringAsFixed(1)}ч факт',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (day.tasks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${day.tasks.length}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          if (day.tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Нет задач на этот день'),
            )
          else
            ...day.tasks.map((task) => _TaskListItem(task: task)),
        ],
      ),
    );
  }

  Widget _buildLoadIndicator() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor().withOpacity(0.15),
      ),
      child: Center(
        child: Text(
          '${day.loadPercentage}%',
          style: TextStyle(
            color: _getStatusColor(),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (day.status) {
      case WorkloadStatus.light:
        return Colors.green;
      case WorkloadStatus.normal:
        return Colors.blue;
      case WorkloadStatus.heavy:
        return Colors.orange;
      case WorkloadStatus.overload:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}';
  }
}

class _TaskListItem extends StatelessWidget {
  final WorkloadTask task;

  const _TaskListItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.assignment, size: 20),
      title: Text(
        task.operationName,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        '${task.orderInfo} ${task.assignee != null ? "• ${task.assignee}" : ""}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${task.plannedHours.toStringAsFixed(1)}ч',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 8),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    switch (task.status) {
      case 'PENDING':
        color = Colors.grey;
        break;
      case 'IN_PROGRESS':
        color = Colors.orange;
        break;
      case 'COMPLETED':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
