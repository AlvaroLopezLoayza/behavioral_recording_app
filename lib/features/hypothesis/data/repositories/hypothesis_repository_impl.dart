import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/hypothesis_remote_datasource.dart';
import '../../domain/entities/functional_hypothesis.dart';
import '../../domain/repositories/hypothesis_repository.dart';
import '../models/functional_hypothesis_model.dart';

class HypothesisRepositoryImpl implements HypothesisRepository {
  final HypothesisRemoteDataSource remoteDataSource;

  HypothesisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FunctionalHypothesis>> createHypothesis(FunctionalHypothesis hypothesis) async {
    try {
      final model = FunctionalHypothesisModel.fromEntity(hypothesis);
      final result = await remoteDataSource.createHypothesis(model);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FunctionalHypothesis>>> getHypothesesByBehavior(String behaviorId) async {
    try {
      final result = await remoteDataSource.getHypothesesByBehavior(behaviorId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, FunctionalHypothesis>> updateHypothesis(FunctionalHypothesis hypothesis) async {
    try {
      final model = FunctionalHypothesisModel.fromEntity(hypothesis);
      final result = await remoteDataSource.updateHypothesis(model);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteHypothesis(String id) async {
    try {
      await remoteDataSource.deleteHypothesis(id);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
