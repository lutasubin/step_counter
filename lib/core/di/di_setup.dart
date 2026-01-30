import 'package:get_it/get_it.dart';
import 'package:step_counter/core/services/notification_service.dart';
import 'package:step_counter/features/blood_pressure/repositories/blood_pressure_repository.dart';
import 'package:step_counter/features/blood_pressure/repositories/blood_pressure_repository_impl.dart';
import 'package:step_counter/features/heart_rate/repositories/heart_rate_repository.dart';
import 'package:step_counter/features/heart_rate/repositories/heart_rate_repository_impl.dart';
import 'package:step_counter/features/heart_rate/service/heart_rate_measurement_service.dart';
import 'package:step_counter/features/home/repositories/step_counter_repository.dart';
import 'package:step_counter/features/home/repositories/step_counter_repository_impl.dart';
import 'package:step_counter/features/home/service/step_counter_service.dart';
import 'package:step_counter/features/report/repositories/report_repository.dart';
import 'package:step_counter/features/report/repositories/report_repository_impl.dart';
import 'package:step_counter/features/report/service/report_service.dart';
import 'package:step_counter/features/splash/repositories/splash_repository.dart';
import 'package:step_counter/features/splash/repositories/splash_repository_impl.dart';
import 'package:step_counter/features/splash/service/splash_service.dart';

/// Dependency Injection setup
final getIt = GetIt.instance;

/// Khởi tạo dependency injection
void setupDI() {
  // Đăng ký repositories
  getIt.registerLazySingleton<SplashRepository>(() => SplashRepositoryImpl());
  getIt.registerLazySingleton<StepCounterRepository>(
    () => StepCounterRepositoryImpl(),
  );
  getIt.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl());
  getIt.registerLazySingleton<HeartRateRepository>(
    () => HeartRateRepositoryImpl(),
  );
  getIt.registerLazySingleton<BloodPressureRepository>(
    () => BloodPressureRepositoryImpl(),
  );

  // Đăng ký services
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<SplashService>(
    () => SplashService(getIt<SplashRepository>()),
  );
  getIt.registerLazySingleton<StepCounterService>(
    () => StepCounterService(getIt<StepCounterRepository>()),
  );
  getIt.registerLazySingleton<ReportService>(
    () => ReportService(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton<HeartRateMeasurementService>(
    () => HeartRateMeasurementService(),
  );
}
