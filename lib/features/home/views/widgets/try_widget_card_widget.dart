import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';

/// Widget card "Try Widgets!"
class TryWidgetCardWidget extends StatelessWidget {
  const TryWidgetCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildContent(screenSize),
          const SizedBox(width: 16),
          _buildWidgetIllustration(),
        ],
      ),
    );
  }

  /// Xây dựng nội dung bên trái
  Widget _buildContent(Size screenSize) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.tryWidgets,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.tryWidgetsDesc,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: screenSize.width * 0.4,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                AppStrings.addWidget,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng widget illustration
  Widget _buildWidgetIllustration() {
    return SvgPicture.asset(AppAssets.iconTryWidget, width: 100, height: 100);
  }
}
