import 'package:equatable/equatable.dart';

import '../../domain/entities/intervention_plan.dart';

abstract class InterventionState extends Equatable {
  const InterventionState();

  @override
  List<Object?> get props => [];
}

class InterventionInitial extends InterventionState {}

class InterventionLoading extends InterventionState {}

class InterventionLoaded extends InterventionState {
  final List<InterventionPlan> plans;

  const InterventionLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class InterventionError extends InterventionState {
  final String message;

  const InterventionError(this.message);

  @override
  List<Object?> get props => [message];
}

class InterventionOperationSuccess extends InterventionState {}
