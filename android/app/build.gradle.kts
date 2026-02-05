import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin (bắt buộc đặt sau Android + Kotlin)
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.mobileai.countersteppro"
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.mobileai.countersteppro"
        minSdk = 24 
        targetSdk = 35 
        versionCode = 2
        versionName = "1.0"
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

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                // Trim whitespace từ keyAlias để tránh lỗi
                keyAlias = (keystoreProperties["keyAlias"] as String).trim()
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
             // Debug build không dùng keystore release
            // Sử dụng keystore debug mặc định

            // BẬT ProGuard cho debug để test lỗi giống bản release
            isMinifyEnabled = true
            // Tắt shrinkResources để log dễ đọc hơn, build nhanh hơn
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        release {
            // Release mode: sử dụng release signing config từ key.properties
            signingConfig = signingConfigs.getByName("release")
            
            // Enable ProGuard/R8 để tối ưu app
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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
