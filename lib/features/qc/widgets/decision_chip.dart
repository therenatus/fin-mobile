import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

/// Decision chip for QC check results
class DecisionChip extends StatelessWidget {
  final QcDecision decision;

  const DecisionChip({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    final color = _getDecisionColor(decision);

    return Chip(
      label: Text(
        decision.label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static Color _getDecisionColor(QcDecision decision) {
    switch (decision) {
      case QcDecision.pass:
        return Colors.green;
      case QcDecision.fail:
        return Colors.red;
      case QcDecision.conditional:
        return Colors.orange;
    }
  }
}
