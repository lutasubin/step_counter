import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/blood_pressure/viewmodels/blood_pressure_controller.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_header_widget.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_list_widget.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_record_button_widget.dart';

/// Màn hình Blood pressure
class BloodPressureView extends StatelessWidget {
  const BloodPressureView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BloodPressureController>();

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: [
            const BloodPressureHeaderWidget(),
            Expanded(child: BloodPressureListWidget(controller: controller)),
            const BloodPressureRecordButtonWidget(),
          ],
        ),
      ),
    );
  }
}
