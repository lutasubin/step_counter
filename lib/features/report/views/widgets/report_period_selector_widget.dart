import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/report/viewmodels/report_controller.dart';

/// Widget chọn period (Day/Week/Month)
class ReportPeriodSelectorWidget extends StatelessWidget {
  final ReportController controller;

  const ReportPeriodSelectorWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            _buildPeriodButton(AppStrings.day, PeriodType.day),
            _buildPeriodButton(AppStrings.week, PeriodType.week),
            _buildPeriodButton(AppStrings.month, PeriodType.month),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, PeriodType period) {
    return Expanded(
      child: Obx(
        () => InkWell(
          onTap: () => controller.changePeriod(period),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: controller.selectedPeriod == period
                  ? Colors.white
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: controller.selectedPeriod == period
                    ? AppColors.buttonOrange
                    : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
