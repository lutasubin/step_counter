import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';
import 'package:step_counter/features/home/views/widgets/activity_summary_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_bottom_nav_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_header_widget.dart';
import 'package:step_counter/features/home/views/widgets/track_card_widget.dart';

/// Màn hình home first (lần đầu vào app)
class HomeFirstView extends StatelessWidget {
  const HomeFirstView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

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

  /// Xây dựng nội dung scrollable với Activity Summary, Track Cards và Try Widgets
  Widget _buildContent(HomeController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Activity Summary Card
          const ActivitySummaryCardWidget(),
          // Heart Rate Track Card
          TrackCardWidget(
            iconPath: AppAssets.iconHeart,
            title: AppStrings.trackHeartRate,
            description: AppStrings.trackHeartRateDesc,
            buttonText: AppStrings.measure,
            buttonColor: AppColors.buttonOrange,
            onButtonPressed: () {
              // Chuyển thẳng đến màn measure heart rate khi bấm Measure
              Get.toNamed(RouteNames.measureHeartRate);
            },
          ),
          // Blood Pressure Track Card
          TrackCardWidget(
            iconPath: AppAssets.iconBlood,
            title: AppStrings.trackBloodPressure,
            description: AppStrings.trackBloodPressureDesc,
            buttonText: AppStrings.record,
            buttonColor: AppColors.buttonTeal,
            onButtonPressed: () {
              Get.toNamed(RouteNames.bloodPressure);
            },
          ),
          // Drink Water Track Card
          TrackCardWidget(
            iconPath: AppAssets.iconDrink,
            title: AppStrings.drinkWater,
            description: AppStrings.drinkWaterDesc,
            buttonText: AppStrings.setting,
            buttonColor: AppColors.buttonBlue,
            onButtonPressed: () {
              Get.toNamed(RouteNames.drinkWaterSettings);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
