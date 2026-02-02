import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';
import 'package:step_counter/features/drink_water/views/widgets/custom_radio_button_widget.dart';

/// Widget bottom sheet cho interval
class IntervalBottomSheetWidget extends StatelessWidget {
  final DrinkWaterSettingsController controller;

  const IntervalBottomSheetWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          _buildOptionsList(context),
          _buildDoneButton(context, mediaQuery),
        ],
      ),
    );
  }

  /// Xây dựng title
  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Text(
        AppStrings.interval,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Xây dựng danh sách options
  Widget _buildOptionsList(BuildContext context) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: controller.intervalOptions.length,
        separatorBuilder: (context, index) => const Divider(
          color: AppColors.loadingBarInactive,
          height: 1,
          thickness: 1,
        ),
        itemBuilder: (context, index) {
          final value = controller.intervalOptions[index];
          return Obx(
            () => InkWell(
              onTap: () {
                controller.updateInterval(value);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$value hour',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    CustomRadioButtonWidget(
                      isSelected: controller.interval == value,
                      onTap: () {
                        controller.updateInterval(value);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Xây dựng button DONE
  Widget _buildDoneButton(BuildContext context, MediaQueryData mediaQuery) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, mediaQuery.padding.bottom + 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonOrange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            AppStrings.done,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
