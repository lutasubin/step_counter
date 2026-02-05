/// Repository quản lý data của splash screen
abstract class SplashRepository {
  /// Kiểm tra xem đã xem welcome screen chưa
  Future<bool> hasSeenWelcome();

  /// Đánh dấu đã xem welcome screen
  Future<void> setWelcomeSeen();

  /// Kiểm tra xem đã hoàn thành trải nghiệm homeFirst chưa
  Future<bool> hasCompletedHomeFirst();

  /// Đánh dấu đã hoàn thành trải nghiệm homeFirst
  Future<void> setHomeFirstCompleted();
}
