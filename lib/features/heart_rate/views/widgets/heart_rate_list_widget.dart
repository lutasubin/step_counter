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

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.heartRates.length,
        itemBuilder: (context, index) {
          final heartRate = controller.heartRates[index];
          final isToday = _isToday(heartRate.dateTime);

          return Padding(
            padding: EdgeInsets.only(bottom: index < controller.heartRates.length - 1 ? 12 : 0),
            child: HeartRateCardWidget(
              heartRate: heartRate,
              isToday: isToday,
            ),
          );
        },
      );
    });
  }

  /// Kiểm tra xem có phải hôm nay không
  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
}
