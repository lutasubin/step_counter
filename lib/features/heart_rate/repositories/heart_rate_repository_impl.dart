import 'package:step_counter/features/heart_rate/model/heart_rate_model.dart';
import 'package:step_counter/features/heart_rate/repositories/heart_rate_database.dart';
import 'package:step_counter/features/heart_rate/repositories/heart_rate_repository.dart';

/// Implementation của HeartRateRepository
class HeartRateRepositoryImpl implements HeartRateRepository {
  final HeartRateDatabase _database = HeartRateDatabase();

  @override
  Future<int> saveHeartRate(HeartRateModel heartRate) async {
    return await _database.insertHeartRate(
      dateTime: heartRate.dateTime,
      bpm: heartRate.bpm,
      status: heartRate.status,
      normalRange: heartRate.normalRange,
    );
  }

  @override
  Future<List<HeartRateModel>> getHeartRates() async {
    final maps = await _database.getAllHeartRates();
    return maps.map((map) => HeartRateModel.fromDatabase(map)).toList();
  }

  @override
  Future<HeartRateModel?> getHeartRateById(int id) async {
    final map = await _database.getHeartRateById(id);
    return map != null ? HeartRateModel.fromDatabase(map) : null;
  }

  @override
  Future<List<HeartRateModel>> getTodayHeartRate() async {
    final maps = await _database.getTodayHeartRates();
    return maps.map((map) => HeartRateModel.fromDatabase(map)).toList();
  }

  @override
  Future<bool> deleteHeartRate(int id) async {
    final result = await _database.deleteHeartRate(id);
    return result > 0;
  }

  @override
  Future<bool> deleteAllHeartRates() async {
    final result = await _database.deleteAllHeartRates();
    return result > 0;
  }
}
