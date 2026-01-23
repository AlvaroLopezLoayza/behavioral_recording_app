import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/abc_record.dart';

/// Repository interface for ABC Recording operations
abstract class AbcRecordingRepository {
  /// Create a new ABC record
  Future<Either<Failure, AbcRecord>> createAbcRecord(AbcRecord record);

  /// Get records for a specific behavior definition
  Future<Either<Failure, List<AbcRecord>>> getRecordsByBehavior(String behaviorDefinitionId);

  /// Get records for a specific session
  Future<Either<Failure, List<AbcRecord>>> getRecordsBySession(String sessionId);
  
  /// Delete a record
  Future<Either<Failure, void>> deleteRecord(String id);
}
