import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_date_picker_widget.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_number_pickers_widget.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_result_card_widget.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_save_button_widget.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/new_blood_pressure_header_widget.dart';

/// Màn hình New blood pressure
class NewBloodPressureView extends StatelessWidget {
  const NewBloodPressureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: [
            const NewBloodPressureHeaderWidget(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BloodPressureDatePickerWidget(),
                    const SizedBox(height: 16),
                    const BloodPressureNumberPickersWidget(),
                    const SizedBox(height: 16),
                    const BloodPressureResultCardWidget(),
                  ],
                ),
              ),
            ),
            const BloodPressureSaveButtonWidget(),
          ],
        ),
      ),
    );
  }
}
