import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final isDrinkMode = controller.isDrinkWaterMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isDrinkMode
            ? _buildDrinkSummary()
            : Obx(() {
                // Truy cập Rx để GetX biết cần rebuild khi dữ liệu report thay đổi
                final period = controller.selectedPeriod;
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
                      if (period == PeriodType.day)
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

  /// Summary cho chế độ drink water: Goal(ml) - Cup(ml) - Remind
  Widget _buildDrinkSummary() {
    return Obx(() {
      // Dùng reloadToken để tạo key, buộc FutureBuilder chạy lại khi reload
      final token = controller.reloadToken;

      return FutureBuilder<_DrinkSummaryData>(
        key: ValueKey(token),
        future: _loadDrinkSummaryData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.loadingBarInactive,
                ),
              ),
            );
          }

          final data = snapshot.data!;

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
                  AppAssets.iconGoalDrink,
                  data.goal.toString(),
                  AppStrings.goalMl,
                ),
                _buildMetric(
                  AppAssets.iconMlDrink,
                  data.cupCapacity.toString(),
                  AppStrings.cupMl,
                ),
                _buildMetric(
                  AppAssets.iconTimeDrink,
                  data.remindText,
                  AppStrings.remindLabel,
                ),
              ],
            ),
          );
        },
      );
    });
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

/// Data tóm tắt cho report drink water
class _DrinkSummaryData {
  final int goal;
  final int cupCapacity;
  final String remindText;

  _DrinkSummaryData({
    required this.goal,
    required this.cupCapacity,
    required this.remindText,
  });
}

/// Load drink water settings từ SharedPreferences
Future<_DrinkSummaryData> _loadDrinkSummaryData() async {
  const keyGoal = 'drink_water_goal';
  const keyCup = 'drink_water_cup_capacity';
  const keyInterval = 'drink_water_interval';
  const keyIntervalType = 'drink_water_interval_type';

  final prefs = await SharedPreferences.getInstance();

  final goal = prefs.getInt(keyGoal) ?? 2000;
  final cupCapacity = prefs.getInt(keyCup) ?? 250;
  final interval = prefs.getInt(keyInterval) ?? 2;
  final intervalType = prefs.getString(keyIntervalType) ?? 'hours';

  final unit = intervalType == 'hours' ? 'Hour' : 'Min';
  final remindText = '$interval $unit';

  return _DrinkSummaryData(
    goal: goal,
    cupCapacity: cupCapacity,
    remindText: remindText,
  );
}
