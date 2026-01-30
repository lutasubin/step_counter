import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/blood_pressure/viewmodels/new_blood_pressure_controller.dart';

/// Widget button "SAVE"
class BloodPressureSaveButtonWidget extends StatelessWidget {
  const BloodPressureSaveButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewBloodPressureController>();

    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isSaving ? null : () => controller.saveBloodPressure(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: controller.isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    AppStrings.save,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
