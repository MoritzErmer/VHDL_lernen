plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "de.vhdllernen.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "de.vhdllernen.app"
        minSdk = 26
        targetSdk = 35
        // CI passes -PversionCode / -PversionName for releases.
        versionCode = (findProperty("versionCode") as String?)?.toIntOrNull() ?: 1
        versionName = (findProperty("versionName") as String?) ?: "0.1.0-dev"
    }

    // Release signing: unlike DesignLanguages the key is NOT in the repository (this repository is public).
    // CI writes the keystore from the secret VHDL_KEYSTORE_BASE64 and sets VHDL_KEYSTORE_FILE/-PASSWORD.
    // Local release builds without these variables fall back to the debug key (only for testing).
    val releaseKeystore = System.getenv("VHDL_KEYSTORE_FILE")?.let { file(it) }?.takeIf { it.exists() }
    signingConfigs {
        if (releaseKeystore != null) {
            create("release") {
                storeFile = releaseKeystore
                storePassword = System.getenv("VHDL_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("VHDL_KEY_ALIAS") ?: "vhdllernen"
                keyPassword = System.getenv("VHDL_KEY_PASSWORD") ?: System.getenv("VHDL_KEYSTORE_PASSWORD")
                enableV1Signing = false
                enableV2Signing = true
                enableV3Signing = true
            }
        }
    }

    buildTypes {
        release {
            isDebuggable = false
            isMinifyEnabled = false
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
        }
    }

    // The lessons are bundled from content/ so the app works offline right after installation.
    sourceSets["main"].assets.srcDir(rootProject.file("content"))

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    buildFeatures {
        compose = true
        buildConfig = true
    }
    testOptions {
        unitTests.isIncludeAndroidResources = true
        unitTests.all {
            it.systemProperty("screenshotDir", rootProject.file("docs/screenshots").path)
            it.systemProperty("screenshots", project.hasProperty("screenshots").toString())
            it.systemProperty("contentFile", rootProject.file("content/haeppchen.json").path)
        }
    }
}

dependencies {
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.ui)
    implementation(libs.compose.foundation)
    implementation(libs.compose.material3)
    implementation(libs.compose.icons)
    implementation(libs.androidx.core)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.compose)
    implementation(libs.kotlinx.coroutines)
    implementation(libs.compose.tooling.preview)
    debugImplementation(libs.compose.tooling)
    debugImplementation(libs.compose.ui.test.manifest)

    // Unit tests (pure logic) + screenshot tests (Robolectric native graphics): -Pscreenshots
    testImplementation(libs.junit)
    testImplementation(libs.json)
    testImplementation(libs.robolectric)
    testImplementation(platform(libs.compose.bom))
    testImplementation(libs.compose.ui.test.junit4)
}

kotlin {
    compilerOptions { jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17) }
}
