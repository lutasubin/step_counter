import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';

/// Widget button SAVE cho drink water settings
class DrinkWaterSettingsSaveButtonWidget extends StatelessWidget {
  final DrinkWaterSettingsController controller;
  final MediaQueryData mediaQuery;

  const DrinkWaterSettingsSaveButtonWidget({
    super.key,
    required this.controller,
    required this.mediaQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mediaQuery.size.width,
      padding: EdgeInsets.fromLTRB(
        mediaQuery.size.width * 0.05,
        16,
        mediaQuery.size.width * 0.05,
        mediaQuery.padding.bottom + 16,
      ),
      child: ElevatedButton(
        onPressed: controller.saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonOrange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          AppStrings.save,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
