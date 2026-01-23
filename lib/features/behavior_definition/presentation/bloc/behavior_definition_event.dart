import 'package:equatable/equatable.dart';

import '../../domain/entities/behavior_definition.dart';

abstract class BehaviorDefinitionEvent extends Equatable {
  const BehaviorDefinitionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all behavior definitions
class LoadBehaviorDefinitions extends BehaviorDefinitionEvent {
  final String? patientId;
  const LoadBehaviorDefinitions({this.patientId});
  
  @override
  List<Object?> get props => [patientId];
}

/// Event to create a new behavior definition
class CreateBehaviorDefinitionEvent extends BehaviorDefinitionEvent {
  final BehaviorDefinition definition;

  const CreateBehaviorDefinitionEvent(this.definition);

  @override
  List<Object?> get props => [definition];
}

/// Event to validate an operational definition while typing
class ValidateDefinitionEvent extends BehaviorDefinitionEvent {
  final String operationalDefinition;

  const ValidateDefinitionEvent(this.operationalDefinition);

  @override
  List<Object?> get props => [operationalDefinition];
}
