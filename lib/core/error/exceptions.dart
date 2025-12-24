class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error occurred']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);
}

class FirestoreException implements Exception {
  final String message;
  const FirestoreException([this.message = 'Firestore error occurred']);
}

class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Storage error occurred']);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission denied']);
}

class LocationException implements Exception {
  final String message;
  const LocationException([this.message = 'Location error occurred']);
}

class CameraException implements Exception {
  final String message;
  const CameraException([this.message = 'Camera error occurred']);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Validation failed']);
}
