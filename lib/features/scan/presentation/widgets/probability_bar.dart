import 'package:flutter/material.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/shared/models/skin_type.dart';
import 'package:skinsense/shared/widgets/skin_type_style.dart';

class ProbabilityBar extends StatelessWidget {
  const ProbabilityBar({
    super.key,
    required this.type,
    required this.value,
    this.isPrimary = false,
  });

  final SkinType type;
  final double value;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final barColor = isPrimary ? AppTheme.coral : AppTheme.navy.withOpacity(0.45);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(type.icon,
                  size: 16,
                  color: isPrimary ? AppTheme.coral : AppTheme.slate),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                    color: AppTheme.navy,
                  ),
                ),
              ),
              Text(
                Formatters.percent(value),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isPrimary ? AppTheme.coral : AppTheme.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.ice,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
