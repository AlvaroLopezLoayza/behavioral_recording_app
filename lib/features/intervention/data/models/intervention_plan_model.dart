import '../domain/entities/intervention_plan.dart';
import 'intervention_strategy_model.dart';

class InterventionPlanModel extends InterventionPlan {
  const InterventionPlanModel({
    required String id,
    required String hypothesisId,
    required String patientId,
    required String replacementBehavior,
    required List<InterventionStrategy> strategies,
    required InterventionStatus status,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          hypothesisId: hypothesisId,
          patientId: patientId,
          replacementBehavior: replacementBehavior,
          strategies: strategies,
          status: status,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory InterventionPlanModel.fromJson(Map<String, dynamic> json) {
    return InterventionPlanModel(
      id: json['id'],
      hypothesisId: json['hypothesis_id'],
      patientId: json['patient_id'],
      replacementBehavior: json['replacement_behavior'],
      strategies: (json['strategies'] as List? ?? [])
          .map((s) => InterventionStrategyModel.fromJson(s))
          .toList(),
      status: InterventionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InterventionStatus.proposed,
      ),
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hypothesis_id': hypothesisId,
      'patient_id': patientId,
      'replacement_behavior': replacementBehavior,
      'strategies': strategies
          .map((s) => InterventionStrategyModel.fromEntity(s).toJson())
          .toList(),
      'status': status.name,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static InterventionPlanModel fromEntity(InterventionPlan plan) {
    return InterventionPlanModel(
      id: plan.id,
      hypothesisId: plan.hypothesisId,
      patientId: plan.patientId,
      replacementBehavior: plan.replacementBehavior,
      strategies: plan.strategies,
      status: plan.status,
      createdBy: plan.createdBy,
      createdAt: plan.createdAt,
      updatedAt: plan.updatedAt,
    );
  }
}
