import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';

/// Widget hiển thị khi chưa có dữ liệu blood pressure
class BloodPressureEmptyWidget extends StatelessWidget {
  const BloodPressureEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon list (3 đường ngang)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.list, size: 48, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          // Text "No records available!"
          Text(
            AppStrings.noRecordsAvailable,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
