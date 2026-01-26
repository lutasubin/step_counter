import 'package:get/get.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/splash/service/splash_service.dart';

/// Controller quản lý logic của welcome screen
class WelcomeController extends GetxController {
  final SplashService _splashService;

  WelcomeController({SplashService? splashService})
    : _splashService = splashService ?? getIt<SplashService>();

  /// Điều hướng đến màn hình home
  Future<void> navigateToHome() async {
    await _splashService.setWelcomeSeen();
    Get.offNamed(RouteNames.home);
  }
}
