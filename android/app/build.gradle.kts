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
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Helper function to read .env files
    // For production builds, use .env.production; otherwise use .env
    // Fails the build if the file or key is missing
    fun getEnvProperty(key: String): String {
        // Determine which .env file to use
        // Check for explicit property first, then check if .env.production exists
        val isProduction = project.findProperty("production")?.toString()?.toBoolean() == true ||
                          rootProject.file("../.env.production").exists()
        
        val envFile = if (isProduction) {
            rootProject.file("../.env.production")
        } else {
            rootProject.file("../.env")
        }
        
        // Fail if file doesn't exist
        if (!envFile.exists()) {
            throw GradleException("Required .env file not found: ${envFile.absolutePath}")
        }
        
        // Read and parse the file
        try {
            envFile.readLines().forEach { line ->
                // Skip comments and empty lines
                val trimmed = line.trim()
                if (trimmed.isNotEmpty() && !trimmed.startsWith("#")) {
                    val parts = trimmed.split("=", limit = 2)
                    if (parts.size == 2 && parts[0].trim() == key) {
                        val value = parts[1].trim()
                        if (value.isEmpty()) {
                            throw GradleException("Environment variable $key is empty in ${envFile.name}")
                        }
                        return value
                    }
                }
            }
        } catch (e: GradleException) {
            throw e
        } catch (e: Exception) {
            throw GradleException("Error reading .env file ${envFile.absolutePath}: ${e.message}", e)
        }
        
        // Key not found - fail the build
        throw GradleException("Required environment variable $key not found in ${envFile.name}")
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
        manifestPlaceholders["auth0Scheme"] = getEnvProperty("AUTH0_SCHEME")
        manifestPlaceholders["auth0Domain"] = getEnvProperty("AUTH0_DOMAIN")
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
// 1. Using NDK version 27.0.12077973 which supports 16 KB page sizes
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
