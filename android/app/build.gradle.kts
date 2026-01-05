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

    defaultConfig {
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Auth0 configuration
        // These values should match your .env file
        // The scheme should match AUTH0_SCHEME in .env
        manifestPlaceholders["auth0Domain"] = "login-dev.moustra.com"
        manifestPlaceholders["auth0Scheme"] = "com.moustra.app"
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
            useLegacyPackaging = false
        }
    }
}

flutter {
    source = "../.."
}
