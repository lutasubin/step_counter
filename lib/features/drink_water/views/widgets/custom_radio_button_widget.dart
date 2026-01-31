import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';

/// Widget radio button tùy chỉnh với checkmark màu trắng trong vòng tròn cam
class CustomRadioButtonWidget extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;

  const CustomRadioButtonWidget({
    super.key,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.buttonOrange
                : AppColors.textSecondary,
            width: 2,
          ),
          color: isSelected ? AppColors.buttonOrange : Colors.transparent,
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }
}
