import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/emergency_contact.dart';

class EmergencyContactModel extends EmergencyContact {
  const EmergencyContactModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.relationship,
    required super.isPrimary,
    required super.createdAt,
  });

  factory EmergencyContactModel.fromEntity(EmergencyContact contact) {
    return EmergencyContactModel(
      id: contact.id,
      name: contact.name,
      phoneNumber: contact.phoneNumber,
      relationship: contact.relationship,
      isPrimary: contact.isPrimary,
      createdAt: contact.createdAt,
    );
  }

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relationship: json['relationship'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'isPrimary': isPrimary,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
