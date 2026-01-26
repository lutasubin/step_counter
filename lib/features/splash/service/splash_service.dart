import 'package:step_counter/features/splash/repositories/splash_repository.dart';

/// Service xử lý business logic của splash screen
class SplashService {
  final SplashRepository _repository;

  SplashService(this._repository);

  /// Kiểm tra có cần hiển thị splash không
  Future<bool> shouldShowSplash() async {
    return await _repository.isFirstLaunch();
  }

  /// Đánh dấu đã hoàn thành splash
  Future<void> completeSplash() async {
    await _repository.setFirstLaunchShown();
  }
}
