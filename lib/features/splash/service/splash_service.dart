import 'package:step_counter/features/splash/repositories/splash_repository.dart';

/// Service xử lý business logic của splash screen
class SplashService {
  final SplashRepository _repository;

  SplashService(this._repository);

  /// Kiểm tra đã xem welcome chưa
  Future<bool> hasSeenWelcome() async {
    return await _repository.hasSeenWelcome();
  }

  /// Đánh dấu đã xem welcome
  Future<void> setWelcomeSeen() async {
    await _repository.setWelcomeSeen();
  }

  /// Kiểm tra đã hoàn thành trải nghiệm homeFirst chưa
  Future<bool> hasCompletedHomeFirst() async {
    return await _repository.hasCompletedHomeFirst();
  }

  /// Đánh dấu đã hoàn thành trải nghiệm homeFirst
  Future<void> setHomeFirstCompleted() async {
    await _repository.setHomeFirstCompleted();
  }
}
