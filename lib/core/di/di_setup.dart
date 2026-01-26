import 'package:get_it/get_it.dart';
import 'package:step_counter/features/splash/repositories/splash_repository.dart';
import 'package:step_counter/features/splash/repositories/splash_repository_impl.dart';
import 'package:step_counter/features/splash/service/splash_service.dart';

/// Dependency Injection setup
final getIt = GetIt.instance;

/// Khởi tạo dependency injection
void setupDI() {
  // Đăng ký repositories
  getIt.registerLazySingleton<SplashRepository>(() => SplashRepositoryImpl());

  // Đăng ký services
  getIt.registerLazySingleton<SplashService>(
    () => SplashService(getIt<SplashRepository>()),
  );
}
