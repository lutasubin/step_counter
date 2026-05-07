import 'dart:io';

import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:step_counter/app.dart';
import 'package:step_counter/core/di/di_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeAndroidAlarmManager();
  
  await _initializeApp();
  runApp(const MyApp());
}

/// Chỉ khởi tạo AlarmManager trên Android để tránh lỗi MissingPluginException.
Future<void> _initializeAndroidAlarmManager() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    await AndroidAlarmManager.initialize();
  } catch (_) {
    // Tránh crash app khi plugin chưa sẵn sàng ở runtime.
  }
}

/// Khởi tạo app bất đồng bộ
Future<void> _initializeApp() async {
  setupDI();
  // Có thể thêm các thao tác khởi tạo bất đồng bộ khác ở đây
  // Ví dụ: await _initializeStorage();
}
