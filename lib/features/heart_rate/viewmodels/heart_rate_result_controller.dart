import 'package:get/get.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/heart_rate/model/heart_rate_model.dart';
import 'package:step_counter/features/heart_rate/repositories/heart_rate_repository.dart';
import 'package:step_counter/features/heart_rate/viewmodels/heart_rate_controller.dart';
import 'package:step_counter/features/heart_rate/views/widgets/heart_rate_info_dialog.dart';
import 'package:step_counter/features/home/viewmodels/home_controller.dart';
import 'package:step_counter/features/splash/service/splash_service.dart';

/// Controller quản lý logic của heart rate result screen
class HeartRateResultController extends GetxController {
  final HeartRateRepository _repository = getIt<HeartRateRepository>();

  final _bpm = 0.obs;
  final _dateTime = DateTime.now().obs;
  final _isSaving = false.obs;

  /// Đang lưu
  bool get isSaving => _isSaving.value;

  /// BPM (observable)
  RxInt get bpm => _bpm;

  /// DateTime (observable)
  Rx<DateTime> get dateTime => _dateTime;

  /// BPM value
  int get bpmValue => _bpm.value;

  /// DateTime value
  DateTime get dateTimeValue => _dateTime.value;

  /// Status dựa trên BPM
  String get status {
    if (_bpm.value < 60) return 'Low';
    if (_bpm.value >= 60 && _bpm.value < 100) return 'Normal';
    if (_bpm.value >= 100 && _bpm.value < 120) return 'Elevated';
    return 'High';
  }

  /// Normal range
  String get normalRange => 'BPM 75-89';

  @override
  void onInit() {
    super.onInit();
    // Nhận BPM từ arguments (từ MeasureHeartRateController)
    final arguments = Get.arguments;
    if (arguments is int) {
      setBpm(arguments);
    } else {
      // Nếu không có arguments, quay lại
      Get.back();
    }
  }

  /// Set BPM
  void setBpm(int value) {
    _bpm.value = value;
    _dateTime.value = DateTime.now();
  }

  /// Lưu kết quả
  Future<void> saveResult() async {
    if (_isSaving.value) return;

    try {
      _isSaving.value = true;

      final heartRate = HeartRateModel(
        dateTime: _dateTime.value,
        bpm: _bpm.value,
        status: status,
        normalRange: normalRange,
      );

      // Lưu vào SQLite
      await _repository.saveHeartRate(heartRate);

      // Đánh dấu đã hoàn thành trải nghiệm homeFirst (nếu chưa)
      final splashService = getIt<SplashService>();
      if (!await splashService.hasCompletedHomeFirst()) {
        await splashService.setHomeFirstCompleted();
      }

      // Refresh HeartRateController để load dữ liệu mới
      final heartRateController = Get.find<HeartRateController>();
      await heartRateController.refreshHeartRates();

      // Refresh HomeController để cập nhật home cards real-time
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        await homeController.refreshHomeCardsData();
      }

      // Hiển thị dialog thông tin BPM
      // Dialog sẽ tự động quay lại màn hình Heart rate khi user bấm GOT IT
      Get.dialog(const HeartRateInfoDialog(), barrierDismissible: false);
    } catch (e) {
      _isSaving.value = false;
      String errorMessage = 'Không thể lưu kết quả';

      if (e.toString().toLowerCase().contains('database') ||
          e.toString().toLowerCase().contains('sqlite')) {
        errorMessage = 'Lỗi database. Vui lòng thử lại';
      } else {
        errorMessage = 'Lỗi: ${e.toString()}';
      }

      Get.snackbar(
        'Lỗi',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
