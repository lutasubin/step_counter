import 'package:flutter/material.dart';
import 'package:step_counter/app.dart';
import 'package:step_counter/core/di/di_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(const MyApp());
}

/// Khởi tạo app bất đồng bộ
Future<void> _initializeApp() async {
  setupDI();
  // Có thể thêm các thao tác khởi tạo bất đồng bộ khác ở đây
  // Ví dụ: await _initializeStorage();
}
