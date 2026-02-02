import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';
import 'package:step_counter/features/drink_water/views/widgets/time_picker_helper.dart';

/// Widget button cho start time
class StartTimeButtonWidget extends StatelessWidget {
  final BuildContext context;
  final DrinkWaterSettingsController controller;

  const StartTimeButtonWidget({
    super.key,
    required this.context,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => TimePickerHelper.show(
          context,
          controller,
          isStartTime: true,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.metricsBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.startTime,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_drop_down,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
