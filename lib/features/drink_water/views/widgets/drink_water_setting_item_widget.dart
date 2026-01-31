import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';

/// Widget hiển thị một setting item
class DrinkWaterSettingItemWidget extends StatelessWidget {
  final String title;
  final Widget valueWidget;

  const DrinkWaterSettingItemWidget({
    super.key,
    required this.title,
    required this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        valueWidget,
      ],
    );
  }
}
