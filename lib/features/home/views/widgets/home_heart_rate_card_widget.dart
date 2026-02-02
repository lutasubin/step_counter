import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';
import 'package:step_counter/features/heart_rate/model/heart_rate_model.dart';

/// Widget card hiển thị heart rate trên home screen
class HomeHeartRateCardWidget extends StatelessWidget {
  const HomeHeartRateCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final heartRate = controller.latestHeartRate;
      if (heartRate == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildContent(heartRate),
          ],
        ),
      );
    });
  }

  /// Xây dựng header với icon, title và arrow
  Widget _buildHeader() {
    return Row(
      children: [
        Image.asset(AppAssets.iconHeartCard, width: 24, height: 24),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Heart rate',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.buttonOrange,
          size: 16,
        ),
      ],
    );
  }

  /// Lấy màu dựa trên status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return const Color(0xFF15D254);
      case 'low':
        return Colors.blue;
      case 'elevated':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return const Color(0xFF15D254);
    }
  }

  /// Xây dựng content với icon graphic bên trái và data card bên phải
  Widget _buildContent(HeartRateModel heartRate) {
    final statusColor = _getStatusColor(heartRate.status);
    final timeText = DateFormat('h:mm a').format(heartRate.dateTime);

    return Row(
      children: [
        // Bên trái: Graphic icon (heart illustration)
        Expanded(
          flex: 2,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              AppAssets.iconHeartCard,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Bên phải: Content card với background homeBackground
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors
                  .homeBackground, // Background homeBackground cho content card
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status với green square
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      heartRate.status,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // BPM với BMP và time trong cùng một Row (dùng FittedBox để tránh overflow)
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Số BPM lớn
                      Text(
                        '${heartRate.bpm}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // BMP (hơi thấp hơn số)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: const Text(
                          'BMP',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                      ),
                      // Đường phân cách dọc màu trắng
                      Container(
                        width: 1,
                        height: 20,
                        color: AppColors.textPrimary,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      // Time
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          timeText,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Record button
                Center(
                  child: SizedBox(
                    width: 128,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(RouteNames.heartRate);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardBackground,
                        side: BorderSide(
                          color: AppColors.loadingBarInactive,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        AppStrings.record,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
