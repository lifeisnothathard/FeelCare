import org.gradle.api.file.Directory

plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false // Updated Kotlin
    id("com.google.gms.google-services") version "4.3.15" apply false // Updated Firebase Plugin
    id("dev.flutter.flutter-gradle-plugin") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://developer.huawei.com/repo/' } // Huawei Maven repository
    }
}

// Keep your custom build directory logic if you prefer, 
// but ensure it's not deleting things prematurely.
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

dependencies {
    classpath("com.google.gms:google-services:4.3.15") // Add this line
}
