import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class GetMedicationsUseCase implements UseCase<List<MedicationEntity>, String> {
  final MedicationRepository repository;

  GetMedicationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MedicationEntity>>> call(String userId) async {
    return await repository.getMedications(userId);
  }
}
