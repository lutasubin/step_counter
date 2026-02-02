import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:step_counter/core/constants/app_colors.dart';

/// Widget card để track các chỉ số sức khỏe
class TrackCardWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback? onButtonPressed;

  const TrackCardWidget({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonColor,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildDescription(),
          const SizedBox(height: 16),
          _buildButton(),
        ],
      ),
    );
  }

  /// Xây dựng header với icon và title
  Widget _buildHeader() {
    return Row(
      children: [
        SvgPicture.asset(iconPath, width: 24, height: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.buttonOrange,
          size: 16,
        ),
      ],
    );
  }

  /// Xây dựng mô tả
  Widget _buildDescription() {
    return Text(
      description,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Xây dựng button với kích thước cố định 128x40 và căn giữa
  Widget _buildButton() {
    return Center(
      child: SizedBox(
        width: 128,
        height: 40,
        child: ElevatedButton(
          onPressed: onButtonPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
