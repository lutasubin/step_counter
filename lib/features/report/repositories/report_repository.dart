import 'package:step_counter/features/report/model/daily_activity_model.dart';

/// Repository interface cho report
abstract class ReportRepository {
  /// Lưu dữ liệu hoạt động theo ngày
  Future<void> saveDailyActivity(DailyActivityModel activity);

  /// Lấy dữ liệu hoạt động theo ngày
  Future<DailyActivityModel?> getDailyActivity(DateTime date);

  /// Lấy danh sách dữ liệu trong khoảng thời gian
  Future<List<DailyActivityModel>> getActivitiesInRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Lấy tất cả dữ liệu
  Future<List<DailyActivityModel>> getAllActivities();
}
