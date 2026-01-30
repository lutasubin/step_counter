import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/features/blood_pressure/viewmodels/blood_pressure_controller.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_card_widget.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_empty_widget.dart';

/// Widget hiển thị danh sách blood pressure
class BloodPressureListWidget extends StatelessWidget {
  final BloodPressureController controller;

  const BloodPressureListWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.bloodPressures.isEmpty) {
        return const BloodPressureEmptyWidget();
      }

      return ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: controller.bloodPressures.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final bloodPressure = controller.bloodPressures[index];
          final isToday = index == 0 &&
              _isToday(bloodPressure.dateTime);

          return BloodPressureCardWidget(
            bloodPressure: bloodPressure,
            isToday: isToday,
          );
        },
      );
    });
  }

  /// Kiểm tra xem dateTime có phải hôm nay không
  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
}
