import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/heart_rate/viewmodels/measure_heart_rate_controller.dart';
import 'package:step_counter/features/heart_rate/views/widgets/measure_heart_rate_header_widget.dart';
import 'package:step_counter/features/heart_rate/views/widgets/measure_heart_rate_content_widget.dart';
import 'package:step_counter/features/heart_rate/views/widgets/measure_heart_rate_instruction_widget.dart';

/// Màn hình Measure heart rate
class MeasureHeartRateView extends StatelessWidget {
  const MeasureHeartRateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: GetBuilder<MeasureHeartRateController>(
          init: Get.find<MeasureHeartRateController>(),
          builder: (controller) {
            return Column(
              children: [
                const MeasureHeartRateHeaderWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MeasureHeartRateContentWidget(controller: controller),
                        const SizedBox(height: 40),
                        const MeasureHeartRateInstructionWidget(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
