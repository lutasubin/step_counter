import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:step_counter/features/drink_water/service/drink_water_alarm_callback.dart';

/// Service quản lý notifications nhắc nhở uống nước
class DrinkWaterNotificationService {
  static final DrinkWaterNotificationService _instance =
      DrinkWaterNotificationService._internal();
  factory DrinkWaterNotificationService() => _instance;
  DrinkWaterNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static const String _channelId = 'drink_water_reminder';
  static const String _channelName = 'Nhắc nhở uống nước';
  static const String _channelDescription = 'Thông báo nhắc nhở uống nước';

  /// Khởi tạo notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Khởi tạo timezone data
    tz.initializeTimeZones();
    final location = tz.getLocation('Asia/Ho_Chi_Minh'); // Vietnam timezone
    tz.setLocalLocation(location);

    // Request permission cho notification (Android 13+)
    await _requestNotificationPermission();

    // Cấu hình Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Cấu hình iOS initialization settings (không cần vì chỉ Android)
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
      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Tạo notification channel cho Android
      await _createNotificationChannel();
    } catch (e) {
      print('Warning: Could not initialize notifications: $e');
    }

    _isInitialized = true;
  }

  /// Request permission cho notification
  Future<void> _requestNotificationPermission() async {
    try {
      // Request notification permission (Android 13+)
      final notificationStatus = await Permission.notification.status;
      if (notificationStatus.isDenied) {
        await Permission.notification.request();
      }
      // KHÔNG request SCHEDULE_EXACT_ALARM vì dùng exact: false
      // Inexact alarm vẫn hoạt động tốt khi app bị kill, chỉ có thể delay vài phút
    } catch (e) {
      print('Warning: Could not request notification permission: $e');
    }
  }

  /// Tạo notification channel cho Android
  Future<void> _createNotificationChannel() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await androidPlugin.createNotificationChannel(androidChannel);

    // Đảm bảo channel đã được tạo
    print('Notification channel created: $_channelId');
  }

  /// Xử lý khi user tap vào notification
  void _onNotificationTapped(NotificationResponse response) {
    // Có thể navigate đến màn hình drink water nếu cần
  }

  /// Parse time string (ví dụ: "09:00 AM") thành DateTime
  /// Trả về DateTime với giờ và phút đã set, ngày là hôm nay
  DateTime _parseTimeString(String timeString) {
    // Format: "09:00 AM" hoặc "09:00 PM"
    final parts = timeString.split(' ');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $timeString');
    }

    final timePart = parts[0]; // "09:00"
    final period = parts[1].toUpperCase(); // "AM" hoặc "PM"

    final timeParts = timePart.split(':');
    if (timeParts.length != 2) {
      throw FormatException('Invalid time format: $timeString');
    }

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Chuyển đổi sang 24h format
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Schedule notifications từ start time đến end time với interval
  /// Ví dụ: startTime = "09:00 AM", endTime = "09:00 PM", interval = 2 hours
  /// Sẽ tạo notifications lúc: 9:00, 11:00, 13:00, 15:00, 17:00, 19:00, 21:00
  /// intervalHours có thể là số thập phân (ví dụ: 0.5 = 30 phút, 0.0167 = 1 phút)
  Future<void> scheduleReminders({
    required String startTime,
    required String endTime,
    required double intervalHours, // Đổi thành double để hỗ trợ phút
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Hủy tất cả notifications cũ trước (không await để nhanh hơn)
    cancelAllReminders();

    try {
      final start = _parseTimeString(startTime);
      final end = _parseTimeString(endTime);

      // Đảm bảo end time sau start time
      if (end.isBefore(start)) {
        // Nếu end time trước start time, có nghĩa là qua ngày hôm sau
        // Không xử lý trường hợp này, chỉ schedule trong ngày
        return;
      }

      // Tạo notification ID unique dựa trên timestamp
      // Đảm bảo mỗi notification có ID khác nhau, tránh conflict
      // Dùng timestamp để đảm bảo unique ngay cả khi schedule nhiều lần
      int baseNotificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int notificationIndex = 0;
      final now = DateTime.now();

      // Xác định xem có nên schedule cho hôm nay hay ngày mai
      // Nếu end time đã qua → schedule cho ngày mai
      // Nếu end time chưa qua → schedule cho hôm nay
      final shouldScheduleToday = end.isAfter(now) || end.isAtSameMomentAs(now);
      final baseDate = shouldScheduleToday
          ? DateTime(now.year, now.month, now.day)
          : DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

      // Tính lại start và end với baseDate đúng
      final startDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        start.hour,
        start.minute,
      );
      final endDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        end.hour,
        end.minute,
      );

      // Tính interval duration
      Duration intervalDuration;
      if (intervalHours < 1.0) {
        final minutes = (intervalHours * 60).round();
        intervalDuration = Duration(minutes: minutes);
      } else {
        final hours = intervalHours.floor();
        final minutes = ((intervalHours - hours) * 60).round();
        intervalDuration = Duration(hours: hours, minutes: minutes);
      }

      DateTime currentTime = startDateTime;

      // Nếu đang schedule cho hôm nay và start time đã qua
      // Tìm thời điểm tiếp theo từ start time mà >= now
      if (shouldScheduleToday && startDateTime.isBefore(now)) {
        // Tính số interval đã qua (dùng seconds để chính xác hơn)
        final diff = now.difference(startDateTime);
        final totalSeconds = diff.inSeconds;
        final intervalSeconds = intervalDuration.inSeconds;

        // Tính số interval đã qua (làm tròn lên)
        int intervalsPassed = (totalSeconds / intervalSeconds).ceil();

        // Bắt đầu từ interval tiếp theo
        currentTime = startDateTime.add(intervalDuration * intervalsPassed);

        // Đảm bảo currentTime >= now (thêm interval nếu vẫn < now)
        // Tránh vòng lặp vô hạn bằng cách giới hạn số lần thử
        int retryCount = 0;
        while (currentTime.isBefore(now) && retryCount < 10) {
          currentTime = currentTime.add(intervalDuration);
          retryCount++;
        }

        // Nếu đã vượt quá end time, schedule cho ngày mai
        if (currentTime.isAfter(endDateTime)) {
          // Schedule cho ngày mai
          final tomorrowBase = baseDate.add(const Duration(days: 1));
          currentTime = DateTime(
            tomorrowBase.year,
            tomorrowBase.month,
            tomorrowBase.day,
            start.hour,
            start.minute,
          );
          final tomorrowEnd = DateTime(
            tomorrowBase.year,
            tomorrowBase.month,
            tomorrowBase.day,
            end.hour,
            end.minute,
          );

          // Thu thập notifications cho ngày mai
          final List<Map<String, dynamic>> tomorrowNotifications = [];
          int tomorrowNotificationIndex = 0;
          DateTime tempTomorrowTime = currentTime;

          while (tempTomorrowTime.isBefore(tomorrowEnd) ||
              tempTomorrowTime.isAtSameMomentAs(tomorrowEnd)) {
            int notificationId =
                baseNotificationId + tomorrowNotificationIndex++;
            tomorrowNotifications.add({
              'id': notificationId,
              'time': tempTomorrowTime,
            });
            tempTomorrowTime = tempTomorrowTime.add(intervalDuration);
            if (tempTomorrowTime.isAfter(tomorrowEnd)) break;
          }

          // Schedule tất cả notifications cho ngày mai song song
          await Future.wait(
            tomorrowNotifications.map((notification) async {
              try {
                await _scheduleNotification(
                  id: notification['id'] as int,
                  scheduledTime: notification['time'] as DateTime,
                );
                _scheduledNotificationIds.add(notification['id'] as int);
              } catch (e) {
                print('Warning: Could not schedule notification: $e');
              }
            }),
          );
          return; // Đã schedule xong cho ngày mai
        }
      }

      // Thu thập tất cả notifications cần schedule trước
      final List<Map<String, dynamic>> notificationsToSchedule = [];
      DateTime tempTime = currentTime;

      while (tempTime.isBefore(endDateTime) ||
          tempTime.isAtSameMomentAs(endDateTime)) {
        // Chỉ schedule nếu thời gian >= hiện tại
        if (!shouldScheduleToday || !tempTime.isBefore(now)) {
          int notificationId = baseNotificationId + notificationIndex++;
          notificationsToSchedule.add({'id': notificationId, 'time': tempTime});
        }
        tempTime = tempTime.add(intervalDuration);
        if (tempTime.isAfter(endDateTime)) break;
      }

      // Schedule tất cả notifications song song để nhanh hơn
      await Future.wait(
        notificationsToSchedule.map((notification) async {
          try {
            await _scheduleNotification(
              id: notification['id'] as int,
              scheduledTime: notification['time'] as DateTime,
            );
            _scheduledNotificationIds.add(notification['id'] as int);
          } catch (e) {
            print('Warning: Could not schedule notification: $e');
          }
        }),
      );
    } catch (e) {
      print('Error scheduling drink water reminders: $e');
    }
  }

  /// Schedule một notification cụ thể bằng AndroidAlarmManager
  /// Dùng AndroidAlarmManager để notification hoạt động khi app bị kill
  /// Dùng exact: false để tránh Google Play reject (inexact vẫn hoạt động tốt)
  Future<void> _scheduleNotification({
    required int id,
    required DateTime scheduledTime,
  }) async {
    try {
      // Tính thời gian delay từ bây giờ đến scheduledTime
      final now = DateTime.now();
      final delay = scheduledTime.difference(now);

      // Chỉ schedule nếu thời gian trong tương lai
      if (delay.isNegative) {
        print(
          'Warning: Scheduled time is in the past, skipping: $scheduledTime',
        );
        return;
      }

      print(
        'Schedule alarm: ID=$id, Time=$scheduledTime, Delay=${delay.inSeconds}s',
      );

      // Schedule alarm bằng AndroidAlarmManager
      // Dùng exact: false để tránh Google Play reject
      // Inexact alarm vẫn hoạt động tốt khi app bị kill, chỉ có thể delay vài phút
      // Điều này hoàn toàn chấp nhận được cho reminder uống nước
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        id,
        drinkWaterAlarmCallback,
        exact: false, // Dùng inexact để an toàn với Google Play
        wakeup: true,
        allowWhileIdle: true,
      );

      print('✅ Alarm scheduled successfully: ID=$id');
    } catch (e, stackTrace) {
      print('❌ Error scheduling alarm: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Lưu danh sách notification IDs đã schedule để cancel nhanh
  final List<int> _scheduledNotificationIds = [];

  /// Hủy tất cả reminders
  Future<void> cancelAllReminders() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Nếu có danh sách IDs, cancel từng alarm
      if (_scheduledNotificationIds.isNotEmpty) {
        print('Cancelling ${_scheduledNotificationIds.length} alarms...');
        // Cancel song song để nhanh hơn
        await Future.wait(
          _scheduledNotificationIds.map((id) async {
            try {
              await AndroidAlarmManager.cancel(id);
            } catch (e) {
              print('Warning: Could not cancel alarm $id: $e');
            }
          }),
        );
        _scheduledNotificationIds.clear();
        print('✅ All alarms cancelled');
      } else {
        print('No alarms to cancel');
      }
    } catch (e) {
      print('Warning: Could not cancel reminders: $e');
    }
  }
}
