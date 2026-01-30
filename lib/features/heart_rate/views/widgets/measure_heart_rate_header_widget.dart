import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/heart_rate/viewmodels/measure_heart_rate_controller.dart';

/// Widget header của measure heart rate screen
class MeasureHeartRateHeaderWidget extends StatelessWidget {
  const MeasureHeartRateHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeasureHeartRateController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () => controller.cancelMeasuring(),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              AppStrings.measureHeartRate,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
