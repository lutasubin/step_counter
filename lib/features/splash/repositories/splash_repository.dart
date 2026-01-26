/// Repository quản lý data của splash screen
abstract class SplashRepository {
  /// Kiểm tra xem đã xem welcome screen chưa
  Future<bool> hasSeenWelcome();

  /// Đánh dấu đã xem welcome screen
  Future<void> setWelcomeSeen();
}
