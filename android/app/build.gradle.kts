plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kaz_bd"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.kaz_bd"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Apply Google Maps API key from environment variable
        // Set GOOGLE_MAPS_API_KEY environment variable or add MAPS_API_KEY property to local.properties or gradle.properties
        val mapsApiKey: String = System.getenv("GOOGLE_MAPS_API_KEY") ?: project.findProperty("MAPS_API_KEY") as String? ?: ""
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }

        debug {
            // Read the API key from environment variable or local.properties for debug builds
            val mapsApiKey: String = System.getenv("GOOGLE_MAPS_API_KEY") ?: project.findProperty("MAPS_API_KEY") as String? ?: ""
            manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
        }
    }
}

flutter {
    source = "../.."
}