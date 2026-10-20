import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// --- Chargement sécurisé du fichier local.properties ---
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")

if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
} else {
    throw GradleException("Le fichier local.properties est INTROUVABLE à l'emplacement : ${localPropertiesFile.absolutePath}")
}

// Extraction des propriétés avec gestion d'erreur si la clé est manquante
val storeFileValue = localProperties.getProperty("STORE_FILE") ?: throw GradleException("La clé 'STORE_FILE' est manquante dans local.properties")
val storePasswordValue = localProperties.getProperty("STORE_PASSWORD") ?: throw GradleException("La clé 'STORE_PASSWORD' est manquante dans local.properties")
val keyAliasValue = localProperties.getProperty("KEY_ALIAS") ?: throw GradleException("La clé 'KEY_ALIAS' est manquante dans local.properties")
val keyPasswordValue = localProperties.getProperty("KEY_PASSWORD") ?: throw GradleException("La clé 'KEY_PASSWORD' est manquante dans local.properties")

android {
    namespace = "fr.endide.ampheria"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "fr.endide.ampheria"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(storeFileValue)
            storePassword = storePasswordValue
            keyAlias = keyAliasValue
            keyPassword = keyPasswordValue
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
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