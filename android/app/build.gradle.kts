import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.moustra.app"
    compileSdk = flutter.compileSdkVersion
    // Explicitly set NDK version to avoid symbol stripping issues on ARM Macs
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Auth0 configuration
        // The scheme is used in AndroidManifest.xml for callback URL intent filters
        // Read from .env.production (preferred) or .env file
        // Falls back to "com.moustra.app" if not found
        manifestPlaceholders["auth0Scheme"] = System.getenv("AUTH0_SCHEME") ?: "com.moustra.app"
        manifestPlaceholders["auth0Domain"] = System.getenv("AUTH0_DOMAIN") ?: "login-dev.moustra.com"
        println("==============================")
        println(manifestPlaceholders["auth0Scheme"])
        println(manifestPlaceholders["auth0Domain"])

        applicationId = "com.moustra.app"
        
        // Disable native debug symbols to avoid stripping issues
        ndk {
            debugSymbolLevel = "NONE"
        }
    }

    fun getSigningProperty(key: String): String? {
        val properties = Properties()
        val keystorePropertiesFile = rootProject.file("key.properties")
        
        if (keystorePropertiesFile.exists()) {
            properties.load(FileInputStream(keystorePropertiesFile))
            return properties.getProperty(key)
        }
        return null
    }

    signingConfigs {
        create("release") {
            // Load credentials from the properties file using the function
            val storeFilePath = getSigningProperty("storeFile")
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
                storePassword = getSigningProperty("storePassword")
                keyAlias = getSigningProperty("keyAlias")
                keyPassword = getSigningProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Use release signing config if key.properties exists, otherwise use debug
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists() && getSigningProperty("storeFile") != null) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Signing with debug keys when key.properties doesn't exist
                signingConfig = signingConfigs.getByName("debug")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
    
    packaging {
        jniLibs {
            // Use extractNativeLibs to properly handle 16 KB page size requirements
            // This allows the system to extract and align native libraries correctly
            useLegacyPackaging = false
            // Only exclude libraries that are not essential for QR code scanning
            // Keep libbarhopper_v3.so for barcode functionality, exclude others
            excludes += listOf(
                "**/libimage_processing_util_jni.so",
                "**/libandroidx.graphics.path.so",
                "**/libdatastore_shared_counter.so",
                "**/libsurface_util_jni.so"
            )
        }
    }
}

// 16 KB Page Size Support Fix
// ============================
// Google Play requires apps to support 16 KB memory page sizes starting Nov 1, 2025.
// The mobile_scanner plugin uses Google ML Kit which includes native libraries
// that don't yet support 16 KB.
//
// Solution implemented:
// 1. Using NDK version 28.2.13676358 which supports 16 KB page sizes
// 2. Excluded incompatible native libraries from packaging:
//    - libimage_processing_util_jni.so (ML Kit utility library)
//    - libbarhopper_v3.so (ML Kit barhopper library)
//    - libandroidx.graphics.path.so (AndroidX graphics library)
//    - libdatastore_shared_counter.so (datastore library)
//    - libsurface_util_jni.so (surface utility library)
//    This excludes the libraries from all architectures (arm64-v8a, x86_64, etc.)
// 3. Using extractNativeLibs (useLegacyPackaging = false) for proper library handling
//
// Note: We keep libbarhopper_v3.so for QR code scanning functionality but exclude
// other utility libraries that cause 16 KB page size issues. If barcode scanning
// still fails, consider using only QR codes or updating to newer mobile_scanner versions.


flutter {
    source = "../.."
}
