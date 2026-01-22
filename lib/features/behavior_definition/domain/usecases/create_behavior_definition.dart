import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/behavior_definition.dart';
import '../repositories/behavior_definition_repository.dart';

/// Use case for creating a new behavior definition
/// Validates that the definition meets ABA criteria before creation
class CreateBehaviorDefinition implements UseCase<BehaviorDefinition, CreateBehaviorDefinitionParams> {
  final BehaviorDefinitionRepository repository;

  CreateBehaviorDefinition(this.repository);

  @override
  Future<Either<Failure, BehaviorDefinition>> call(CreateBehaviorDefinitionParams params) async {
    // Validate the definition first
    final validationResult = await repository.validateDefinition(params.operationalDefinition);
    
    return validationResult.fold(
      (failure) => Left(failure),
      (isValid) {
        if (!isValid) {
          return Future.value(
            const Left(ValidationFailure('Operational definition must be observable and measurable')),
          );
        }
        
        // If valid, create the definition
        return repository.createDefinition(params.definition);
      },
    );
  }
}

/// Parameters for CreateBehaviorDefinition use case
class CreateBehaviorDefinitionParams {
  final BehaviorDefinition definition;
  final String operationalDefinition;

  CreateBehaviorDefinitionParams({
    required this.definition,
    required this.operationalDefinition,
  });
}
