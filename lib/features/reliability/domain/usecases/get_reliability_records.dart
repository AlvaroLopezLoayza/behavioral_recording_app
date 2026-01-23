import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reliability_record.dart';
import '../repositories/reliability_repository.dart';

class GetReliabilityRecords implements UseCase<List<ReliabilityRecord>, String> {
  final ReliabilityRepository repository;

  GetReliabilityRecords(this.repository);

  @override
  Future<Either<Failure, List<ReliabilityRecord>>> call(String patientId) async {
    return await repository.getReliabilityByPatient(patientId);
  }
}
