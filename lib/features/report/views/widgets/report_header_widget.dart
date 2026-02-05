import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/features/report/viewmodels/report_controller.dart';

/// Widget header của report screen
class ReportHeaderWidget extends StatelessWidget {
  const ReportHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();
    final title = controller.isDrinkWaterMode
        ? 'Report drink water'
        : AppStrings.reportCounter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (controller.isDrinkWaterMode)
            InkWell(
              onTap: () async {
                // Điều hướng sang màn cài đặt uống nước,
                // khi quay lại thì reload dữ liệu report drink
                final result = await Get.toNamed(RouteNames.drinkWaterSettings);
                if (result == true) {
                  await controller.reloadDrinkReport();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.settings,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
