import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/heart_rate/viewmodels/heart_rate_result_controller.dart';

/// Widget button SAVE ở bottom
class HeartRateResultSaveButtonWidget extends StatelessWidget {
  const HeartRateResultSaveButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HeartRateResultController>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => controller.saveResult(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            AppStrings.save.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
