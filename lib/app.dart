import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/router/app_router.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/core/services/notification_service.dart';

/// Widget chính của ứng dụng
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo notification service khi app khởi động
    NotificationService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WalkFit - Step Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      initialRoute: RouteNames.splash,
      getPages: AppRouter.routes,
    );
  }
}
