import 'package:get/get.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/heart_rate/model/heart_rate_model.dart';
import 'package:step_counter/features/heart_rate/repositories/heart_rate_repository.dart';

/// Controller quản lý logic của heart rate screen
class HeartRateController extends GetxController {
  final HeartRateRepository _repository = getIt<HeartRateRepository>();
  final _heartRates = <HeartRateModel>[].obs;
  final _isLoading = false.obs;

  /// Đang load
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadHeartRates();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh khi vào màn hình để đảm bảo dữ liệu mới nhất
    refreshHeartRates();
  }

  /// Danh sách heart rates
  List<HeartRateModel> get heartRates => _heartRates;

  /// Heart rate hiện tại (mới nhất)
  HeartRateModel? get currentHeartRate {
    if (_heartRates.isEmpty) return null;
    return _heartRates.first;
  }

  /// Load dữ liệu heart rates từ SQLite
  Future<void> _loadHeartRates() async {
    try {
      _isLoading.value = true;
      final heartRates = await _repository.getHeartRates();
      _heartRates.value = heartRates;
    } catch (e) {
      // Nếu có lỗi, để danh sách rỗng và log error
      _heartRates.value = [];
      // Không hiển thị error cho user vì đây là load tự động
      // Chỉ log để debug
      print('Error loading heart rates: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh dữ liệu heart rates (public method)
  Future<void> refreshHeartRates() async {
    await _loadHeartRates();
  }
}
