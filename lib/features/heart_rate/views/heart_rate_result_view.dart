import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/heart_rate/viewmodels/heart_rate_result_controller.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_result_header_widget.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_result_content_widget.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_result_disclaimer_widget.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_result_save_button_widget.dart';

/// Màn hình kết quả đo nhịp tim
class HeartRateResultView extends StatelessWidget {
  const HeartRateResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final bpm = Get.arguments as int? ?? 85;
    final controller = Get.find<HeartRateResultController>();
    controller.setBpm(bpm);

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: [
            const HeartRateResultHeaderWidget(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HeartRateResultContentWidget(controller: controller),
                    const SizedBox(height: 16),
                    const HeartRateResultDisclaimerWidget(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const HeartRateResultSaveButtonWidget(),
          ],
        ),
      ),
    );
  }
}
