import 'package:get/get.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/blood_pressure/model/blood_pressure_model.dart';
import 'package:step_counter/features/blood_pressure/repositories/blood_pressure_repository.dart';

/// Controller quản lý logic của blood pressure screen
class BloodPressureController extends GetxController {
  final BloodPressureRepository _repository = getIt<BloodPressureRepository>();
  final _bloodPressures = <BloodPressureModel>[].obs;
  final _isLoading = false.obs;

  /// Đang load
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadBloodPressures();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh khi vào màn hình để đảm bảo dữ liệu mới nhất
    refreshBloodPressures();
  }

  /// Danh sách blood pressures
  List<BloodPressureModel> get bloodPressures => _bloodPressures;

  /// Blood pressure hiện tại (mới nhất)
  BloodPressureModel? get currentBloodPressure {
    if (_bloodPressures.isEmpty) return null;
    return _bloodPressures.first;
  }

  /// Load dữ liệu blood pressures từ SQLite
  Future<void> _loadBloodPressures() async {
    try {
      _isLoading.value = true;
      final bloodPressures = await _repository.getBloodPressures();
      _bloodPressures.value = bloodPressures;
    } catch (e) {
      // Nếu có lỗi, để danh sách rỗng và log error
      _bloodPressures.value = [];
      print('Error loading blood pressures: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh dữ liệu blood pressures (public method)
  Future<void> refreshBloodPressures() async {
    await _loadBloodPressures();
  }
}
