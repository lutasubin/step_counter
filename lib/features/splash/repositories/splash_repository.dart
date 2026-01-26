/// Repository quản lý data của splash screen
abstract class SplashRepository {
  /// Kiểm tra xem đã hiển thị splash lần đầu chưa
  Future<bool> isFirstLaunch();

  /// Đánh dấu đã hiển thị splash
  Future<void> setFirstLaunchShown();
}
