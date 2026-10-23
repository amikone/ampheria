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

# Supabase & Realtime & Auth & Models
-keep class com.supabase.** { *; }
-keep class io.supabase.** { *; }
-keep class fr.endide.ampheria.models.** { *; }

# Flutter Chat UI & Material UI & Flyer Chat (Fix Release crash on MaterialLocalizations)
-dontwarn material_ui.**
-keep class material_ui.** { *; }
-dontwarn flutter_chat_ui.**
-keep class flutter_chat_ui.** { *; }
-dontwarn flutter_chat_core.**
-keep class flutter_chat_core.** { *; }
-dontwarn flyer_chat_image_message.**
-keep class flyer_chat_image_message.** { *; }

# SharedPreferences & Local Storage
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Geolocator, InAppPurchase, ImagePicker, AppLinks
-keep class com.baseflow.geolocator.** { *; }
-keep class io.flutter.plugins.inapppurchase.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class com.llfeng.app_links.** { *; }

# Network & OkHttp & WebSockets & Coroutines
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keep class kotlinx.coroutines.** { *; }
