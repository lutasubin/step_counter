/// Repository interface cho step counter
abstract class StepCounterRepository {
  /// Kiểm tra xem có quyền đếm bước không
  Future<bool> checkPermission();

  /// Yêu cầu quyền đếm bước
  Future<bool> requestPermission();

  /// Lấy số bước hiện tại từ sensor
  Future<int> getCurrentSteps();

  /// Lấy số bước từ lần khởi động app
  Stream<int> getStepStream();

  /// Reset số bước ban đầu (khi bắt đầu đếm mới)
  void resetInitialSteps();

  /// Lấy số bước hiện tại của ngày (từ pedometer, không reset)
  Future<int> getTodaySteps();
}
