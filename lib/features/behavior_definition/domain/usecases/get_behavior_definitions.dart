import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/behavior_definition.dart';
import '../repositories/behavior_definition_repository.dart';

/// Use case for retrieving all behavior definitions for the current user
class GetBehaviorDefinitionsParams extends Equatable {
  final String? patientId;
  const GetBehaviorDefinitionsParams({this.patientId});
  
  @override
  List<Object?> get props => [patientId];
}

class GetBehaviorDefinitions implements UseCase<List<BehaviorDefinition>, GetBehaviorDefinitionsParams> {
  final BehaviorDefinitionRepository repository;

  GetBehaviorDefinitions(this.repository);

  @override
  Future<Either<Failure, List<BehaviorDefinition>>> call(GetBehaviorDefinitionsParams params) {
    return repository.getAllDefinitions(patientId: params.patientId);
  }
}
