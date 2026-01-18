import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

/// Status chip for QC checks
class QcStatusChip extends StatelessWidget {
  final QcStatus status;

  const QcStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

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

  static Color _getStatusColor(QcStatus status) {
    switch (status) {
      case QcStatus.pending:
        return Colors.grey;
      case QcStatus.inProgress:
        return Colors.orange;
      case QcStatus.completed:
        return Colors.green;
      case QcStatus.cancelled:
        return Colors.red;
    }
  }
}
