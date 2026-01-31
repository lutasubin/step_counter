import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';
import 'package:step_counter/features/drink_water/views/widgets/drink_water_setting_item_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/start_time_button_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/end_time_button_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/interval_button_widget.dart';

/// Widget hiển thị remind settings (start time, end time, interval)
class RemindSettingsWidget extends StatelessWidget {
  final BuildContext context;
  final DrinkWaterSettingsController controller;

  const RemindSettingsWidget({
    super.key,
    required this.context,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.remind
          ? Column(
              children: [
                const SizedBox(height: 16),
                _buildSettingCard(
                  AppStrings.startTime,
                  StartTimeButtonWidget(
                    context: context,
                    controller: controller,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  AppStrings.endTime,
                  EndTimeButtonWidget(context: context, controller: controller),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  AppStrings.interval,
                  IntervalButtonWidget(
                    context: context,
                    controller: controller,
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  /// Xây dựng setting card
  Widget _buildSettingCard(String title, Widget valueWidget) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DrinkWaterSettingItemWidget(
        title: title,
        valueWidget: valueWidget,
      ),
    );
  }
}
