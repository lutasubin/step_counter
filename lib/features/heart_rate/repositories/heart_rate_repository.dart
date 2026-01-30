import 'package:step_counter/features/heart_rate/model/heart_rate_model.dart';

/// Interface cho HeartRateRepository
/// Định nghĩa các method để tương tác với heart rate data
abstract class HeartRateRepository {
  /// Lưu heart rate vào database
  Future<int> saveHeartRate(HeartRateModel heartRate);

  /// Lấy tất cả heart rates, sắp xếp theo date_time giảm dần
  Future<List<HeartRateModel>> getHeartRates();

  /// Lấy heart rate theo ID
  Future<HeartRateModel?> getHeartRateById(int id);

  /// Lấy heart rates của ngày hôm nay
  Future<List<HeartRateModel>> getTodayHeartRate();

  /// Xóa heart rate theo ID
  Future<bool> deleteHeartRate(int id);

  /// Xóa tất cả heart rates
  Future<bool> deleteAllHeartRates();
}
