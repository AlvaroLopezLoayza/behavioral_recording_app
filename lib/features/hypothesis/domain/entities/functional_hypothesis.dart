import 'package:equatable/equatable.dart';
import 'function_type.dart';

enum HypothesisStatus { draft, active, disproven, verified }

class FunctionalHypothesis extends Equatable {
  final String id;
  final String behaviorDefinitionId;
  final FunctionType functionType;
  final String description;
  final double confidence;
  final HypothesisStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FunctionalHypothesis({
    required this.id,
    required this.behaviorDefinitionId,
    required this.functionType,
    required this.description,
    required this.confidence,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        behaviorDefinitionId,
        functionType,
        description,
        confidence,
        status,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
