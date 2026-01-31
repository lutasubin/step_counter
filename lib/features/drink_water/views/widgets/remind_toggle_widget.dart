import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';

/// Widget toggle cho remind
class RemindToggleWidget extends StatelessWidget {
  final DrinkWaterSettingsController controller;

  const RemindToggleWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Switch(
        value: controller.remind,
        onChanged: (_) => controller.toggleRemind(),
        activeThumbColor: Colors.white,
        activeTrackColor: Colors.green,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: AppColors.metricsBackground,
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
    );
  }
}
