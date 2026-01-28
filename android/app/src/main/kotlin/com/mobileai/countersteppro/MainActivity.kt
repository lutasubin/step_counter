package com.mobileai.countersteppro

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
    }

    // Tạo notification channel cho Android 8+
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                notificationChannelId,
                "Step Counter",
                NotificationManager.IMPORTANCE_LOW,
            )
            channel.description = "Hiển thị trạng thái đếm bước chân"
            notificationManager.createNotificationChannel(channel)
        }
    }

    // Hiển thị notification với layout custom
    private fun showCountingNotification(steps: Int, calories: Double) {
        val views = RemoteViews(packageName, R.layout.layout_step_counter_notification)
        views.setTextViewText(R.id.tv_steps, steps.toString())
        views.setTextViewText(R.id.tv_calories, String.format("%.1f", calories))
        val progress = steps.coerceIn(0, 10_000)
        views.setProgressBar(R.id.progress_bar, 10_000, progress, false)

        val notification: Notification = NotificationCompat.Builder(this, notificationChannelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(views)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()

        notificationManager.notify(notificationId, notification)
    }

    // Ẩn notification
    private fun hideCountingNotification() {
        notificationManager.cancel(notificationId)
    }
}
