import 'package:equatable/equatable.dart';

/// Domain entity representing a behavioral definition
/// This enforces the principles of Applied Behavior Analysis by requiring
/// operational definitions to be observable and measurable
class BehaviorDefinition extends Equatable {
  final String id;
  final String name;
  final String operationalDefinition;
  final bool isObservable;
  final bool isMeasurable;
  final List<String> dimensions;
  final String? patientId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BehaviorDefinition({
    required this.id,
    required this.name,
    required this.operationalDefinition,
    required this.isObservable,
    required this.isMeasurable,
    required this.dimensions,
    this.patientId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Validates if this definition meets ABA criteria
  bool get isValid => isObservable && isMeasurable && operationalDefinition.length >= 10;

  @override
  List<Object?> get props => [
        id,
        name,
        operationalDefinition,
        isObservable,
        isMeasurable,
        dimensions,
        dimensions,
        patientId,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
