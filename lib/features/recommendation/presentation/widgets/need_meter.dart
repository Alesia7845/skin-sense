import 'package:flutter/material.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/features/recommendation/domain/entities/need_profile.dart';

class NeedMeter extends StatelessWidget {
  const NeedMeter({super.key, required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppTheme.ink)),
              ),
              Text('${NeedProfile.levelOf(value)} (${value.round()})',
                  style: TextStyle(fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppTheme.mist,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
