plugins {
    id("com.android.application")
    id("kotlin-android")
    id("kotlin-kapt")
}

android {
    compileSdkVersion(29)
    defaultConfig {
        applicationId "com.futabooo.fastlane.android.version.manage"
        minSdkVersion(23)
        targetSdkVersion(29)
        versionCode = 17
        versionName = "1.23.4"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
}