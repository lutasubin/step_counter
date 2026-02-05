import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_counter/features/splash/repositories/splash_repository.dart';

/// Implementation của SplashRepository
class SplashRepositoryImpl implements SplashRepository {
  static const String _keyHasSeenWelcome = 'has_seen_welcome';
  static const String _keyHasCompletedHomeFirst = 'has_completed_home_first';

  @override
  Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenWelcome) ?? false;
  }

  @override
  Future<void> setWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenWelcome, true);
  }

  @override
  Future<bool> hasCompletedHomeFirst() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasCompletedHomeFirst) ?? false;
  }

  @override
  Future<void> setHomeFirstCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasCompletedHomeFirst, true);
  }
}
