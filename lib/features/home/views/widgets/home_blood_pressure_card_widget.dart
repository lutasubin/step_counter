import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';
import 'package:step_counter/features/blood_pressure/model/blood_pressure_model.dart';

/// Widget card hiển thị blood pressure trên home screen
class HomeBloodPressureCardWidget extends StatelessWidget {
  const HomeBloodPressureCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (!controller.hasBloodPressureData) {
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
            _buildContent(controller.latestBloodPressure),
          ],
        ),
      );
    });
  }

  /// Xây dựng header với icon, title và arrow
  Widget _buildHeader() {
    return Row(
      children: [
        Image.asset(AppAssets.iconBloodCard, width: 24, height: 24),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Blood pressure',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Icon arrow có thể bấm để vào màn danh sách Blood pressure
        GestureDetector(
          onTap: () {
            Get.toNamed(RouteNames.bloodPressure);
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.buttonOrange,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// Lấy màu dựa trên status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hypotension':
        return Colors.blue;
      case 'normal':
        return const Color(0xFF15D254);
      case 'elevated':
        return Colors.yellow;
      case 'stage 1':
        return const Color(0xFFFFA500);
      case 'stage 2':
        return const Color(0xFFFF6B35);
      case 'hypertensive':
        return Colors.red;
      case 'low':
        return Colors.blue;
      case 'high':
        return Colors.red;
      default:
        return const Color(0xFF15D254);
    }
  }

  /// Xây dựng content với icon graphic bên trái và data card bên phải
  Widget _buildContent(BloodPressureModel? bloodPressure) {
    // Nếu không có data, hiển thị "No data today"
    if (bloodPressure == null) {
      return Row(
        children: [
          // Bên trái: Graphic icon (blood pressure illustration)
          Expanded(
            flex: 2,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(AppAssets.iconBloodCard, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 16),
          // Bên phải: Content card với background homeBackground
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.homeBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "No data today" text
                  Text(
                    'No data today',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Record button -> chuyển đến màn tạo record mới (New blood pressure)
                  SizedBox(
                    width: 128,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(RouteNames.newBloodPressure);
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
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Có data, hiển thị bình thường
    final statusColor = _getStatusColor(bloodPressure.status);
    final timeText = DateFormat('h:mm a').format(bloodPressure.dateTime);

    return Row(
      children: [
        // Bên trái: Graphic icon (blood pressure illustration)
        Expanded(
          flex: 2,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(AppAssets.iconBloodCard, fit: BoxFit.contain),
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
                      bloodPressure.status,
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
                // Values với time trong cùng một Row (dùng FittedBox để tránh overflow)
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Systolic/Diastolic
                      Text(
                        '${bloodPressure.systolic}/${bloodPressure.diastolic}',
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

                // Record button -> chuyển đến màn tạo record mới (New blood pressure)
                Center(
                  child: SizedBox(
                    width: 128,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(RouteNames.newBloodPressure);
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
