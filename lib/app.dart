import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/router/app_router.dart';
import 'package:step_counter/core/constants/route_names.dart';

/// Widget chính của ứng dụng
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WalkFit - Step Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: RouteNames.splash,
      getPages: AppRouter.routes,
    );
  }
}
