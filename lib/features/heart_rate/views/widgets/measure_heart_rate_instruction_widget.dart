import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';

/// Widget hiển thị hướng dẫn với phone và hand illustration
class MeasureHeartRateInstructionWidget extends StatelessWidget {
  const MeasureHeartRateInstructionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.coverCameraInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
                        fontFamily: 'Montserrat',color: AppColors.textPrimary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildIllustration(),
        ],
      ),
    );
  }

  /// Xây dựng illustration với phone và hand
  Widget _buildIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Phone PNG
        Image.asset(
          'assets/images/phone.png',
          width: 200,
          height: 300,
          fit: BoxFit.contain,
        ),
        // Hand PNG (positioned to cover camera)
        Positioned(
          bottom: 60,
          child: Image.asset(
            'assets/images/hand.png',
            width: 180,
            height: 280,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
