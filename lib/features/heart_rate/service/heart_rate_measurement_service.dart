import 'dart:async';
import 'package:flutter/services.dart';

/// Service để đo nhịp tim bằng camera (PPG method)
/// Sử dụng native Android code để đạt độ chính xác cao hơn
class HeartRateMeasurementService {
  static const MethodChannel _channel = MethodChannel('heart_rate_measurement');
  StreamController<Map<String, dynamic>>? _streamController;

  /// Bắt đầu đo nhịp tim
  /// Trả về stream của BPM và progress (0.0 - 1.0)
  Future<Stream<Map<String, dynamic>>> startMeasurement() async {
    _streamController = StreamController<Map<String, dynamic>>();

    // Setup listener cho native callbacks
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onMeasurementUpdate':
          final data = call.arguments as Map<dynamic, dynamic>;
          _streamController?.add({
            'bpm': data['bpm'] as int?,
            'progress': data['progress'] as double,
            'frameCount': data['frameCount'] as int,
            'fingerDetected': data['fingerDetected'] as bool? ?? true,
          });
          break;
        case 'onFingerDetected':
          _streamController?.add({
            'bpm': null,
            'progress': 0.0,
            'frameCount': 0,
            'fingerDetected': true,
          });
          break;
        case 'onMeasurementComplete':
          final data = call.arguments as Map<dynamic, dynamic>;
          final bpm = data['bpm'] as int?;
          print('HeartRateService: Received onMeasurementComplete, BPM: $bpm');

          // Gửi data với completed flag
          _streamController?.add({
            'bpm': bpm,
            'progress': 1.0,
            'frameCount': 900, // 30 giây * 30 FPS
            'completed': true,
          });

          // Đợi một chút để đảm bảo message được gửi
          await Future.delayed(const Duration(milliseconds: 100));

          // Đóng stream sau khi đã gửi
          _streamController?.close();
          _streamController = null;
          break;
        case 'onError':
          final error = call.arguments as String;
          _streamController?.addError(Exception(error));
          await stopMeasurement();
          _streamController?.close();
          break;
      }
    });

    // Gọi native code để bắt đầu đo
    try {
      await _channel.invokeMethod('startMeasurement');
    } catch (e) {
      _streamController?.addError(e);
      _streamController?.close();
    }

    return _streamController!.stream;
  }

  /// Dừng đo nhịp tim
  Future<void> stopMeasurement() async {
    try {
      await _channel.invokeMethod('stopMeasurement');
    } catch (e) {
      // Ignore errors khi dừng
      print('Error stopping measurement: $e');
    } finally {
      _streamController?.close();
      _streamController = null;
    }
  }

  /// Cleanup khi dispose
  void dispose() {
    stopMeasurement();
  }
}
