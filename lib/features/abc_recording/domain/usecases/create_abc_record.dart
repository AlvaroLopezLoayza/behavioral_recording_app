import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/abc_record.dart';
import '../repositories/abc_recording_repository.dart';

/// Use case for creating a new ABC record
class CreateAbcRecord implements UseCase<AbcRecord, AbcRecord> {
  final AbcRecordingRepository repository;

  CreateAbcRecord(this.repository);

  @override
  Future<Either<Failure, AbcRecord>> call(AbcRecord params) {
    return repository.createAbcRecord(params);
  }
}
