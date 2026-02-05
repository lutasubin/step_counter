import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/splash/service/splash_service.dart';

/// Widget bottom navigation bar
class HomeBottomNavWidget extends StatelessWidget {
  const HomeBottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final currentRoute = Get.currentRoute;
    // Check cả homeFirst và home để xác định active state
    final isHomeActive = currentRoute == RouteNames.home ||
        currentRoute == RouteNames.homeFirst;
    final isSettingActive = currentRoute == RouteNames.setting;

    return Container(
      padding: EdgeInsets.only(bottom: padding.bottom + 8, top: 16),
      decoration: const BoxDecoration(color: AppColors.cardBackground),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHomeNavItem(AppAssets.iconHome, isHomeActive),
          _buildNavItem(
            AppAssets.iconSetting,
            isSettingActive,
            RouteNames.setting,
          ),
        ],
      ),
    );
  }

  /// Xây dựng home nav item với logic điều hướng thông minh
  Widget _buildHomeNavItem(String iconPath, bool isActive) {
    return InkWell(
      onTap: () async {
        if (!isActive) {
          // Check xem đã hoàn thành trải nghiệm homeFirst chưa
          final splashService = getIt<SplashService>();
          final hasCompletedHomeFirst = await splashService.hasCompletedHomeFirst();
          
          if (!hasCompletedHomeFirst) {
            // Chưa hoàn thành homeFirst → đi đến homeFirst
            Get.offNamed(RouteNames.homeFirst);
          } else {
            // Đã hoàn thành homeFirst → đi đến home
            Get.offNamed(RouteNames.home);
          }
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
