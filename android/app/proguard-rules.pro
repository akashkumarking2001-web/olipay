# Keep flutter notification listener service
-keep class id.flutter.flutter_notification_listener.** { *; }

# Keep flutter tts configuration
-keep class com.tundralabs.fluttertts.** { *; }

# Keep flutter platform channels
-keep class io.flutter.plugin.common.** { *; }

# Firebase Keep Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.firestore.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
