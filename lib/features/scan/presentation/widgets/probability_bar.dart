import 'package:flutter/material.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/shared/models/skin_type.dart';
import 'package:skinsense/shared/widgets/skin_type_style.dart';

class ProbabilityBar extends StatelessWidget {
  const ProbabilityBar({super.key, required this.type, required this.value});

  final SkinType type;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(type.label,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.ink)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: AppTheme.mist,
                valueColor: AlwaysStoppedAnimation(type.color),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(Formatters.percent(value),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
