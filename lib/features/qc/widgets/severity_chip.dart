import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

/// Severity chip for defects
class SeverityChip extends StatelessWidget {
  final DefectSeverity severity;

  const SeverityChip({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(severity);

    return Chip(
      label: Text(
        severity.label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static Color _getSeverityColor(DefectSeverity severity) {
    switch (severity) {
      case DefectSeverity.critical:
        return Colors.red;
      case DefectSeverity.major:
        return Colors.orange;
      case DefectSeverity.minor:
        return Colors.yellow.shade700;
    }
  }
}
