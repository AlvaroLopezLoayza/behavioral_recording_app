import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reliability_record.dart';
import '../repositories/reliability_repository.dart';

class SaveReliabilityRecord implements UseCase<ReliabilityRecord, ReliabilityRecord> {
  final ReliabilityRepository repository;

  SaveReliabilityRecord(this.repository);

  @override
  Future<Either<Failure, ReliabilityRecord>> call(ReliabilityRecord record) async {
    return await repository.saveReliabilityRecord(record);
  }
}
