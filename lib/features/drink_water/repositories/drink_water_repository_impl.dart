import 'package:step_counter/features/drink_water/model/drink_water_record_model.dart';
import 'package:step_counter/features/drink_water/repositories/drink_water_database.dart';
import 'package:step_counter/features/drink_water/repositories/drink_water_repository.dart';

/// Implementation của DrinkWaterRepository
class DrinkWaterRepositoryImpl implements DrinkWaterRepository {
  final DrinkWaterDatabase _database = DrinkWaterDatabase();

  @override
  Future<void> saveDrinkWaterRecord(DrinkWaterRecordModel record) async {
    await _database.insertDrinkWaterRecord(record);
  }

  @override
  Future<List<DrinkWaterRecordModel>> getAllRecords() async {
    return await _database.getAllRecords();
  }

  @override
  Future<List<DrinkWaterRecordModel>> getRecordsByDate(DateTime date) async {
    return await _database.getRecordsByDate(date);
  }

  @override
  Future<int> getTotalAmountByDate(DateTime date) async {
    return await _database.getTotalAmountByDate(date);
  }

  @override
  Future<DrinkWaterRecordModel?> getRecordById(int id) async {
    return await _database.getRecordById(id);
  }

  @override
  Future<void> deleteRecord(int id) async {
    await _database.deleteRecord(id);
  }

  @override
  Future<void> deleteAllRecords() async {
    await _database.deleteAllRecords();
  }
}
