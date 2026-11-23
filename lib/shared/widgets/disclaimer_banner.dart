import 'package:flutter/material.dart';
import 'package:skinsense/core/constants/app_constants.dart';
import 'package:skinsense/core/theme/app_theme.dart';

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.mist,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: AppTheme.teal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppConstants.disclaimer,
              style: TextStyle(fontSize: 12.5, height: 1.4, color: AppTheme.ink),
            ),
          ),
        ],
      ),
    );
  }
}
