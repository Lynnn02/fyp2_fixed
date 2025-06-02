// Project-level build.gradle.kts
buildscript {
    repositories {
        google()  // For Google services
        mavenCentral()  // For maven dependencies
    }
    dependencies {
        // Android Gradle Plugin version (ensure you're using a compatible version for your SDK)
        classpath("com.android.tools.build:gradle:7.2.2") 
        
        // Google Services plugin for Firebase integration
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()  // Ensures Google services are available
        mavenCentral()  // For other dependencies
    }
}

// This section configures the build directories for subprojects (custom build setup)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Ensure subprojects use the same build directory
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Clean task to remove generated build files
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
