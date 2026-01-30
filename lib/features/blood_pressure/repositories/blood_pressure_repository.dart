import 'package:step_counter/features/blood_pressure/model/blood_pressure_model.dart';

/// Repository interface cho blood pressure data operations
abstract class BloodPressureRepository {
  /// Lưu blood pressure
  Future<void> saveBloodPressure(BloodPressureModel bloodPressure);

  /// Lấy tất cả blood pressures
  Future<List<BloodPressureModel>> getBloodPressures();

  /// Lấy blood pressure theo ID
  Future<BloodPressureModel?> getBloodPressureById(int id);

  /// Lấy blood pressure hôm nay (mới nhất)
  Future<BloodPressureModel?> getTodayBloodPressure();

  /// Xóa blood pressure theo ID
  Future<void> deleteBloodPressure(int id);

  /// Xóa tất cả blood pressures
  Future<void> deleteAllBloodPressures();
}
