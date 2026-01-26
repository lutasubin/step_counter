import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/splash/viewmodels/splash_controller.dart';
import 'package:step_counter/features/splash/views/widgets/splash_app_name_widget.dart';
import 'package:step_counter/features/splash/views/widgets/splash_icon_widget.dart';
import 'package:step_counter/features/splash/views/widgets/splash_loading_bar_widget.dart';

/// Màn hình splash screen
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: _buildContent(context, screenSize, padding, controller),
    );
  }

  /// Xây dựng nội dung màn hình
  Widget _buildContent(
    BuildContext context,
    Size screenSize,
    EdgeInsets padding,
    SplashController controller,
  ) {
    return Stack(
      children: [
        _buildCenterContent(),
        _buildLoadingBar(screenSize, padding, controller),
      ],
    );
  }

  /// Xây dựng nội dung ở giữa màn hình
  Widget _buildCenterContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SplashIconWidget(),
          const SizedBox(height: 24),
          const SplashAppNameWidget(),
        ],
      ),
    );
  }

  /// Xây dựng thanh loading ở dưới cùng
  Widget _buildLoadingBar(
    Size screenSize,
    EdgeInsets padding,
    SplashController controller,
  ) {
    return Positioned(
      bottom: padding.bottom + 40,
      left: 0,
      right: 0,
      child: SplashLoadingBarWidget(
        controller: controller,
        screenWidth: screenSize.width,
      ),
    );
  }
}
