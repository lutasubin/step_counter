import 'package:get/get.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/home/service/step_counter_service.dart';
import 'package:step_counter/features/home/views/home_view.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';
import 'package:step_counter/features/report/service/report_service.dart';
import 'package:step_counter/features/report/views/report_view.dart';
import 'package:step_counter/features/report/viewmodels/report_controller.dart';
import 'package:step_counter/features/setting/views/setting_view.dart';
import 'package:step_counter/features/setting/viewmodels/setting_controller.dart';
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
    GetPage(
      name: RouteNames.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: RouteNames.setting,
      page: () => const SettingView(),
      binding: SettingBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: RouteNames.report,
      page: () => const ReportView(),
      binding: ReportBinding(),
    ),
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

/// Binding cho HomeController - dùng lazyPut để tối ưu
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(getIt<StepCounterService>()),
    );
  }
}

/// Binding cho SettingController - dùng lazyPut để tối ưu
class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingController>(() => SettingController());
  }
}

/// Binding cho ReportController - dùng lazyPut để tối ưu
class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(
      () => ReportController(getIt<ReportService>()),
    );
  }
}
