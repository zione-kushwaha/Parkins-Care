import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medication_entity.dart';

abstract class MedicationRepository {
  Future<Either<Failure, List<MedicationEntity>>> getMedications(String userId);

  Future<Either<Failure, MedicationEntity>> addMedication(
    MedicationEntity medication,
  );

  Future<Either<Failure, MedicationEntity>> updateMedication(
    MedicationEntity medication,
  );

  Future<Either<Failure, void>> deleteMedication(String medicationId);

  Future<Either<Failure, List<MedicationLogEntity>>> getMedicationLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, MedicationLogEntity>> logMedication(
    MedicationLogEntity log,
  );

  Future<Either<Failure, double>> getAdherenceRate({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Stream<List<MedicationEntity>> watchMedications(String userId);
}
