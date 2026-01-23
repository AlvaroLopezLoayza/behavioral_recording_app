import '../../domain/entities/behavior_definition.dart';

/// Data model for BehaviorDefinition
/// Converts between domain entities and JSON for Supabase
class BehaviorDefinitionModel extends BehaviorDefinition {
  const BehaviorDefinitionModel({
    required String id,
    required String name,
    required String operationalDefinition,
    required bool isObservable,
    required bool isMeasurable,
    required List<String> dimensions,
    String? patientId,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          operationalDefinition: operationalDefinition,
          isObservable: isObservable,
          isMeasurable: isMeasurable,
          dimensions: dimensions,
          patientId: patientId,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Create a model from JSON (from Supabase)
  factory BehaviorDefinitionModel.fromJson(Map<String, dynamic> json) {
    return BehaviorDefinitionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      operationalDefinition: json['operational_definition'] as String,
      isObservable: json['is_observable'] as bool? ?? false,
      isMeasurable: json['is_measurable'] as bool? ?? false,
      dimensions: (json['dimensions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      patientId: json['patient_id'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert model to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'operational_definition': operationalDefinition,
      'is_observable': isObservable,
      'is_measurable': isMeasurable,
      'dimensions': dimensions,
      'patient_id': patientId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert domain entity to model
  factory BehaviorDefinitionModel.fromEntity(BehaviorDefinition entity) {
    return BehaviorDefinitionModel(
      id: entity.id,
      name: entity.name,
      operationalDefinition: entity.operationalDefinition,
      isObservable: entity.isObservable,
      isMeasurable: entity.isMeasurable,
      dimensions: entity.dimensions,
      patientId: entity.patientId,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to domain entity
  BehaviorDefinition toEntity() {
    return BehaviorDefinition(
      id: id,
      name: name,
      operationalDefinition: operationalDefinition,
      isObservable: isObservable,
      isMeasurable: isMeasurable,
      dimensions: dimensions,
      patientId: patientId,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
