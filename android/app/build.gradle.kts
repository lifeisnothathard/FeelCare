// File: android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services") 
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

android {
    // Verified: Matches your Package Name
    namespace = "com.project.feelcare" 

    compileSdk = flutter.compileSdkVersion.toInt()

    defaultConfig {
        applicationId = "com.project.feelcare"
        
        // --- Required for Firebase & Biometrics ---
        minSdk = 23 
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        
        // --- Essential for heavy apps with many plugins ---
        multiDexEnabled = true 
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true 
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
    
    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    buildTypes {
        release {
            // Add your signing config here if needed later
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    testImplementation("junit:junit:4.13.2")
    // Implementation for multidex support
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = ".."
}

// --- THE MISSING PIECE ---
// This line MUST be at the very bottom to connect Google Services properly
apply(plugin = "com.google.gms.google-services")