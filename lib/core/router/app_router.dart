import 'package:get/get.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/features/splash/views/splash_view.dart';

/// Quản lý routing của ứng dụng
class AppRouter {
  AppRouter._();

  /// Danh sách các routes
  static final List<GetPage> routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashView(),
    ),
    
  ];
}
