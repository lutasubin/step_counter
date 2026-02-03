import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Top-level callback function cho alarm
/// PHẢI là top-level, KHÔNG được trong class
/// @pragma('vm:entry-point') để tránh bị tree-shake trong release mode
@pragma('vm:entry-point')
Future<void> drinkWaterAlarmCallback(int alarmId) async {
  print('========================================');
  print('🔔 ALARM FIRED! ID: $alarmId');
  print('========================================');

  // Khởi tạo timezone
  tz.initializeTimeZones();
  final location = tz.getLocation('Asia/Ho_Chi_Minh');
  tz.setLocalLocation(location);

  // Khởi tạo FlutterLocalNotificationsPlugin
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Cấu hình Android initialization settings
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  try {
    // Initialize notifications
    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: null,
    );

    // Tạo notification channel
    const androidChannel = AndroidNotificationChannel(
      'drink_water_reminder',
      'Nhắc nhở uống nước',
      description: 'Thông báo nhắc nhở uống nước',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }

    // Hiển thị notification
    const androidDetails = AndroidNotificationDetails(
      'drink_water_reminder',
      'Nhắc nhở uống nước',
      channelDescription: 'Thông báo nhắc nhở uống nước',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: alarmId,
      title: 'Nhắc nhở uống nước',
      body: 'Đã đến lúc uống nước rồi! Hãy uống nước để duy trì sức khỏe.',
      notificationDetails: notificationDetails,
    );

    print('✅ Notification đã được hiển thị!');
    print('========================================');
  } catch (e, stackTrace) {
    print('❌ Lỗi khi hiển thị notification: $e');
    print('Stack trace: $stackTrace');
  }
}
