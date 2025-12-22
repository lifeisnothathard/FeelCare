// Top-level build file where you can add configuration options common to all sub-projects/modules.

// ------------------------------------------
// 1. Plugin Versions Declaration (Modern Approach)
// The versions here are declared and applied with 'apply false'
// to prevent them from applying to the root project itself.
// ------------------------------------------
plugins {
    // Current stable Android Gradle Plugin (AGP) version (Example: 8.13.2)
    id("com.android.application") version "8.13.2" apply false
    
    // Current stable Kotlin version (Example: 2.2.21)
    id("org.jetbrains.kotlin.android") version "2.2.21" apply false
    
    // Google Services plugin for Firebase (Example: 4.4.4)
    id("com.google.gms.google-services") version "4.4.4" apply false 
    
    // Flutter's required plugin 
    id("dev.flutter.flutter-gradle-plugin") apply false
}

// Note: The old 'buildscript { dependencies { classpath(...) } }' block is GONE.

// ------------------------------------------
// 2. Repositories and Custom Build Directory Logic
// ------------------------------------------
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Ensure you import the correct Directory type for the custom build logic
import org.gradle.api.file.Directory

// Custom logic to move the build directory outside the android folder
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Keeping this evaluation dependency, though often not needed in modern Flutter
    project.evaluationDependsOn(":app")
}

// Register the clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}