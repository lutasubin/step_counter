import 'dart:async';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/splash/service/splash_service.dart';

/// Controller quản lý logic của splash screen
class SplashController extends GetxController {
  final SplashService _splashService;
  final _loadingProgress = 0.0.obs;
  Timer? _loadingTimer;

  SplashController({SplashService? splashService})
      : _splashService = splashService ?? getIt<SplashService>();

  /// Tiến độ loading (0.0 - 1.0)
  double get loadingProgress => _loadingProgress.value;

  @override
  void onInit() {
    super.onInit();
    _initializeSplash();
  }

  /// Khởi tạo splash screen
  Future<void> _initializeSplash() async {
    final shouldShow = await _splashService.shouldShowSplash();
    if (shouldShow) {
      _startLoading();
    } else {
      _navigateToHome();
    }
  }

  /// Bắt đầu animation loading
  void _startLoading() {
    _loadingProgress.value = 0.0;
    _loadingTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        if (_loadingProgress.value >= 1.0) {
          timer.cancel();
          _completeSplash();
        } else {
          _loadingProgress.value += 0.02;
        }
      },
    );
  }

  /// Hoàn thành splash và điều hướng
  Future<void> _completeSplash() async {
    await _splashService.completeSplash();
    _navigateToHome();
  }

  /// Điều hướng đến màn hình chính
  void _navigateToHome() {
    Get.offNamed(RouteNames.home);
  }

  @override
  void onClose() {
    _loadingTimer?.cancel();
    super.onClose();
  }
}
