import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';

/// Widget bottom navigation bar
class HomeBottomNavWidget extends StatelessWidget {
  const HomeBottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Container(
      padding: EdgeInsets.only(
        bottom: padding.bottom + 8,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(AppAssets.iconHome, true),
          _buildNavItem(AppAssets.iconSetting, false),
        ],
      ),
    );
  }

  /// Xây dựng nav item
  Widget _buildNavItem(String iconPath, bool isActive) {
    return SvgPicture.asset(
      iconPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isActive ? AppColors.textPrimary : AppColors.textSecondary,
        BlendMode.srcIn,
      ),
    );
  }
}
