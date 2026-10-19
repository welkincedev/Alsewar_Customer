# Proguard rules for Al Sewar Customer App
# Issue 2 Fix: Prevent TypeToken runtime crash in ScheduledNotificationBootReceiver / FlutterLocalNotificationsPlugin

# Preserve generic type signatures for Gson TypeToken reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Preserve Flutter Local Notifications plugin and receiver classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# Preserve Gson models and serialized fields
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter framework base proguard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Suppress warnings for Play Core deferred components when not used
-dontwarn com.google.android.play.core.**
