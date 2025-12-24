import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
    : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred'])
    : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred'])
    : super(message);
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed'])
    : super(message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([String message = 'Invalid credentials'])
    : super(message);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([String message = 'User not found'])
    : super(message);
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([String message = 'Email already in use'])
    : super(message);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([String message = 'Password is too weak'])
    : super(message);
}

// Firebase failures
class FirestoreFailure extends Failure {
  const FirestoreFailure([String message = 'Firestore error occurred'])
    : super(message);
}

class StorageFailure extends Failure {
  const StorageFailure([String message = 'Storage error occurred'])
    : super(message);
}

// Permission failures
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([String message = 'Permission denied'])
    : super(message);
}

// Location failures
class LocationFailure extends Failure {
  const LocationFailure([String message = 'Location error occurred'])
    : super(message);
}

// Camera failures
class CameraFailure extends Failure {
  const CameraFailure([String message = 'Camera error occurred'])
    : super(message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed'])
    : super(message);
}
