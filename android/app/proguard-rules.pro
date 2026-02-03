# Flutter ProGuard Rules
# Tối ưu app khi đưa lên Google Play Store

# ============================================
# Flutter Engine & Dart Runtime
# ============================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart native entry points
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.dart.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.embedding.engine.plugins.util.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Flutter JNI
-keep class io.flutter.embedding.engine.FlutterJNI { *; }

# ============================================
# GetX (State Management)
# ============================================
-keep class com.github.jonataslaw.** { *; }
-keep class get.** { *; }
-keepclassmembers class * extends get.GetxController {
    <methods>;
}
-keepclassmembers class * extends get.GetxService {
    <methods>;
}

# ============================================
# GetIt (Dependency Injection)
# ============================================
-keep class get_it.** { *; }
-keepclassmembers class * {
    @get_it.* <methods>;
}

# ============================================
# SharedPreferences
# ============================================
-keep class androidx.preference.** { *; }
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$** { *; }

# ============================================
# SQLite (sqflite)
# ============================================
-keep class com.tekartik.sqflite.** { *; }
-keep class android.database.sqlite.** { *; }
-keep class android.database.** { *; }
-keepclassmembers class * extends android.database.sqlite.SQLiteOpenHelper {
    <init>(...);
}

# ============================================
# Flutter Local Notifications
# ============================================
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.** { *; }
-keep class android.app.Notification { *; }
-keep class android.app.NotificationManager { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.app.NotificationChannelGroup { *; }
-keepclassmembers class * extends android.content.BroadcastReceiver {
    <init>(...);
}

# Keep notification receivers
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }

# ============================================
# Permission Handler
# ============================================
-keep class com.baseflow.permissionhandler.** { *; }
-keep class androidx.core.content.** { *; }

# ============================================
# Pedometer (Step Counter)
# ============================================
-keep class com.johnpryan.flutter.pedometer.** { *; }
-keep class android.hardware.SensorManager { *; }
-keep class android.hardware.Sensor { *; }
-keep class android.hardware.SensorEvent { *; }

# ============================================
# Camera
# ============================================
-keep class io.flutter.plugins.camera.** { *; }
-keep class androidx.camera.** { *; }
-keep class android.hardware.camera2.** { *; }
-keep class android.hardware.Camera { *; }
-keep class android.hardware.Camera$** { *; }

# ============================================
# Image Processing
# ============================================
-keep class io.flutter.plugins.image.** { *; }
-keep class android.graphics.** { *; }
-keep class android.graphics.Bitmap { *; }
-keep class android.graphics.BitmapFactory { *; }

# ============================================
# Timezone
# ============================================
-keep class com.baseflow.timezone.** { *; }

# ============================================
# FL Chart
# ============================================
-keep class com.github.imaNNeoFighT.fl_chart.** { *; }

# ============================================
# SVG (flutter_svg)
# ============================================
-keep class com.davemorrissey.labs.subscaleview.** { *; }
-keep class com.davemorrissey.labs.subscaleview.SubsamplingScaleImageView { *; }

# ============================================
# Intl (Internationalization)
# ============================================
-keep class intl.** { *; }

# ============================================
# Android Support Libraries
# ============================================
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# ============================================
# Kotlin
# ============================================
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class * extends kotlin.Enum {
    <fields>;
}

# ============================================
# MainActivity & Application
# ============================================
-keep class com.mobileai.countersteppro.MainActivity { *; }
-keep class com.mobileai.countersteppro.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# ============================================
# Keep Parcelables
# ============================================
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# ============================================
# Keep Serializable
# ============================================
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============================================
# Keep Enums
# ============================================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ============================================
# Keep Native Methods
# ============================================
-keepclasseswithmembernames class * {
    native <methods>;
}

# ============================================
# Keep View constructors
# ============================================
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# ============================================
# Remove logging in release
# ============================================
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ============================================
# Keep annotations
# ============================================
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ============================================
# Keep line numbers for stack traces
# ============================================
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ============================================
# Optimization
# ============================================
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# ============================================
# Warnings
# ============================================
-dontwarn android.support.**
-dontwarn androidx.**
-dontwarn com.google.**
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn kotlin.**
-dontwarn org.jetbrains.annotations.**
