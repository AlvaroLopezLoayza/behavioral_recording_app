import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recording_session.dart';
import '../repositories/abc_recording_repository.dart';

class CreateRecordingSession implements UseCase<RecordingSession, RecordingSession> {
  final AbcRecordingRepository repository;

  CreateRecordingSession(this.repository);

  @override
  Future<Either<Failure, RecordingSession>> call(RecordingSession params) async {
    return await repository.createRecordingSession(params);
  }
}
