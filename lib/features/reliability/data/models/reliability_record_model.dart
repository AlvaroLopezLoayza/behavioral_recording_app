import '../../domain/entities/reliability_record.dart';

class ReliabilityRecordModel extends ReliabilityRecord {
  const ReliabilityRecordModel({
    required super.id,
    required super.patientId,
    required super.behaviorDefinitionId,
    required super.observer1Id,
    required super.observer2Id,
    required super.method,
    required super.score,
    required super.startTime,
    required super.endTime,
    required super.parameters,
    required super.createdAt,
  });

  factory ReliabilityRecordModel.fromJson(Map<String, dynamic> json) {
    return ReliabilityRecordModel(
      id: json['id'],
      patientId: json['patient_id'],
      behaviorDefinitionId: json['behavior_definition_id'],
      observer1Id: json['observer_1_id'],
      observer2Id: json['observer_2_id'],
      method: json['method'],
      score: (json['score'] as num).toDouble(),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      parameters: json['parameters'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'behavior_definition_id': behaviorDefinitionId,
      'observer_1_id': observer1Id,
      'observer_2_id': observer2Id,
      'method': method,
      'score': score,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'parameters': parameters,
    };
  }

  factory ReliabilityRecordModel.fromEntity(ReliabilityRecord entity) {
    return ReliabilityRecordModel(
      id: entity.id,
      patientId: entity.patientId,
      behaviorDefinitionId: entity.behaviorDefinitionId,
      observer1Id: entity.observer1Id,
      observer2Id: entity.observer2Id,
      method: entity.method,
      score: entity.score,
      startTime: entity.startTime,
      endTime: entity.endTime,
      parameters: entity.parameters,
      createdAt: entity.createdAt,
    );
  }
}
