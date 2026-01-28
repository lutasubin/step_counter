import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/home/views/widgets/home_bottom_nav_widget.dart';
import 'package:step_counter/features/setting/viewmodels/setting_controller.dart';
import 'package:step_counter/features/setting/views/widgets/setting_item_widget.dart';

/// Màn hình setting
class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingController>();

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildContent(controller)),
            const HomeBottomNavWidget(),
          ],
        ),
      ),
    );
  }

  /// Xây dựng header
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Text(
        AppStrings.settingTitle,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Xây dựng nội dung scrollable
  Widget _buildContent(SettingController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFirstCard(controller),
          _buildSecondCard(controller),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Xây dựng card đầu tiên
  Widget _buildFirstCard(SettingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SettingItemWidget(
            icon: Icons.language,
            title: AppStrings.language,
            onTap: controller.onLanguageTap,
          ),
          const SizedBox(height: 16),
          SettingItemWidget(
            icon: Icons.share,
            title: AppStrings.share,
            onTap: controller.onShareTap,
          ),
          const SizedBox(height: 16),
          SettingItemWidget(
            icon: Icons.star,
            title: AppStrings.rateUs,
            onTap: controller.onRateUsTap,
          ),
        ],
      ),
    );
  }

  /// Xây dựng card thứ hai
  Widget _buildSecondCard(SettingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SettingItemWidget(
            icon: Icons.description,
            title: AppStrings.termsOfUse,
            onTap: controller.onTermsOfUseTap,
          ),
          const SizedBox(height: 16),
          SettingItemWidget(
            icon: Icons.privacy_tip,
            title: AppStrings.privacyPolicy,
            onTap: controller.onPrivacyPolicyTap,
          ),
        ],
      ),
    );
  }
}
