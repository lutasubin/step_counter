import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';

/// Widget card hiển thị tổng quan hoạt động
class ActivitySummaryCardWidget extends StatelessWidget {
  const ActivitySummaryCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(controller),
          const SizedBox(height: 20),
          _buildMetrics(controller),
          const SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );
  }

  /// Xây dựng header với step count và play button
  Widget _buildHeader(HomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          // Hiển thị bước chân kích thước lớn, bước (Steps) kích thước nhỏ hơn và màu textSecondary
          () => RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${controller.activityData.stepCount}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' / ${AppStrings.steps}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => InkWell(
            onTap: () => controller.toggleCounting(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: controller.isCounting
                  ? const Icon(
                      Icons.pause,
                      color: AppColors.textPrimary,
                      size: 32,
                    )
                  : SvgPicture.asset(AppAssets.iconPlay, width: 32, height: 32),
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng các metrics
  Widget _buildMetrics(HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.metricsBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCaloriesMetric(controller),
          _buildDistanceMetric(controller),
          _buildDurationMetric(controller),
        ],
      ),
    );
  }

  /// Xây dựng metric calories
  Widget _buildCaloriesMetric(HomeController controller) {
    return Column(
      children: [
        SvgPicture.asset(AppAssets.iconFire, width: 24, height: 24),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            controller.activityData.calories.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          AppStrings.kcal,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Xây dựng metric distance
  Widget _buildDistanceMetric(HomeController controller) {
    return Column(
      children: [
        SvgPicture.asset(AppAssets.iconKilomet, width: 24, height: 24),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            controller.activityData.distance.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          AppStrings.km,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Xây dựng metric duration
  Widget _buildDurationMetric(HomeController controller) {
    return Column(
      children: [
        SvgPicture.asset(AppAssets.iconTime, width: 24, height: 24),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            controller.activityData.duration,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          AppStrings.min,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Xây dựng footer
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Get.toNamed('/report'),
          child: Text(
            AppStrings.report,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        InkWell(
          onTap: () => Get.toNamed('/report'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.detail,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.buttonOrange,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.buttonOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
