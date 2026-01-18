import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

/// Status chip for defects
class DefectStatusChip extends StatelessWidget {
  final DefectStatus status;

  const DefectStatusChip({super.key, required this.status});

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

  static Color _getStatusColor(DefectStatus status) {
    switch (status) {
      case DefectStatus.open:
        return Colors.red;
      case DefectStatus.inProgress:
        return Colors.orange;
      case DefectStatus.resolved:
        return Colors.blue;
      case DefectStatus.closed:
        return Colors.green;
      case DefectStatus.wontFix:
        return Colors.grey;
    }
  }
}
