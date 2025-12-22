// File: android/app/build.gradle.kts (The module-level file)

plugins {
    // 1. Apply the Android Application and Kotlin plugins
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    
    // 2. Apply the Google Services plugin (no version needed here)
    id("com.google.gms.google-services") 
    
    // 3. Apply Flutter's plugin (must be last)
    id("dev.flutter.flutter-gradle-plugin")
}

// --- Import for Keystore / Local Properties ---
import java.util.Properties
import java.io.FileInputStream

// Load flutter.gradle properties and local.properties
val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { load(it) }
    }
}

android {
    // You should define your package name explicitly here
    namespace = "com.yourdomain.feelcaree" // **CHANGE THIS TO YOUR PACKAGE NAME**

    // Use versions defined by the Flutter SDK
    compileSdk = flutter.compileSdkVersion.toInt()

    defaultConfig {
        // TODO: Specify your own unique Application ID (e.g., com.example.app)
        applicationId = localProperties.getProperty("flutter.applicationId") ?: "com.yourdomain.feelcaree"
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        
        // Example for Multi-architecture support
        // ndk {
        //    abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        // }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Match your JDK version
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    
    sourceSets {
        getByName("main") {
            // Include the generated flutter code
            java.srcDirs("src/main/kotlin")
        }
    }
    
    // --- SIGNING CONFIGURATIONS (Recommended for Release) ---
    // Uncomment this block and create key.properties if you are signing a release build
    /*
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
    */
}

// --- DEPENDENCIES ---
dependencies {
    // Import the Firebase Bill of Materials (BoM) to manage library versions
    // You need to find the latest BoM version if you add Firebase dependencies
    // Example: implementation(platform("com.google.firebase:firebase-bom:34.3.0"))

    // Example Firebase dependencies (uncomment as needed)
    // implementation("com.google.firebase:firebase-analytics")
    // implementation("com.google.firebase:firebase-auth")

    // The rest of your regular dependencies
    testImplementation("junit:junit:4.13.2")
}

// This block ensures the generated Dart code can be used by the native project
flutter {
    source = rootProject.layout.projectDirectory.dir("..").resolve("local.properties")
}