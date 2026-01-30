import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/route_names.dart';

/// Dialog hiển thị thông tin các mức BPM
class HeartRateInfoDialog extends StatelessWidget {
  const HeartRateInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Information',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // BPM categories
            _buildCategory(
              color: const Color(0xFF4A90E2), // Light blue
              label: 'Low',
              range: 'BPM < 60',
            ),
            const SizedBox(height: 12),
            _buildCategory(
              color: const Color(0xFF4DD0E1), // Teal
              label: 'Normal - Low',
              range: 'BPM 60-74',
            ),
            const SizedBox(height: 12),
            _buildCategory(
              color: const Color(0xFF15D254), // Green
              label: 'Normal',
              range: 'BPM 75-89',
            ),
            const SizedBox(height: 12),
            _buildCategory(
              color: AppColors.buttonOrange, // Orange
              label: 'High',
              range: 'BPM 90-110',
            ),
            const SizedBox(height: 12),
            _buildCategory(
              color: Colors.red,
              label: 'Critical High',
              range: 'BPM > 110',
            ),
            const SizedBox(height: 24),
            // GOT IT button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Đóng dialog
                  // Quay lại màn hình Heart rate
                  Get.until((route) => route.settings.name == RouteNames.heartRate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'GOT IT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng một category item
  Widget _buildCategory({
    required Color color,
    required String label,
    required String range,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Text(
                range,
                style: const TextStyle(
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
}
