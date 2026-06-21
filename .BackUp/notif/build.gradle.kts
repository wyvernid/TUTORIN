plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.tutorin.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // ── BARU: wajib untuk flutter_local_notifications (v10+) ──
        // Plugin ini memakai API Java 8+ (java.time dkk) yang butuh
        // "desugaring" supaya bisa jalan di Android versi lama juga.
        // Tanpa ini, build akan gagal dengan error:
        // "Dependency ':flutter_local_notifications' requires core
        //  library desugaring to be enabled for :app"
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tutorin.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // ── BARU: disarankan dokumentasi flutter_local_notifications ──
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}


dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.14.0"))
    implementation("com.google.firebase:firebase-analytics")

    // ── BARU: dependency desugaring, wajib berpasangan dengan
    // isCoreLibraryDesugaringEnabled = true di atas ──
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}