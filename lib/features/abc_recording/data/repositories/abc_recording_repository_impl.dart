import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/abc_record.dart';
import '../../domain/repositories/abc_recording_repository.dart';
import '../datasources/abc_recording_remote_datasource.dart';
import '../models/abc_record_model.dart';

class AbcRecordingRepositoryImpl implements AbcRecordingRepository {
  final AbcRecordingRemoteDataSource remoteDataSource;

  AbcRecordingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AbcRecord>> createAbcRecord(AbcRecord record) async {
    try {
      final model = AbcRecordModel.fromEntity(record);
      final result = await remoteDataSource.createAbcRecord(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AbcRecord>>> getRecordsByBehavior(String behaviorDefinitionId) async {
    try {
      final models = await remoteDataSource.getRecordsByBehavior(behaviorDefinitionId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AbcRecord>>> getRecordsBySession(String sessionId) async {
    try {
      final models = await remoteDataSource.getRecordsBySession(sessionId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord(String id) async {
    try {
      await remoteDataSource.deleteRecord(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
