import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/splash/viewmodels/splash_controller.dart';

/// Widget hiển thị thanh loading
class SplashLoadingBarWidget extends StatelessWidget {
  final SplashController controller;
  final double screenWidth;

  const SplashLoadingBarWidget({
    super.key,
    required this.controller,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 24.0;
    final barWidth = screenWidth - (horizontalPadding * 2);
    final barHeight = 6.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Obx(
        () => Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: AppColors.loadingBarInactive,
            borderRadius: BorderRadius.circular(barHeight / 2),
          ),
          child: Stack(
            children: [
              _buildProgressBar(controller, barWidth, barHeight),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng thanh tiến trình
  Widget _buildProgressBar(
    SplashController controller,
    double barWidth,
    double barHeight,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(barHeight / 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: barWidth * controller.loadingProgress,
          height: barHeight,
          color: AppColors.loadingBarActive,
        ),
      ),
    );
  }
}
