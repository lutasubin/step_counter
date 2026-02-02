import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';

/// Widget disclaimer cho heart rate result
class HeartRateResultDisclaimerWidget extends StatelessWidget {
  const HeartRateResultDisclaimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.disclaimerText,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
