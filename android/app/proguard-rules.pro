# Disable aggressive R8 optimizations that break Flutter/Supabase reflection
-dontoptimize

# Flutter Deferred Components & Play Core
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Flutter Wrapper & Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase & Realtime & Auth
-keep class com.supabase.** { *; }
-keep class io.supabase.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }

# SharedPreferences & Local Storage
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Network & OkHttp & WebSockets
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
