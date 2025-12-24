import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpWithEmailUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String name;
  final UserRole role;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
}
