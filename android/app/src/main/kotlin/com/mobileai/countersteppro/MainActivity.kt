package com.mobileai.countersteppro

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.TypedArray
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// Xử lý notification native cho step counter
class MainActivity : FlutterActivity() {

    private val channelName = "step_counter_notifications"
    private val notificationChannelId = "step_counter_native_channel"
    private val notificationId = 1001

    private val notificationManager: NotificationManager by lazy {
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    private var heartRateHandler: HeartRateMeasurementHandler? = null
    private val heartRateChannelName = "heart_rate_measurement"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
        // Kiểm tra nếu app được mở từ notification
        handleNotificationIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Kiểm tra nếu app được mở từ notification (khi app đang chạy)
        handleNotificationIntent(intent)
    }

    // Xử lý intent khi app được mở từ notification
    private fun handleNotificationIntent(intent: Intent?) {
        if (intent?.getBooleanExtra("from_notification", false) == true) {
            // Gửi message qua MethodChannel để Flutter navigate về home
            // Sẽ được xử lý trong configureFlutterEngine nếu engine đã sẵn sàng
            // Hoặc có thể dùng EventChannel hoặc đơn giản là navigate trong Flutter
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MethodChannel cho step counter notifications
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "showCountingNotification" -> {
                    val steps = call.argument<Int>("steps") ?: 0
                    val calories = call.argument<Double>("calories") ?: 0.0
                    showCountingNotification(steps, calories)
                    result.success(null)
                }
                "hideCountingNotification" -> {
                    hideCountingNotification()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // MethodChannel cho heart rate measurement
        val heartRateChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            heartRateChannelName,
        )
        heartRateHandler = HeartRateMeasurementHandler(this, heartRateChannel)
        
        heartRateChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startMeasurement" -> {
                    // Kiểm tra camera permission
                    if (ContextCompat.checkSelfPermission(
                            this,
                            android.Manifest.permission.CAMERA
                        ) == PackageManager.PERMISSION_GRANTED
                    ) {
                        heartRateHandler?.startMeasurement()
                        result.success(null)
                    } else {
                        result.error("PERMISSION_DENIED", "Camera permission not granted", null)
                    }
                }
                "stopMeasurement" -> {
                    heartRateHandler?.stopMeasurement()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // Tạo notification channel cho Android 8+
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Theo tài liệu Android: IMPORTANCE_HIGH để notification luôn hiển thị ở đầu
            // IMPORTANCE_HIGH: Notification hiển thị ở đầu, có thể heads-up, phát âm thanh
            // IMPORTANCE_MAX: Tương tự nhưng có thể quá nhiều (dùng cho alarm/call)
            // Lưu ý: Với IMPORTANCE_HIGH, cần tắt âm thanh để không làm phiền
            val channel = NotificationChannel(
                notificationChannelId,
                "Step Counter",
                NotificationManager.IMPORTANCE_HIGH,
            )
            channel.description = "Hiển thị trạng thái đếm bước chân"
            channel.setShowBadge(false)
            // Tắt âm thanh và rung để không làm phiền người dùng
            // Nhưng vẫn giữ IMPORTANCE_HIGH để notification ở đầu
            channel.enableVibration(false)
            channel.setSound(null, null)
            // Cho phép heads-up notification (hiển thị popup trên màn hình)
            channel.enableLights(false)
            notificationManager.createNotificationChannel(channel)
        }
    }

