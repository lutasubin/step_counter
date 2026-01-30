import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/features/heart_rate/viewmodels/heart_rate_controller.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_card_widget.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_empty_widget.dart';

/// Widget hiển thị danh sách heart rates
class HeartRateListWidget extends StatelessWidget {
  final HeartRateController controller;

  const HeartRateListWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Hiển thị loading indicator nếu đang load
      if (controller.isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Hiển thị empty state nếu không có dữ liệu
      if (controller.heartRates.isEmpty) {
        return const HeartRateEmptyWidget();
      }

      return ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: controller.heartRates.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final heartRate = controller.heartRates[index];
          // Card đầu tiên (mới nhất) luôn hiển thị như "Today"
          final isToday = index == 0;

          return HeartRateCardWidget(
            heartRate: heartRate,
            isToday: isToday,
          );
        },
      );
    });
  }

}
