import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';

/// Widget hiển thị khi chưa có dữ liệu heart rate
class HeartRateEmptyWidget extends StatelessWidget {
  const HeartRateEmptyWidget({super.key});

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
            child: Icon(
              Icons.list,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // Text "No records available!"
          Text(
            'No records available!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
