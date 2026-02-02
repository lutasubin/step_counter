import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/report/viewmodels/report_controller.dart';

/// Widget hiển thị số bước chân
class ReportStepDisplayWidget extends StatelessWidget {
  final ReportController controller;

  const ReportStepDisplayWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedPeriod == PeriodType.day) {
        // Với Day view, hiển thị tổng số bước của ngày, không phải chỉ khoảng đầu tiên
        final steps = controller.getTotalSteps();
        return _buildDayView(steps);
      } else {
        final avgSteps = controller.getAverageSteps().toInt();
        final totalSteps = controller.getTotalSteps();
        return _buildWeekMonthView(avgSteps, totalSteps);
      }
    });
  }

  Widget _buildDayView(int steps) {
    return Column(
      children: [
        Text(
          '$steps',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
            fontSize: 48,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.step,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekMonthView(int avgSteps, int totalSteps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                '$avgSteps',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.avgPerDay,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                _formatNumberWithComma(totalSteps),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.totalStep,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Format số với dấu phẩy (ví dụ: 12,268)
  String _formatNumberWithComma(int number) {
    final numberStr = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < numberStr.length; i++) {
      if (i > 0 && (numberStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(numberStr[i]);
    }
    return buffer.toString();
  }
}
