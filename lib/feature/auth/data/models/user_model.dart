import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.phoneNumber,
    required super.name,
    required super.role,
    super.profileImageUrl,
    required super.createdAt,
    super.lastLoginAt,
    super.dateOfBirth,
    super.emergencyContact1,
    super.emergencyContact2,
    super.emergencyContact3,
    super.patientIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.patient,
      ),
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      dateOfBirth: json['dateOfBirth'] as String?,
      emergencyContact1: json['emergencyContact1'] as String?,
      emergencyContact2: json['emergencyContact2'] as String?,
      emergencyContact3: json['emergencyContact3'] as String?,
      patientIds: json['patientIds'] != null
          ? List<String>.from(json['patientIds'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'name': name,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'dateOfBirth': dateOfBirth,
      'emergencyContact1': emergencyContact1,
      'emergencyContact2': emergencyContact2,
      'emergencyContact3': emergencyContact3,
      'patientIds': patientIds,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? name,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? dateOfBirth,
    String? emergencyContact1,
    String? emergencyContact2,
    String? emergencyContact3,
    List<String>? patientIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emergencyContact1: emergencyContact1 ?? this.emergencyContact1,
      emergencyContact2: emergencyContact2 ?? this.emergencyContact2,
      emergencyContact3: emergencyContact3 ?? this.emergencyContact3,
      patientIds: patientIds ?? this.patientIds,
    );
  }
}
