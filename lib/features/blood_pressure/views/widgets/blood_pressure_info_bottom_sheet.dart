import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';

/// Bottom sheet thông báo với danh sách các category huyết áp
class BloodPressureInfoBottomSheet extends StatelessWidget {
  const BloodPressureInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.homeBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    AppStrings.information,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Danh sách các category
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCategoryItem(
                  Colors.blue,
                  AppStrings.hypotension,
                  'SYS < 90 or DIA < 60',
                ),
                const SizedBox(height: 16),
                _buildCategoryItem(
                  const Color(0xFF15D254),
                  AppStrings.normal,
                  'SYS 90-119 and DIA 60-79',
                ),
                const SizedBox(height: 16),
                _buildCategoryItem(
                  Colors.yellow,
                  AppStrings.elevated,
                  'SYS 120-129 and DIA 60-79',
                ),
                const SizedBox(height: 16),
                _buildCategoryItem(
                  const Color(0xFFFFA500),
                  AppStrings.hypotensionStage1,
                  'SYS 130-139 and DIA 80-89',
                ),
                const SizedBox(height: 16),
                _buildCategoryItem(
                  const Color(0xFFFF6B35),
                  AppStrings.hypotensionStage2,
                  'SYS 140-180 or DIA 90-120',
                ),
                const SizedBox(height: 16),
                _buildCategoryItem(
                  Colors.red,
                  AppStrings.hypotensive,
                  'SYS > 180 or DIA > 120',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // GOT IT Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Đóng bottom sheet và quay về màn hình blood pressure
                  Get.back(); // Đóng info bottom sheet
                  Get.back(); // Quay về màn hình blood pressure list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  AppStrings.gotIt,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng item category
  Widget _buildCategoryItem(Color color, String title, String range) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                range,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
