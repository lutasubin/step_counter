import 'package:step_counter/features/splash/repositories/splash_repository.dart';

/// Implementation của SplashRepository
class SplashRepositoryImpl implements SplashRepository {
  @override
  Future<bool> isFirstLaunch() async {
    // TODO: Implement với shared_preferences hoặc storage khác
    return true;
  }

  @override
  Future<void> setFirstLaunchShown() async {
    // TODO: Implement với shared_preferences hoặc storage khác
  }
}
