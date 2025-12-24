import 'package:equatable/equatable.dart';

enum UserRole { patient, caregiver }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String name;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Patient-specific fields
  final String? dateOfBirth;
  final String? emergencyContact1;
  final String? emergencyContact2;
  final String? emergencyContact3;

  // Caregiver-specific fields
  final List<String>? patientIds;

  const UserEntity({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.name,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.dateOfBirth,
    this.emergencyContact1,
    this.emergencyContact2,
    this.emergencyContact3,
    this.patientIds,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    phoneNumber,
    name,
    role,
    profileImageUrl,
    createdAt,
    lastLoginAt,
    dateOfBirth,
    emergencyContact1,
    emergencyContact2,
    emergencyContact3,
    patientIds,
  ];
}
