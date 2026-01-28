import 'package:step_counter/features/home/repositories/step_counter_repository.dart';

/// Service xử lý logic đếm bước chân
class StepCounterService {
  final StepCounterRepository _repository;

  StepCounterService(this._repository);

  /// Kiểm tra và yêu cầu quyền
  Future<bool> checkAndRequestPermission() async {
    final hasPermission = await _repository.checkPermission();
    if (!hasPermission) {
      return await _repository.requestPermission();
    }
    return true;
  }

  /// Lấy stream số bước
  Stream<int> getStepStream() {
    return _repository.getStepStream();
  }

  /// Reset số bước ban đầu
  void resetInitialSteps() {
    _repository.resetInitialSteps();
  }

  /// Tính calo đốt (công thức: steps * 0.04 kcal)
  double calculateCalories(int steps) {
    return steps * 0.04;
  }

  /// Tính khoảng cách (công thức: steps * 0.0008 km, mỗi bước ~0.8m)
  double calculateDistance(int steps) {
    return steps * 0.0008;
  }

  /// Format thời gian từ giây sang "Xh Ym"
  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Lấy số bước hiện tại của ngày
  Future<int> getTodaySteps() async {
    return await _repository.getTodaySteps();
  }
}
