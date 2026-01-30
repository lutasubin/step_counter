import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/heart_rate/viewmodels/heart_rate_controller.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_header_widget.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_list_widget.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_measure_button_widget.dart';

/// Màn hình Heart rate
class HeartRateView extends StatelessWidget {
  const HeartRateView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HeartRateController>();

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: [
            const HeartRateHeaderWidget(),
            Expanded(child: HeartRateListWidget(controller: controller)),
            const HeartRateMeasureButtonWidget(),
          ],
        ),
      ),
    );
  }
}
