import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/abc_record.dart';
import '../repositories/abc_recording_repository.dart';

class GetRecordsByBehaviorParams {
  final String behaviorDefinitionId;
  const GetRecordsByBehaviorParams(this.behaviorDefinitionId);
}

/// Use case for retrieving records for a specific behavior
class GetRecordsByBehavior implements UseCase<List<AbcRecord>, GetRecordsByBehaviorParams> {
  final AbcRecordingRepository repository;

  GetRecordsByBehavior(this.repository);

  @override
  Future<Either<Failure, List<AbcRecord>>> call(GetRecordsByBehaviorParams params) {
    return repository.getRecordsByBehavior(params.behaviorDefinitionId);
  }
}
