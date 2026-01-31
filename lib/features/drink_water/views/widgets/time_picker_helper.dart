import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';
import 'package:step_counter/features/drink_water/views/widgets/custom_time_picker_bottom_sheet_widget.dart';

/// Helper class cho time picker
class TimePickerHelper {
  TimePickerHelper._();

  /// Hiển thị time picker bottom sheet
  static Future<void> show(
    BuildContext context,
    DrinkWaterSettingsController controller, {
    required bool isStartTime,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomTimePickerBottomSheetWidget(
        controller: controller,
        isStartTime: isStartTime,
      ),
    );
  }
}
