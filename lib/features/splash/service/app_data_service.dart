import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/blood_pressure/repositories/blood_pressure_repository.dart';
import 'package:step_counter/features/drink_water/repositories/drink_water_repository.dart';
import 'package:step_counter/features/heart_rate/repositories/heart_rate_repository.dart';
import 'package:step_counter/features/report/service/report_service.dart';

/// Service kiểm tra xem app đã có dữ liệu chưa
class AppDataService {
  final ReportService _reportService;
  final HeartRateRepository _heartRateRepository;
  final BloodPressureRepository _bloodPressureRepository;
  final DrinkWaterRepository _drinkWaterRepository;

  AppDataService({
    ReportService? reportService,
    HeartRateRepository? heartRateRepository,
    BloodPressureRepository? bloodPressureRepository,
    DrinkWaterRepository? drinkWaterRepository,
  }) : _reportService = reportService ?? getIt<ReportService>(),
       _heartRateRepository =
           heartRateRepository ?? getIt<HeartRateRepository>(),
       _bloodPressureRepository =
           bloodPressureRepository ?? getIt<BloodPressureRepository>(),
       _drinkWaterRepository =
           drinkWaterRepository ?? getIt<DrinkWaterRepository>();

  /// Kiểm tra xem app đã có dữ liệu chưa
  /// Trả về true nếu có ít nhất 1 trong các dữ liệu: steps, heart rate, blood pressure, drink water
  Future<bool> hasAnyData() async {
    try {
      // Check steps data (có activity nào không)
      final today = DateTime.now();
      final date = DateTime(today.year, today.month, today.day);
      final activity = await _reportService.getActivityByDate(date);
      if (activity != null && activity.steps > 0) {
        return true;
      }

      // Check heart rate data
      final heartRates = await _heartRateRepository.getHeartRates();
      if (heartRates.isNotEmpty) {
        return true;
      }

      // Check blood pressure data
      final bloodPressures = await _bloodPressureRepository.getBloodPressures();
      if (bloodPressures.isNotEmpty) {
        return true;
      }

      // Check drink water data
      final drinkWaterRecords = await _drinkWaterRepository.getAllRecords();
      if (drinkWaterRecords.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking app data: $e');
      return false;
    }
  }
}
