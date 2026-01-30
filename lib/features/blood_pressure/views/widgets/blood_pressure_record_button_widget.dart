import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/core/constants/route_names.dart';

/// Widget button "RECORD" ở dưới cùng
class BloodPressureRecordButtonWidget extends StatelessWidget {
  const BloodPressureRecordButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Get.toNamed(RouteNames.newBloodPressure);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            AppStrings.recordBloodPressure,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
