import 'package:equatable/equatable.dart';
import 'intervention_strategy.dart';

enum InterventionStatus {
  proposed,
  active,
  discontinued,
}

class InterventionPlan extends Equatable {
  final String id;
  final String hypothesisId;
  final String patientId;
  final String replacementBehavior;
  final List<InterventionStrategy> strategies;
  final InterventionStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InterventionPlan({
    required this.id,
    required this.hypothesisId,
    required this.patientId,
    required this.replacementBehavior,
    required this.strategies,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        hypothesisId,
        patientId,
        replacementBehavior,
        strategies,
        status,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
