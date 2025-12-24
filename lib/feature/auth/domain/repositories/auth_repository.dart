import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, UserEntity>> signInWithPhoneNumber({
    required String phoneNumber,
    required String verificationCode,
  });

  Future<Either<Failure, void>> sendPhoneVerificationCode({
    required String phoneNumber,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> resetPassword({required String email});

  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  });

  Stream<UserEntity?> get authStateChanges;
}
