import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  String? title;
  String? body;
  String? image;
  Timestamp? timestamp;
  bool? isRead;

  Notification(
      {required this.title,
      required this.body,
      required this.image,
      required this.timestamp,
      required this.isRead});

  Notification.fromMap(Map<String, dynamic> data) {
    title = data['title'];
    body = data['body'];
    image = data['image'];
    timestamp = data['timestamp'];
    isRead = data['read'];
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'image': image,
      'timestamp': timestamp,
      'read': isRead,
    };
  }
}
