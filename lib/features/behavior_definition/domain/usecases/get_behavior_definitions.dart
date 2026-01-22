import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/behavior_definition.dart';
import '../repositories/behavior_definition_repository.dart';

/// Use case for retrieving all behavior definitions for the current user
class GetBehaviorDefinitions implements UseCase<List<BehaviorDefinition>, NoParams> {
  final BehaviorDefinitionRepository repository;

  GetBehaviorDefinitions(this.repository);

  @override
  Future<Either<Failure, List<BehaviorDefinition>>> call(NoParams params) {
    return repository.getAllDefinitions();
  }
}
