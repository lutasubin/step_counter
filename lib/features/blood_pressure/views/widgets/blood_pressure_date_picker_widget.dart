import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/blood_pressure/viewmodels/new_blood_pressure_controller.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_time_picker_bottom_sheet.dart';

/// Widget date/time picker
class BloodPressureDatePickerWidget extends StatelessWidget {
  const BloodPressureDatePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewBloodPressureController>();

    return Obx(() {
      final dateFormat = DateFormat('h:mm a - MMM d, yyyy', 'en_US');
      final formattedDate = dateFormat.format(controller.dateTime);

      return InkWell(
        onTap: () {
          // Hiển thị bottom sheet từ dưới lên
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => const BloodPressureTimePickerBottomSheet(),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      );
    });
  }
}
