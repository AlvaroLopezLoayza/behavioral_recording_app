import 'package:equatable/equatable.dart';
import '../../domain/entities/behavior_definition.dart';

abstract class BehaviorDefinitionState extends Equatable {
  const BehaviorDefinitionState();
  
  @override
  List<Object?> get props => [];
}

class BehaviorDefinitionInitial extends BehaviorDefinitionState {}

class BehaviorDefinitionLoading extends BehaviorDefinitionState {}

class BehaviorDefinitionLoaded extends BehaviorDefinitionState {
  final List<BehaviorDefinition> definitions;

  const BehaviorDefinitionLoaded(this.definitions);

  @override
  List<Object?> get props => [definitions];
}

class BehaviorDefinitionError extends BehaviorDefinitionState {
  final String message;

  const BehaviorDefinitionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for successful creation (useful for navigation/snackbar)
class BehaviorDefinitionCreated extends BehaviorDefinitionState {}

/// State for validation results
class BehaviorDefinitionValidated extends BehaviorDefinitionState {
  final bool isValid;
  final String? message;

  const BehaviorDefinitionValidated(this.isValid, [this.message]);

  @override
  List<Object?> get props => [isValid, message];
}
