plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.syathiby.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "id.syathiby.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Configuration for the 'debug' signing config
        getByName("debug") {
            storeFile = file("../../keystore/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
        
        // Configuration for the 'release' signing config
        create("release") {
            storeFile = file("../../keystore/creatorbe-bundle.jks")
            storePassword = "bismillah"
            keyAlias = "creatorbe"
            keyPassword = "bismillah"
        }
    }

    buildTypes {
        // Access existing build type configuration using getByName
        getByName("debug") {
            // Note: The assignment operator (=) is often required in KTS for setting properties
            signingConfig = signingConfigs.getByName("debug")
        }
        
        getByName("release") {
            isMinifyEnabled = true // Optional: often helpful for release builds
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}