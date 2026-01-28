import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service quản lý notification hệ thống
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const MethodChannel _channel = MethodChannel(
    'step_counter_notifications',
  );

  bool _isInitialized = false;

  /// Khởi tạo notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permission cho notification (Android 13+)
    await _requestNotificationPermission();

    _isInitialized = true;
  }

  /// Request permission cho notification (Android 13+)
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  /// Hiển thị notification khi bắt đầu đếm bước (gọi native)
  Future<void> showCountingNotification({
    required int steps,
    required double calories,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _channel.invokeMethod<void>('showCountingNotification', {
        'steps': steps,
        'calories': calories,
      });
    } catch (e) {
      debugPrint('NotificationService show error: $e');
    }
  }

  /// Cập nhật notification với dữ liệu mới
  Future<void> updateCountingNotification({
    required int steps,
    required double calories,
  }) async {
    await showCountingNotification(steps: steps, calories: calories);
  }

  /// Ẩn notification khi dừng đếm
  Future<void> hideCountingNotification() async {
    try {
      await _channel.invokeMethod<void>('hideCountingNotification');
    } catch (e) {
      debugPrint('NotificationService hide error: $e');
    }
  }
}
