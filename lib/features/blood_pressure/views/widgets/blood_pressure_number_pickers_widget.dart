import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/blood_pressure/viewmodels/new_blood_pressure_controller.dart';

/// Widget number pickers cho Systolic, Diastolic, Pulse
class BloodPressureNumberPickersWidget extends StatelessWidget {
  const BloodPressureNumberPickersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewBloodPressureController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNumberPicker(
            label: AppStrings.systolic,
            value: controller.systolic,
            min: 50,
            max: 200,
            onChanged: (value) => controller.systolic = value,
          ),
          _buildNumberPicker(
            label: AppStrings.diastolic,
            value: controller.diastolic,
            min: 30,
            max: 150,
            onChanged: (value) => controller.diastolic = value,
          ),
          _buildNumberPicker(
            label: AppStrings.pulseBMP,
            value: controller.pulse,
            min: 40,
            max: 200,
            onChanged: (value) => controller.pulse = value,
          ),
        ],
      ),
    );
  }

  /// Xây dựng number picker
  Widget _buildNumberPicker({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: value - min),
              onSelectedItemChanged: (index) {
                onChanged(min + index);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final itemValue = min + index;
                  final isSelected = itemValue == value;

                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.buttonOrange.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        itemValue.toString(),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 24,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
                childCount: max - min + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
