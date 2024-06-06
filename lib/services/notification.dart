import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationFBM {
  /// Create instance of FBM :
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize notification for this app or device:
  Future<void> initNotifications() async {
    try {
      // Request permissions for iOS
      await _firebaseMessaging.requestPermission();

      // Initialize the FlutterLocalNotificationsPlugin
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      String? token = await _firebaseMessaging.getToken();
      print("Token : $token");

      // Handle background notifications
      handleBackgroundNotification();

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showNotification(message);
      });
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  /// Handle notifications when received:
  void handleMessage(RemoteMessage? message) {
    try {
      if (message == null) return;

      // Extract notification data
      String? title = message.notification?.title;
      String? body = message.notification?.body;
      Map<String, dynamic> data = message.data;

      // Print the message data
      print("Notification title: $title");
      print("Notification body: $body");
      print("Notification data: $data");

      // Perform actions based on the notification
      if (data['type'] == 'chat') {
        // Navigate to chat screen or update chat UI
      } else if (data['type'] == 'alert') {
        // Show alert dialog
      }

      // You can also show a local notification
      _showNotification(message);
    } catch (e) {
      print("Error handling message: $e");
    }
  }


  /// Handle notifications in case the app is terminated:
  Future handleBackgroundNotification() async {
    try {
      FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    } catch (e) {
      print("Error handling background notification: $e");
    }
  }

  /// Show notification when the app is in foreground
  Future<void> _showNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'islamic_library', // channel id
        'islamic_library', // channel name
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: 'Default_Sound',
      );
    } catch (e) {
      print("Error showing notification: $e");
    }
  }
}
