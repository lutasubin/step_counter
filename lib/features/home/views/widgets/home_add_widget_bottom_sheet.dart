import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';

/// Bottom sheet cho nút Add widget - dùng để bật/tắt các home cards
class HomeAddWidgetBottomSheet extends StatelessWidget {
  const HomeAddWidgetBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      // Build danh sách items mỗi lần state thay đổi
      final items = <_AddWidgetItem>[
        _AddWidgetItem(
          type: HomeCardType.heartRate,
          title: 'Heart rate',
          hasData: controller.hasHeartRateData,
        ),
        _AddWidgetItem(
          type: HomeCardType.bloodPressure,
          title: 'Blood pressure',
          hasData: controller.hasBloodPressureData,
        ),
        _AddWidgetItem(
          type: HomeCardType.drinkWater,
          title: 'Drink water',
          hasData: controller.hasDrinkWaterData,
        ),
      ];

      return Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.loadingBarInactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => _buildItemRow(controller, item)),
          ],
        ),
      );
    });
  }

  Widget _buildItemRow(HomeController controller, _AddWidgetItem item) {
    final isVisible = controller.isCardVisible(item.type);
    final enabled = item.hasData;
    final switchValue = enabled ? isVisible : false;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        item.title,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: !enabled
          ? const Text(
              'Chưa có dữ liệu hôm nay',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
      trailing: Switch(
        value: switchValue,
        onChanged: enabled
            ? (value) async {
                // Chỉ toggle khi trạng thái thực sự thay đổi
                if (value != isVisible) {
                  await controller.toggleCardVisibility(item.type);
                }
              }
            : null,
        activeThumbColor: AppColors.textPrimary,
        activeTrackColor: Color(0xFF15D254),
        inactiveTrackColor: AppColors.loadingBarInactive,
      ),
    );
  }
}

class _AddWidgetItem {
  final HomeCardType type;
  final String title;
  final bool hasData;

  const _AddWidgetItem({
    required this.type,
    required this.title,
    required this.hasData,
  });
}
