import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';
import 'package:step_counter/features/drink_water/views/widgets/interval_bottom_sheet_widget.dart';

/// Widget button cho interval
class IntervalButtonWidget extends StatelessWidget {
  final BuildContext context;
  final DrinkWaterSettingsController controller;

  const IntervalButtonWidget({
    super.key,
    required this.context,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => _showIntervalBottomSheet(context),
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
                controller.intervalType == 'minutes'
                    ? '${controller.interval} min'
                    : '${controller.interval} hour',
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

  /// Hiển thị bottom sheet cho interval
  void _showIntervalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => IntervalBottomSheetWidget(controller: controller),
    );
  }
}
