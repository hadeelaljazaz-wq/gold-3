# ============================================================================
# Gold Nightmare Pro - ProGuard Rules
# ============================================================================
# 
# هذا الملف يحتوي على قواعد ProGuard/R8 لتحسين وحماية التطبيق
# يتم تطبيقه تلقائياً عند البناء بوضع Release
# 
# Documentation: https://www.guardsquare.com/manual/configuration/usage
# ============================================================================

# ============================================================================
# FLUTTER CORE
# ============================================================================

# Keep Flutter engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Flutter embedding
-keep class io.flutter.embedding.** { *; }

# ============================================================================
# KOTLIN
# ============================================================================

-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}
-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
    static void checkParameterIsNotNull(java.lang.Object, java.lang.String);
}

# ============================================================================
# HTTP & NETWORKING
# ============================================================================

# OkHttp
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Retrofit (if used)
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.KotlinExtensions
-dontwarn retrofit2.KotlinExtensions$*

# ============================================================================
# JSON SERIALIZATION
# ============================================================================

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep model classes (adjust package names as needed)
-keep class com.goldennightmare.pro.models.** { *; }
-keep class com.goldennightmare.pro.services.** { *; }

# ============================================================================
# FIREBASE (if used)
# ============================================================================

-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# ============================================================================
# BUILD CONFIG
# ============================================================================

# Keep BuildConfig
-keep class **.BuildConfig { *; }

# ============================================================================
# HIVE (Local Storage)
# ============================================================================

-keep class * extends hive.HiveObject
-keep class * extends hive.HiveAdapter
-keepclassmembers class * extends hive.HiveObject {
    <fields>;
}

# ============================================================================
# RIVERPOD (State Management)
# ============================================================================

-keep class * extends riverpod.** { *; }
-keepclassmembers class * {
    @riverpod.* <methods>;
}

# ============================================================================
# GENERAL RULES
# ============================================================================

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom view constructors
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============================================================================
# OPTIMIZATION
# ============================================================================

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Remove debug code
-assumenosideeffects class * {
    void debug*(...);
    void trace*(...);
}

# ============================================================================
# WARNINGS SUPPRESSION
# ============================================================================

-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# ============================================================================
# CUSTOM APP RULES
# ============================================================================

# Keep API keys class (but obfuscate values)
-keep class com.goldennightmare.pro.core.constants.ApiKeys {
    public static java.lang.String get*();
}

# Keep analysis engines
-keep class com.goldennightmare.pro.services.golden_nightmare.** { *; }
-keep class com.goldennightmare.pro.services.engines.** { *; }

# Keep models used in JSON serialization
-keep class com.goldennightmare.pro.models.Candle { *; }
-keep class com.goldennightmare.pro.models.Recommendation { *; }
-keep class com.goldennightmare.pro.models.ScalpingSignal { *; }
-keep class com.goldennightmare.pro.models.SwingSignal { *; }
-keep class com.goldennightmare.pro.models.TechnicalIndicators { *; }

# ============================================================================
# END OF RULES
# ============================================================================
