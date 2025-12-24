import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.imageUrl,
    super.data,
    required super.timestamp,
    super.isRead,
    super.type,
  });

  // From Firestore
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      data: data['data'] != null ? Map<String, dynamic>.from(data['data']) : null,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      type: data['type'],
    );
  }

  // From Firebase Messaging RemoteMessage
  factory NotificationModel.fromRemoteMessage(
    String id,
    Map<String, dynamic> message,
  ) {
    final notification = message['notification'] as Map<String, dynamic>?;
    final data = message['data'] as Map<String, dynamic>?;

    return NotificationModel(
      id: id,
      title: notification?['title'] ?? data?['title'] ?? 'New Notification',
      body: notification?['body'] ?? data?['body'] ?? '',
      imageUrl: notification?['image'] ?? data?['image'],
      data: data,
      timestamp: DateTime.now(),
      isRead: false,
      type: data?['type'],
    );
  }

  // From local notification payload
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      type: json['type'],
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
    };
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  // From entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      imageUrl: entity.imageUrl,
      data: entity.data,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
      type: entity.type,
    );
  }
}
