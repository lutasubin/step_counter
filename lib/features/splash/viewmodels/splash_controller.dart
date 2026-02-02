import 'dart:async';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/splash/service/app_data_service.dart';
import 'package:step_counter/features/splash/service/splash_service.dart';

/// Controller quản lý logic của splash screen
class SplashController extends GetxController {
  final SplashService _splashService;
  final AppDataService _appDataService;
  final _loadingProgress = 0.0.obs;
  Timer? _loadingTimer;

  SplashController({
    SplashService? splashService,
    AppDataService? appDataService,
  }) : _splashService = splashService ?? getIt<SplashService>(),
       _appDataService = appDataService ?? getIt<AppDataService>();

  /// Tiến độ loading (0.0 - 1.0)
  double get loadingProgress => _loadingProgress.value;

  @override
  void onInit() {
    super.onInit();
    _initializeSplash();
  }

  /// Khởi tạo splash screen
  Future<void> _initializeSplash() async {
    _startLoading();
  }

  /// Bắt đầu animation loading
  void _startLoading() {
    _loadingProgress.value = 0.0;
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_loadingProgress.value >= 1.0) {
        timer.cancel();
        _navigateAfterSplash();
      } else {
        _loadingProgress.value += 0.02;
      }
    });
  }

  /// Điều hướng sau khi splash hoàn thành
  Future<void> _navigateAfterSplash() async {
    final hasSeenWelcome = await _splashService.hasSeenWelcome();
    if (!hasSeenWelcome) {
      // Chưa xem welcome → đi đến welcome
      _navigateToWelcome();
      return;
    }

    // Đã xem welcome → check dữ liệu
    final hasData = await _appDataService.hasAnyData();
    if (hasData) {
      // Có dữ liệu → đi đến home (màn hình đầy đủ)
      _navigateToHome();
    } else {
      // Chưa có dữ liệu → đi đến welcome (màn hình first time)
      _navigateToWelcome();
    }
  }

  /// Điều hướng đến màn hình welcome
  void _navigateToWelcome() {
    Get.offNamed(RouteNames.welcome);
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