    // Lấy màu background từ hệ thống Android theo tài liệu chính thức
    // Sử dụng theme attributes để lấy màu động theo theme của thiết bị
    private fun getSystemNotificationBackgroundColor(): Int {
        val typedValue = TypedValue()
        val theme = this.theme
        
        // Theo tài liệu Android, nên dùng colorBackground hoặc colorPrimary
        var color = 0xFF111829.toInt() // Màu mặc định nếu không lấy được
        
        try {
            // Thử lấy màu từ colorBackground (màu nền mặc định của hệ thống)
            // Attribute này tự động thay đổi theo light/dark mode
            if (theme.resolveAttribute(android.R.attr.colorBackground, typedValue, true)) {
                // typedValue.data có thể là resource ID hoặc color value
                if (typedValue.type >= TypedValue.TYPE_FIRST_COLOR_INT && 
                    typedValue.type <= TypedValue.TYPE_LAST_COLOR_INT) {
                    color = typedValue.data
                } else if (typedValue.resourceId != 0) {
                    // Nếu là resource ID, lấy màu từ resource
                    color = ContextCompat.getColor(this, typedValue.resourceId)
                }
            }
            // Nếu không có, thử lấy từ windowBackground
            else if (theme.resolveAttribute(android.R.attr.windowBackground, typedValue, true)) {
                if (typedValue.type >= TypedValue.TYPE_FIRST_COLOR_INT && 
                    typedValue.type <= TypedValue.TYPE_LAST_COLOR_INT) {
                    color = typedValue.data
                } else if (typedValue.resourceId != 0) {
                    color = ContextCompat.getColor(this, typedValue.resourceId)
                }
            }
        } catch (e: Exception) {
            // Nếu có lỗi, dùng màu mặc định
            color = 0xFF111829.toInt()
        }
        
        return color
    }

    // Hiển thị notification với layout custom
    private fun showCountingNotification(steps: Int, calories: Double) {
        val views = RemoteViews(packageName, R.layout.layout_step_counter_notification)
        views.setTextViewText(R.id.tv_steps, steps.toString())
        views.setTextViewText(R.id.tv_calories, String.format("%.1f", calories))
        val progress = steps.coerceIn(0, 10_000)
        views.setProgressBar(R.id.progress_bar, 10_000, progress, false)
        
        // Theo tài liệu Android chính thức:
        // - DecoratedCustomViewStyle tự động thêm background decoration theo theme hệ thống
        // - Không nên hardcode background color trong layout XML
        // - Để hệ thống tự động xử lý màu background theo theme (light/dark mode)
        // - RemoteViews có hạn chế trong việc set background color động
        // 
        // Giải pháp: Bỏ background trong layout XML, để DecoratedCustomViewStyle
        // tự động thêm màu background theo theme của hệ thống
        // Điều này sẽ đảm bảo notification có cùng màu với hệ thống

        // Tạo PendingIntent để mở app khi click vào notification
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("from_notification", true) // Flag để biết app được mở từ notification
        }
        
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            pendingIntentFlags
        )

        // DecoratedCustomViewStyle tự động thêm background decoration của hệ thống Android
        // Điều này có thể tạo ra hai màu khác nhau (màu của hệ thống và màu của layout)
        // Không có cách nào để loại bỏ hoàn toàn decoration này trong Android
        // Giải pháp: Đảm bảo layout có background đầy đủ và minHeight để che phủ toàn bộ
        val style = NotificationCompat.DecoratedCustomViewStyle()
        
        // Theo tài liệu Android: Để notification luôn ở đầu, cần:
        // 1. IMPORTANCE_HIGH trong channel (đã set ở trên)
        // 2. PRIORITY_HIGH trong notification builder
        // 3. Category phù hợp (STATUS cho ongoing notification)
        // 4. Ongoing = true để notification không thể swipe away
        val notification: Notification = NotificationCompat.Builder(this, notificationChannelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setStyle(style)
            .setCustomContentView(views)
            .setContentIntent(pendingIntent) // Thêm PendingIntent để mở app khi click
            .setOngoing(true) // Notification sẽ không thể swipe away, luôn hiển thị
            .setOnlyAlertOnce(true) // Chỉ alert một lần khi tạo
            .setPriority(NotificationCompat.PRIORITY_HIGH) // Priority cao để luôn ở đầu
            .setCategory(NotificationCompat.CATEGORY_STATUS) // Category cho status notification
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC) // Hiển thị công khai
            .setShowWhen(false) // Ẩn thời gian để tránh decoration
            .setWhen(0) // Ẩn thời gian
            .build()

        notificationManager.notify(notificationId, notification)
    }

    // Ẩn notification
    private fun hideCountingNotification() {
        notificationManager.cancel(notificationId)
    }
}
