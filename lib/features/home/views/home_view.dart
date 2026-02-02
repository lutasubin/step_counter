import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';
import 'package:step_counter/features/home/views/widgets/activity_summary_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_bottom_nav_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_header_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_heart_rate_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_blood_pressure_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/home_drink_water_card_widget.dart';
import 'package:step_counter/features/home/views/widgets/try_widget_card_widget.dart';

/// Màn hình home
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    // Refresh dữ liệu khi quay lại home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshHomeCardsData();
    });

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeaderWidget(),
            Expanded(child: _buildContent(controller)),
            const HomeBottomNavWidget(),
          ],
        ),
      ),
    );
  }

  /// Xây dựng nội dung scrollable
  Widget _buildContent(HomeController controller) {
    return Obx(() {
      // Lấy danh sách cards có data và visible, sắp xếp theo thứ tự đã lưu
      final visibleCards = controller.cardOrder
          .where((cardType) => controller.shouldShowCard(cardType))
          .toList();

      return SingleChildScrollView(
        child: Column(
          children: [
            const ActivitySummaryCardWidget(),
            // ReorderableListView cho các home cards
            if (visibleCards.isNotEmpty)
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  controller.updateCardOrder(oldIndex, newIndex);
                },
                // Khi giữ và kéo card, proxyDecorator làm card sáng lên và hơi lắc
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final t = Curves.easeInOut.transform(animation.value);
                      final scale = 1.0 + 0.04 * t;
                      final angle = 0.02 * (1 - t);
                      return Transform.scale(
                        scale: scale,
                        child: Transform.rotate(
                          angle: angle,
                          child: Opacity(opacity: 0.95, child: child),
                        ),
                      );
                    },
                    child: child,
                  );
                },
                children: visibleCards.map((cardType) {
                  return _buildDraggableCard(
                    key: ValueKey(cardType),
                    cardType: cardType,
                    controller: controller,
                  );
                }).toList(),
              ),
            const TryWidgetCardWidget(),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  /// Xây dựng card có thể drag & drop và dismiss
  Widget _buildDraggableCard({
    required Key key,
    required HomeCardType cardType,
    required HomeController controller,
  }) {
    Widget cardWidget;
    switch (cardType) {
      case HomeCardType.heartRate:
        cardWidget = const HomeHeartRateCardWidget();
        break;
      case HomeCardType.bloodPressure:
        cardWidget = const HomeBloodPressureCardWidget();
        break;
      case HomeCardType.drinkWater:
        cardWidget = const HomeDrinkWaterCardWidget();
        break;
    }

    return Dismissible(
      key: key,
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      onDismissed: (direction) {
        controller.removeCard(cardType);
        Get.snackbar(
          'Đã Ẩn',
          'Card đã được ẩn. Bạn có thể khôi phục trong Add widget',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.black.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      },
      child: cardWidget,
    );
  }
}
