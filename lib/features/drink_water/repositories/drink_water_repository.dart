import 'package:step_counter/features/drink_water/model/drink_water_record_model.dart';

/// Repository interface cho drink water data operations
abstract class DrinkWaterRepository {
  /// Lưu record uống nước
  Future<void> saveDrinkWaterRecord(DrinkWaterRecordModel record);

  /// Lấy tất cả records, sắp xếp theo date_time giảm dần
  Future<List<DrinkWaterRecordModel>> getAllRecords();

  /// Lấy records theo ngày
  Future<List<DrinkWaterRecordModel>> getRecordsByDate(DateTime date);

  /// Lấy tổng số ml đã uống trong ngày
  Future<int> getTotalAmountByDate(DateTime date);

  /// Lấy record theo ID
  Future<DrinkWaterRecordModel?> getRecordById(int id);

  /// Xóa record theo ID
  Future<void> deleteRecord(int id);

  /// Xóa tất cả records
  Future<void> deleteAllRecords();
}
