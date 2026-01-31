import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';
import 'package:step_counter/features/drink_water/views/widgets/cup_capacity_bottom_sheet_widget.dart';

/// Widget button cho cup capacity
class CupCapacityButtonWidget extends StatelessWidget {
  final BuildContext context;
  final DrinkWaterSettingsController controller;

  const CupCapacityButtonWidget({
    super.key,
    required this.context,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => _showCupCapacityBottomSheet(context),
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
                '${controller.cupCapacity} ml',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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

  /// Hiển thị bottom sheet cho cup capacity
  void _showCupCapacityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CupCapacityBottomSheetWidget(
        controller: controller,
      ),
    );
  }
}
