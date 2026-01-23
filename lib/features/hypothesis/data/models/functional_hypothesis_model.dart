import '../../domain/entities/function_type.dart';
import '../../domain/entities/functional_hypothesis.dart';

class FunctionalHypothesisModel extends FunctionalHypothesis {
  const FunctionalHypothesisModel({
    required String id,
    required String behaviorDefinitionId,
    required FunctionType functionType,
    required String description,
    required double confidence,
    required HypothesisStatus status,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          behaviorDefinitionId: behaviorDefinitionId,
          functionType: functionType,
          description: description,
          confidence: confidence,
          status: status,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory FunctionalHypothesisModel.fromJson(Map<String, dynamic> json) {
    return FunctionalHypothesisModel(
      id: json['id'],
      behaviorDefinitionId: json['behavior_definition_id'],
      functionType: FunctionType.values.firstWhere(
        (e) => e.name == json['function_type'],
        orElse: () => FunctionType.unknown,
      ),
      description: json['description'],
      confidence: (json['confidence'] as num).toDouble(),
      status: HypothesisStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HypothesisStatus.draft,
      ),
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'behavior_definition_id': behaviorDefinitionId,
      'function_type': functionType.name,
      'description': description,
      'confidence': confidence,
      'status': status.name,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FunctionalHypothesisModel.fromEntity(FunctionalHypothesis entity) {
    return FunctionalHypothesisModel(
      id: entity.id,
      behaviorDefinitionId: entity.behaviorDefinitionId,
      functionType: entity.functionType,
      description: entity.description,
      confidence: entity.confidence,
      status: entity.status,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
