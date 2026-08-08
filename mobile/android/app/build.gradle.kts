plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")   
}

android {
    namespace = "com.example.bitaqati_as_sihiya"
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.example.bitaqati_as_sihiya"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // بقية الـ dependencies التي كانت عندك (إن وُجدت) تبقى كما هي هنا

    // مكتبة desugaring المطلوبة مع تفعيل coreLibraryDesugaringEnabled
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
      implementation(platform("com.google.firebase:firebase-bom:34.17.0"))

    // مثال: Analytics (اختياري لكن مفيد لاختبار الاتصال)
    implementation("com.google.firebase:firebase-analytics")
}