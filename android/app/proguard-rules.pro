# flutter_local_notifications serializes scheduled notifications with Gson.
# R8 full mode otherwise removes the generic signature used by TypeToken,
# causing ScheduledNotificationReceiver and its boot receiver to crash.
-keepattributes Signature
-keep,allowobfuscation,allowshrinking,allowoptimization class com.google.gson.reflect.TypeToken { *; }
-keep,allowobfuscation,allowshrinking,allowoptimization class * extends com.google.gson.reflect.TypeToken
