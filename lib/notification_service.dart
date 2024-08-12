import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize({String? deviceToken}) async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Handling foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Here you can update your UI or show notifications
      print("Received a message while in foreground!");
      print("Message data: ${message.data}");
    });

    // Handling notifications when they are clicked and the app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked!");
      // Navigate to desired screen or handle other logic
    });

    // You might want to send this token to your server
    if (deviceToken != null) {
      print("Firebase Messaging Token: $deviceToken");
      // Optionally handle token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        // Save the new token by sending it to your server
        print("Firebase Messaging Token Refreshed: $newToken");
      });
    }
  }

  static Future<String?> getDeviceToken() async {
    return await _messaging.getToken();
  }
}
