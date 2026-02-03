import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/drink_water/model/drink_water_record_model.dart';
import 'package:step_counter/features/drink_water/repositories/drink_water_repository.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';

/// Widget card hiển thị drink water trên home screen
class HomeDrinkWaterCardWidget extends StatelessWidget {
  const HomeDrinkWaterCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (!controller.hasDrinkWaterData) {
        return const SizedBox.shrink();
      }

      final currentAmount = controller.drinkWaterCurrentAmount;
      final goal = controller.drinkWaterGoal;
      final cupCapacity = controller.drinkWaterCupCapacity;
      final progress = goal > 0 ? (currentAmount / goal).clamp(0.0, 1.0) : 0.0;

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
            _buildContent(currentAmount, goal, progress, cupCapacity),
          ],
        ),
      );
    });
  }

  /// Xây dựng header với icon, title và arrow (có thể tap để điều hướng)
  Widget _buildHeader() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteNames.drinkWaterSettings);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SvgPicture.asset(AppAssets.iconDrinkCard, width: 15, height: 15),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Drink water',
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
        ),
      ),
    );
  }

  /// Xây dựng content với progress circle bên trái và data card bên phải
  Widget _buildContent(
    int currentAmount,
    int goal,
    double progress,
    int cupCapacity,
  ) {
    final percentage = (progress * 100).toStringAsFixed(0);

    return Row(
      children: [
        // Bên trái: Progress circle với icon và phần trăm
        Expanded(
          flex: 2,
          child: SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle (màu xanh nước biển #2F7BFF)
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.loadingBarInactive,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2F7BFF),
                    ),
                  ),
                ),
                // Center: Icon và phần trăm
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon (giữ nguyên màu gốc)
                    SvgPicture.asset(
                      AppAssets.iconDrinkCard,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(height: 4),
                    // Phần trăm (màu xanh nước biển #2F7BFF)
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xFF2F7BFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
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
                // Amount và goal
                Text(
                  '$currentAmount/$goal ml',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                // Quick Add button
                Center(
                  child: SizedBox(
                    width: 128,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _addDrinkWater(cupCapacity);
                      },
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.buttonBlue,
                        size: 20,
                      ),
                      label: Text(
                        '${cupCapacity}ml',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: AppColors.buttonBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  /// Thêm drink water record vào database
  Future<void> _addDrinkWater(int amount) async {
    try {
      final repository = getIt<DrinkWaterRepository>();
      final now = DateTime.now();

      // Tạo record mới
      final record = DrinkWaterRecordModel(dateTime: now, amount: amount);

      // Lưu vào database
      await repository.saveDrinkWaterRecord(record);

      // Refresh HomeController để cập nhật UI real-time
      final homeController = Get.find<HomeController>();
      await homeController.refreshHomeCardsData();
    } catch (e) {
      print('Error adding drink water: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể thêm nước. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
