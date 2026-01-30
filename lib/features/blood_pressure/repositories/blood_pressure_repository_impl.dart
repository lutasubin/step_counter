import 'package:step_counter/features/blood_pressure/model/blood_pressure_model.dart';
import 'package:step_counter/features/blood_pressure/repositories/blood_pressure_database.dart';
import 'package:step_counter/features/blood_pressure/repositories/blood_pressure_repository.dart';

/// Implementation của BloodPressureRepository
class BloodPressureRepositoryImpl implements BloodPressureRepository {
  final BloodPressureDatabase _database = BloodPressureDatabase();

  @override
  Future<void> saveBloodPressure(BloodPressureModel bloodPressure) async {
    await _database.insertBloodPressure(bloodPressure);
  }

  @override
  Future<List<BloodPressureModel>> getBloodPressures() async {
    return await _database.getAllBloodPressures();
  }

  @override
  Future<BloodPressureModel?> getBloodPressureById(int id) async {
    return await _database.getBloodPressureById(id);
  }

  @override
  Future<BloodPressureModel?> getTodayBloodPressure() async {
    return await _database.getTodayBloodPressure();
  }

  @override
  Future<void> deleteBloodPressure(int id) async {
    await _database.deleteBloodPressure(id);
  }

  @override
  Future<void> deleteAllBloodPressures() async {
    await _database.deleteAllBloodPressures();
  }
}
