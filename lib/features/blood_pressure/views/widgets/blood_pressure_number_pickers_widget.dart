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

    return Obx(() {
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
              getColorForValue: (value) =>
                  _getSystolicColor(value, controller.diastolic),
              isSystolic: true,
            ),
            _buildNumberPicker(
              label: AppStrings.diastolic,
              value: controller.diastolic,
              min: 30,
              max: 150,
              onChanged: (value) => controller.diastolic = value,
              getColorForValue: (value) =>
                  _getDiastolicColor(controller.systolic, value),
              isSystolic: false,
            ),
            _buildNumberPicker(
              label: AppStrings.pulseBMP,
              value: controller.pulse,
              min: 40,
              max: 200,
              onChanged: (value) => controller.pulse = value,
              getColorForValue: (value) => _getPulseColor(value),
            ),
          ],
        ),
      );
    });
  }

  /// Lấy màu dựa trên giá trị systolic (6 categories)
  Color _getSystolicColor(int systolic, int diastolic) {
    if (systolic < 90 || diastolic < 60) {
      return Colors.blue; // Hypotension
    } else if (systolic >= 90 &&
        systolic <= 119 &&
        diastolic >= 60 &&
        diastolic <= 79) {
      return const Color(0xFF15D254); // Normal - Green
    } else if (systolic >= 120 &&
        systolic <= 129 &&
        diastolic >= 60 &&
        diastolic <= 79) {
      return Colors.yellow; // Elevated
    } else if (systolic >= 130 &&
        systolic <= 139 &&
        diastolic >= 80 &&
        diastolic <= 89) {
      return const Color(0xFFFFA500); // Stage 1 - Orange 1
    } else if ((systolic >= 140 && systolic <= 180) ||
        (diastolic >= 90 && diastolic <= 120)) {
      return const Color(0xFFFF6B35); // Stage 2 - Orange 2
    } else {
      return Colors.red; // Hypertensive
    }
  }

  /// Lấy màu dựa trên giá trị diastolic (6 categories)
  Color _getDiastolicColor(int systolic, int diastolic) {
    if (systolic < 90 || diastolic < 60) {
      return Colors.blue; // Hypotension
    } else if (systolic >= 90 &&
        systolic <= 119 &&
        diastolic >= 60 &&
        diastolic <= 79) {
      return const Color(0xFF15D254); // Normal - Green
    } else if (systolic >= 120 &&
        systolic <= 129 &&
        diastolic >= 60 &&
        diastolic <= 79) {
      return Colors.yellow; // Elevated
    } else if (systolic >= 130 &&
        systolic <= 139 &&
        diastolic >= 80 &&
        diastolic <= 89) {
      return const Color(0xFFFFA500); // Stage 1 - Orange 1
    } else if ((systolic >= 140 && systolic <= 180) ||
        (diastolic >= 90 && diastolic <= 120)) {
      return const Color(0xFFFF6B35); // Stage 2 - Orange 2
    } else {
      return Colors.red; // Hypertensive
    }
  }

  /// Lấy màu dựa trên giá trị pulse (6 categories)
  /// Pulse range: 40-200 BPM
  /// Segment 0 (Blue): < 50 - Rất thấp
  /// Segment 1 (Green): 50-70 - Thấp nhưng OK
  /// Segment 2 (Green): 70-100 - Normal
  /// Segment 3 (Yellow): 100-120 - Hơi cao
  /// Segment 4 (Orange): 120-150 - Cao
  /// Segment 5 (Red): > 150 - Rất cao
  Color _getPulseColor(int pulse) {
    if (pulse < 50) {
      return Colors.blue; // Segment 0 - Rất thấp
    } else if (pulse >= 50 && pulse < 70) {
      return const Color(0xFF15D254); // Segment 1 - Thấp nhưng chấp nhận được
    } else if (pulse >= 70 && pulse <= 100) {
      return const Color(0xFF15D254); // Segment 2 - Normal - Green
    } else if (pulse > 100 && pulse <= 120) {
      return Colors.yellow; // Segment 3 - Hơi cao
    } else if (pulse > 120 && pulse <= 150) {
      return const Color(0xFFFFA500); // Segment 4 - Cao - Orange 1
    } else {
      return Colors.red; // Segment 5 - Rất cao
    }
  }

  /// Xây dựng number picker
  Widget _buildNumberPicker({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    Color? Function(int)? getColorForValue,
    bool isSystolic = false,
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

                  // Lấy màu dựa trên giá trị nếu có hàm getColorForValue
                  Color? textColor;
                  if (getColorForValue != null) {
                    textColor = getColorForValue(itemValue);
                  } else {
                    textColor = isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary;
                  }

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
                          color: textColor,
                          fontSize: 24,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
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
