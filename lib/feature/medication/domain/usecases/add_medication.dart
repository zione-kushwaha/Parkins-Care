import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class AddMedicationUseCase
    implements UseCase<MedicationEntity, AddMedicationParams> {
  final MedicationRepository repository;

  AddMedicationUseCase(this.repository);

  @override
  Future<Either<Failure, MedicationEntity>> call(
    AddMedicationParams params,
  ) async {
    return await repository.addMedication(params.medication);
  }
}

class AddMedicationParams {
  final MedicationEntity medication;

  const AddMedicationParams({required this.medication});
}
