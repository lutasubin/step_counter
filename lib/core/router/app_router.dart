import 'package:get/get.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/features/home/views/home_view.dart';
import 'package:step_counter/features/splash/views/splash_view.dart';
import 'package:step_counter/features/splash/viewmodels/splash_controller.dart';
import 'package:step_counter/features/welcome/views/welcome_view.dart';
import 'package:step_counter/features/welcome/viewmodels/welcome_controller.dart';

/// Quản lý routing của ứng dụng
class AppRouter {
  AppRouter._();

  /// Danh sách các routes
  static final List<GetPage> routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: RouteNames.welcome,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(name: RouteNames.home, page: () => const HomeView()),
  ];
}

/// Binding cho SplashController - dùng lazyPut để tối ưu
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}

/// Binding cho WelcomeController - dùng lazyPut để tối ưu
class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WelcomeController>(() => WelcomeController());
  }
}
