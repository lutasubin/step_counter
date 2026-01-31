import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';
import 'package:step_counter/features/drink_water/views/widgets/drink_water_setting_item_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/drink_water_settings_header_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/drink_water_settings_save_button_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/drink_goal_button_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/cup_capacity_button_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/remind_toggle_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/start_time_button_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/end_time_button_widget.dart';
import 'package:step_counter/features/drink_water/views/widgets/interval_button_widget.dart';

/// Màn hình settings của drink water
class DrinkWaterSettingsView extends StatelessWidget {
  const DrinkWaterSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrinkWaterSettingsController>();
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: [
            const DrinkWaterSettingsHeaderWidget(),
            Expanded(child: _buildContent(context, controller, mediaQuery)),
            DrinkWaterSettingsSaveButtonWidget(
              controller: controller,
              mediaQuery: mediaQuery,
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng nội dung
  Widget _buildContent(
    BuildContext context,
    DrinkWaterSettingsController controller,
    MediaQueryData mediaQuery,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * 0.05),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSettingCard(
              controller,
              AppStrings.drinkingGoal,
              DrinkGoalButtonWidget(context: context, controller: controller),
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              controller,
              AppStrings.cupCapacity,
              CupCapacityButtonWidget(context: context, controller: controller),
            ),
            const SizedBox(height: 16),
            _buildRemindCard(context, controller),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Xây dựng setting card
  Widget _buildSettingCard(
    DrinkWaterSettingsController controller,
    String title,
    Widget valueWidget,
  ) {
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

  /// Xây dựng remind card với toggle và các settings
  Widget _buildRemindCard(
    BuildContext context,
    DrinkWaterSettingsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Remind toggle
          DrinkWaterSettingItemWidget(
            title: AppStrings.remind,
            valueWidget: RemindToggleWidget(controller: controller),
          ),
          // Remind settings khi bật
          Obx(
            () => controller.remind
                ? Column(
                    children: [
                      const SizedBox(height: 16),
                      DrinkWaterSettingItemWidget(
                        title: AppStrings.startTime,
                        valueWidget: StartTimeButtonWidget(
                          context: context,
                          controller: controller,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DrinkWaterSettingItemWidget(
                        title: AppStrings.endTime,
                        valueWidget: EndTimeButtonWidget(
                          context: context,
                          controller: controller,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DrinkWaterSettingItemWidget(
                        title: AppStrings.interval,
                        valueWidget: IntervalButtonWidget(
                          context: context,
                          controller: controller,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
