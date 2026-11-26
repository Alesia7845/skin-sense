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
        border: Border.all(color: AppTheme.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.navy),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppConstants.disclaimer,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppTheme.slate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
