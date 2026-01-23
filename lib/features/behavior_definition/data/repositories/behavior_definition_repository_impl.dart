import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/behavior_definition.dart';
import '../../domain/repositories/behavior_definition_repository.dart';
import '../datasources/behavior_definition_remote_datasource.dart';
import '../models/behavior_definition_model.dart';

/// Implementation of BehaviorDefinitionRepository
/// Handles error conversion from exceptions to failures
/// Returns Either<Failure, T> for all operations
class BehaviorDefinitionRepositoryImpl implements BehaviorDefinitionRepository {
  final BehaviorDefinitionRemoteDataSource remoteDataSource;

  BehaviorDefinitionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BehaviorDefinition>> createDefinition(
    BehaviorDefinition definition,
  ) async {
    try {
      final model = BehaviorDefinitionModel.fromEntity(definition);
      final result = await remoteDataSource.createDefinition(model);
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
  Future<Either<Failure, List<BehaviorDefinition>>> getAllDefinitions({String? patientId}) async {
    try {
      final models = await remoteDataSource.getDefinitions(patientId: patientId);
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
  Future<Either<Failure, BehaviorDefinition>> getDefinitionById(String id) async {
    try {
      // TODO: Implement getDefinitionById in remote datasource
      // For now, get all and filter
      final models = await remoteDataSource.getDefinitions();
      final model = models.firstWhere(
        (m) => m.id == id,
        orElse: () => throw NotFoundException('Behavior definition not found'),
      );
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BehaviorDefinition>> updateDefinition(
    BehaviorDefinition definition,
  ) async {
    try {
      final model = BehaviorDefinitionModel.fromEntity(definition);
      final result = await remoteDataSource.updateDefinition(model);
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
  Future<Either<Failure, void>> deleteDefinition(String id) async {
    try {
      await remoteDataSource.deleteDefinition(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> validateDefinition(String operationalDefinition) async {
    try {
      // Simple validation logic for ABA principles
      // Must be at least 10 characters and contain action verbs
      if (operationalDefinition.length < 10) {
        return const Right(false);
      }
      
      // Check for vague terms that aren't observable
      final vagueTerms = ['aggressive', 'bad', 'good', 'nice', 'mean', 'upset'];
      final lowerDef = operationalDefinition.toLowerCase();
      
      for (final term in vagueTerms) {
        if (lowerDef.contains(term) && !lowerDef.contains('such as')) {
          return const Right(false);
        }
      }
      
      return const Right(true);
    } catch (e) {
      return Left(ValidationFailure('Failed to validate definition'));
    }
  }
}
