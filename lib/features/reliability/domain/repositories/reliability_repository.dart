import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reliability_record.dart';

abstract class ReliabilityRepository {
  Future<Either<Failure, List<ReliabilityRecord>>> getReliabilityByPatient(String patientId);
  
  Future<Either<Failure, ReliabilityRecord>> saveReliabilityRecord(ReliabilityRecord record);

  Future<Either<Failure, double>> calculateIOA({
    required String behaviorDefinitionId,
    required String observer1Id,
    required String observer2Id,
    required DateTime startTime,
    required DateTime endTime,
    required String method,
    Map<String, dynamic>? parameters,
  });
}
