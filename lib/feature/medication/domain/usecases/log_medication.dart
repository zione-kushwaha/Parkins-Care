import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class LogMedicationUseCase
    implements UseCase<MedicationLogEntity, LogMedicationParams> {
  final MedicationRepository repository;

  LogMedicationUseCase(this.repository);

  @override
  Future<Either<Failure, MedicationLogEntity>> call(
    LogMedicationParams params,
  ) async {
    return await repository.logMedication(params.log);
  }
}

class LogMedicationParams {
  final MedicationLogEntity log;

  const LogMedicationParams({required this.log});
}
