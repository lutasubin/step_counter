import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/heart_rate/viewmodels/measure_heart_rate_controller.dart';

/// Widget nội dung chính của measure heart rate screen
class MeasureHeartRateContentWidget extends StatelessWidget {
  final MeasureHeartRateController controller;

  const MeasureHeartRateContentWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildHeartIcon(),
          const SizedBox(height: 40),
          _buildProgressIndicator(),
          const SizedBox(height: 20),
          _buildInstruction(),
        ],
      ),
    );
  }

  /// Xây dựng heart icon với BPM
  Widget _buildHeartIcon() {
    return Obx(() {
      // Heart icon chuyển sang đỏ khi đang đo và có BPM > 0
      // Ban đầu là dark blue với opacity, sau đó chuyển sang đỏ
      final heartColor = controller.isMeasuring && controller.bpm > 0
          ? Colors.red
          : AppColors.cardBackground.withOpacity(0.8);

      return SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Heart icon lớn với shadow để nổi bật
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: heartColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(Icons.favorite, size: 200, color: heartColor),
            ),
            // Text BPM bên trong heart
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.bpm.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'BMP',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Xây dựng progress indicator
  Widget _buildProgressIndicator() {
    return Obx(() {
      // Nếu chưa detect được tay, hiển thị thông báo
      if (!controller.isFingerDetected) {
        return Column(
          children: [
            Text(
              AppStrings.coverCameraInstruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.0,
                backgroundColor: AppColors.loadingBarInactive,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                minHeight: 4,
              ),
            ),
          ],
        );
      }

      // Đã detect được tay, hiển thị progress
      final progressPercent = (controller.progress * 100).toInt();
      return Column(
        children: [
          Text(
            '${AppStrings.measuring} ($progressPercent%)',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: controller.progress,
              backgroundColor: AppColors.loadingBarInactive,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 4,
            ),
          ),
        ],
      );
    });
  }

  /// Xây dựng instruction text
  Widget _buildInstruction() {
    return Text(
      AppStrings.measureInstruction,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
    );
  }
}
