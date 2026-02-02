import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/report/viewmodels/report_controller.dart';

/// Widget hiển thị summary metrics
class ReportSummaryMetricsWidget extends StatelessWidget {
  final ReportController controller;

  const ReportSummaryMetricsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Obx(() {
          final calories = controller.getTotalCalories();
          final distance = controller.getTotalDistance();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.metricsBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  AppAssets.iconFire,
                  calories.toStringAsFixed(1),
                  AppStrings.kcal,
                ),
                _buildMetric(
                  AppAssets.iconKilomet,
                  distance.toStringAsFixed(1),
                  AppStrings.km,
                ),
                if (controller.selectedPeriod == PeriodType.day)
                  _buildMetric(
                    AppAssets.iconTime,
                    _formatDuration(),
                    AppStrings.min,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMetric(String iconPath, String value, String unit) {
    return Column(
      children: [
        SvgPicture.asset(iconPath, width: 24, height: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDuration() {
    if (controller.activities.isEmpty) return '0h 0m';
    final totalSeconds = controller.activities
        .fold(0, (sum, activity) => sum + activity.durationSeconds);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
