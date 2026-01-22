import 'package:equatable/equatable.dart';
import '../../domain/entities/intervention_plan.dart';

abstract class InterventionEvent extends Equatable {
  const InterventionEvent();

  @override
  List<Object?> get props => [];
}

class LoadInterventionPlans extends InterventionEvent {
  final String hypothesisId;

  const LoadInterventionPlans(this.hypothesisId);

  @override
  List<Object?> get props => [hypothesisId];
}

class CreateInterventionPlan extends InterventionEvent {
  final InterventionPlan plan;

  const CreateInterventionPlan(this.plan);

  @override
  List<Object?> get props => [plan];
}

class UpdateInterventionPlan extends InterventionEvent {
  final InterventionPlan plan;

  const UpdateInterventionPlan(this.plan);

  @override
  List<Object?> get props => [plan];
}

class DeleteInterventionPlan extends InterventionEvent {
  final String planId;

  const DeleteInterventionPlan(this.planId);

  @override
  List<Object?> get props => [planId];
}
