import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

/// Type chip for QC templates
class QcTypeChip extends StatelessWidget {
  final QcType type;

  const QcTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(type.label, style: const TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
