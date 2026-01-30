import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/heart_rate/service/heart_rate_measurement_service.dart';

/// Controller quản lý logic của measure heart rate screen
class MeasureHeartRateController extends GetxController {
  final HeartRateMeasurementService _measurementService =
      getIt<HeartRateMeasurementService>();

  final _bpm = 0.obs;
  final _progress = 0.0.obs;
  final _isMeasuring = false.obs;
  final _isFingerDetected = false.obs;
  StreamSubscription<Map<String, dynamic>>? _measurementSubscription;

  /// BPM hiện tại
  int get bpm => _bpm.value;

  /// Progress (0.0 - 1.0)
  double get progress => _progress.value;

  /// Đang đo
  bool get isMeasuring => _isMeasuring.value;

  /// Đã detect được tay che camera
  bool get isFingerDetected => _isFingerDetected.value;

  @override
  void onReady() {
    super.onReady();
    // Delay một chút để UI render xong trước khi bắt đầu đo
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkPermissionAndStart();
    });
  }

  /// Kiểm tra permission và bắt đầu đo
  Future<void> _checkPermissionAndStart() async {
    // Kiểm tra camera permission
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _startMeasuring();
    } else if (status.isDenied) {
      // Request permission
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _startMeasuring();
      } else {
        Get.snackbar(
          'Quyền truy cập',
          'Cần quyền truy cập camera để đo nhịp tim',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      }
    } else {
      // Permanently denied
      Get.snackbar(
        'Quyền truy cập',
        'Vui lòng cấp quyền camera trong Settings',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      // Mở settings sau 1 giây
      Future.delayed(const Duration(seconds: 1), () {
        openAppSettings();
      });
      Get.back();
    }
  }

  @override
  void onClose() {
    _stopMeasuring();
    super.onClose();
  }

  /// Bắt đầu đo nhịp tim
  Future<void> _startMeasuring() async {
    try {
      _isMeasuring.value = true;
      _progress.value = 0.0;
      _bpm.value = 0;

      // Bắt đầu đo từ service
      final stream = await _measurementService.startMeasurement();

      // Lắng nghe stream để cập nhật BPM và progress
      _measurementSubscription = stream.listen(
        (data) {
          final bpm = data['bpm'] as int?;
          final progress = data['progress'] as double;
          final completed = data['completed'] as bool? ?? false;
          final fingerDetected = data['fingerDetected'] as bool? ?? true;

          print(
            'MeasureHeartRateController: Received data - BPM: $bpm, Progress: $progress, Completed: $completed, FingerDetected: $fingerDetected',
          );

          // Cập nhật finger detected state
          _isFingerDetected.value = fingerDetected;

          // Chỉ cập nhật BPM và progress khi đã detect được tay
          if (fingerDetected) {
            if (bpm != null) {
              _bpm.value = bpm;
            }
            _progress.value = progress;
          } else {
            // Chưa detect được tay, giữ progress = 0
            _progress.value = 0.0;
            _bpm.value = 0;
          }

          // Kết thúc khi hoàn thành
          if (completed) {
            final finalBPM = bpm ?? _bpm.value;
            print(
              'MeasureHeartRateController: Measurement completed, BPM: $finalBPM, calling _finishMeasuring',
            );
            _finishMeasuring(finalBPM);
          }
        },
        onError: (error) {
          _isMeasuring.value = false;
          String errorMessage = 'Đã xảy ra lỗi khi đo nhịp tim';

          if (error is Exception) {
            final errorStr = error.toString().toLowerCase();
            if (errorStr.contains('camera') ||
                errorStr.contains('không tìm thấy')) {
              errorMessage = 'Không tìm thấy camera hoặc camera không khả dụng';
            } else if (errorStr.contains('permission') ||
                errorStr.contains('quyền')) {
              errorMessage = 'Không có quyền truy cập camera';
            } else if (errorStr.contains('flash')) {
              errorMessage = 'Không thể bật đèn flash';
            } else {
              errorMessage = error.toString();
            }
          }

          Get.snackbar(
            'Lỗi',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          Get.back();
        },
      );
    } catch (e) {
      _isMeasuring.value = false;
      String errorMessage = 'Không thể bắt đầu đo nhịp tim';

      if (e is PlatformException) {
        if (e.code == 'PERMISSION_DENIED') {
          errorMessage = 'Không có quyền truy cập camera';
        } else if (e.code == 'CAMERA_NOT_AVAILABLE') {
          errorMessage = 'Camera không khả dụng';
        } else {
          errorMessage = 'Lỗi: ${e.message ?? e.toString()}';
        }
      } else {
        errorMessage = 'Lỗi: ${e.toString()}';
      }

      Get.snackbar(
        'Lỗi',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      Get.back();
    }
  }

  /// Kết thúc đo
  void _finishMeasuring(int finalBPM) {
    print(
      'MeasureHeartRateController: _finishMeasuring called with BPM: $finalBPM',
    );

    _isMeasuring.value = false;
    _bpm.value = finalBPM;
    _progress.value = 1.0;

    // Dừng subscription và service
    _stopMeasuring();

    // Luôn chuyển sang màn hình kết quả, bất kể BPM là bao nhiêu
    Future.delayed(const Duration(milliseconds: 500), () {
      print(
        'MeasureHeartRateController: Navigating to result screen with BPM: $finalBPM',
      );
      if (Get.isRegistered<MeasureHeartRateController>()) {
        Get.offNamed(RouteNames.heartRateResult, arguments: finalBPM);
      } else {
        print(
          'MeasureHeartRateController: Controller not registered, using Get.toNamed',
        );
        Get.toNamed(RouteNames.heartRateResult, arguments: finalBPM);
      }
    });
  }

  /// Dừng đo
  Future<void> _stopMeasuring() async {
    try {
      await _measurementSubscription?.cancel();
      _measurementSubscription = null;
      await _measurementService.stopMeasurement();
    } catch (e) {
      // Ignore errors khi dừng
      print('Error stopping measurement: $e');
    } finally {
      _isMeasuring.value = false;
    }
  }

  /// Hủy đo
  void cancelMeasuring() {
    _stopMeasuring();
    Get.back();
  }
}
