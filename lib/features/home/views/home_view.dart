import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';
import 'package:step_counter/features/home/views/widgets/activity_summary_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_bottom_nav_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_header_widget.dart';
import 'package:step_counter/features/home/views/widgets/track_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/try_widget_card_widget.dart';

/// Màn hình home
class HomeView extends StatelessWidget {
  const HomeView({super.key});

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

  /// Xây dựng nội dung scrollable
  Widget _buildContent(HomeController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const ActivitySummaryCardWidget(),
          _buildTrackHeartRateCard(),
          _buildTrackBloodPressureCard(),
          _buildDrinkWaterCard(),
          const TryWidgetCardWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Xây dựng card track heart rate
  Widget _buildTrackHeartRateCard() {
    return TrackCardWidget(
      iconPath: AppAssets.iconHeart,
      title: AppStrings.trackHeartRate,
      description: AppStrings.trackHeartRateDesc,
      buttonText: AppStrings.measure,
      buttonColor: AppColors.buttonOrange,
      onButtonPressed: () {},
    );
  }

  /// Xây dựng card track blood pressure
  Widget _buildTrackBloodPressureCard() {
    return TrackCardWidget(
      iconPath: AppAssets.iconBlood,
      title: AppStrings.trackBloodPressure,
      description: AppStrings.trackBloodPressureDesc,
      buttonText: AppStrings.record,
      buttonColor: AppColors.buttonTeal,
      onButtonPressed: () {},
    );
  }

  /// Xây dựng card drink water
  Widget _buildDrinkWaterCard() {
    return TrackCardWidget(
      iconPath: AppAssets.iconDrink,
      title: AppStrings.drinkWater,
      description: AppStrings.drinkWaterDesc,
      buttonText: AppStrings.setting,
      buttonColor: AppColors.buttonBlue,
      onButtonPressed: () {},
    );
  }
}
