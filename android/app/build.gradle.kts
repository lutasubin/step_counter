plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin (bắt buộc đặt sau Android + Kotlin)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mobileai.countersteppro"
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.mobileai.countersteppro"
        minSdk = 24 
        targetSdk = 35 
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        // Dùng Java 17 vẫn OK
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // BẮT BUỘC cho flutter_local_notifications >= 20
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        release {
            // tạm dùng debug key cho release
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // BẮT BUỘC cho desugaring (java.time, Optional, …)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
