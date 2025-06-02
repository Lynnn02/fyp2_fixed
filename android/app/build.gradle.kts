// App-level build.gradle.kts
plugins {
    id("com.android.application")  // Android Application plugin
    id("kotlin-android")  // Kotlin Android plugin
    id("dev.flutter.flutter-gradle-plugin")  // Flutter plugin for Gradle
    id("com.google.gms.google-services")  // Google Services plugin for Firebase
}

android {
    namespace = "com.example.little_explorers"  // Application namespace (matches package name)
    compileSdk = flutter.compileSdkVersion  // Use Flutter's compile SDK version
    ndkVersion = "27.0.12077973"  // Specify the NDK version here

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11  // Java 11 for source compatibility
        targetCompatibility = JavaVersion.VERSION_11  // Java 11 for target compatibility
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()  // Kotlin JVM target set to Java 11
    }

    defaultConfig {
        // Application ID must be unique
        applicationId = "com.example.little_explorers"  // Ensure this matches google-services.json
        minSdk = 23  // Minimum SDK version required for your app
        targetSdk = flutter.targetSdkVersion  // Target SDK version (from Flutter)
        versionCode = flutter.versionCode  // Version code (from Flutter)
        versionName = flutter.versionName  // Version name (from Flutter)
    }

    buildTypes {
        release {
            // Signing configuration (ensure you adjust this for release builds)
            signingConfig = signingConfigs.getByName("debug")  // Set your signing config here
        }
    }
}

flutter {
    source = "../.."  // Path to the Flutter project
}
