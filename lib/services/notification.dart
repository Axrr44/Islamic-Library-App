
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationFBM {
  /// Create instance of FBM :
  final _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize notification for this app or device:
  Future<void> initNotifications() async {
    try {
      await _firebaseMessaging.requestPermission();
      String? token = await _firebaseMessaging.getToken();
      print("Token : $token");
      handleBackgroundNotification();
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  /// handle notifications when received:
  void handleMessage(RemoteMessage? message) {
    try {
      if (message == null) return;
      // Handle the message here
    } catch (e) {
      print("Error handling message: $e");
    }
  }

  /// handle notifications in case of app is terminated:
  Future handleBackgroundNotification() async {
    try {
      FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    } catch (e) {
      print("Error handling background notification: $e");
    }
  }
}
