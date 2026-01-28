import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/route_names.dart';

/// Widget bottom navigation bar
class HomeBottomNavWidget extends StatelessWidget {
  const HomeBottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final currentRoute = Get.currentRoute;
    final isHomeActive = currentRoute == RouteNames.home;
    final isSettingActive = currentRoute == RouteNames.setting;

    return Container(
      padding: EdgeInsets.only(bottom: padding.bottom + 8, top: 16),
      decoration: const BoxDecoration(color: AppColors.cardBackground),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(AppAssets.iconHome, isHomeActive, RouteNames.home),
          _buildNavItem(
            AppAssets.iconSetting,
            isSettingActive,
            RouteNames.setting,
          ),
        ],
      ),
    );
  }

  /// Xây dựng nav item
  Widget _buildNavItem(String iconPath, bool isActive, String route) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          Get.offNamed(route);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isActive ? AppColors.textPrimary : AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
