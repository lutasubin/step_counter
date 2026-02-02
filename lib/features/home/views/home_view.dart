import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';
import 'package:step_counter/features/home/views/widgets/activity_summary_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_bottom_nav_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_header_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_heart_rate_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_blood_pressure_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_drink_water_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/try_widget_card_widget.dart';

/// Màn hình home
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    // Refresh dữ liệu khi quay lại home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshHomeCardsData();
    });

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeaderWidget(),
            Expanded(child: _buildContent(controller)),
            const HomeBottomNavWidget(),
          ],
        ),
      ),
    );
  }

  /// Xây dựng nội dung scrollable
  Widget _buildContent(HomeController controller) {
    return SingleChildScrollView(
      child: Obx(
        () => Column(
          children: [
            const ActivitySummaryCardWidget(),
            controller.hasHeartRateData
                ? const HomeHeartRateCardWidget()
                : const SizedBox.shrink(),
            controller.hasBloodPressureData
                ? const HomeBloodPressureCardWidget()
                : const SizedBox.shrink(),
            controller.hasDrinkWaterData
                ? const HomeDrinkWaterCardWidget()
                : const SizedBox.shrink(),
            const TryWidgetCardWidget(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
