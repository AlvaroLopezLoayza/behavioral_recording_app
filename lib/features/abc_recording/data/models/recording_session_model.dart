import '../../domain/entities/recording_session.dart';

class RecordingSessionModel extends RecordingSession {
  const RecordingSessionModel({
    required super.id,
    required super.patientId,
    required super.startTime,
    super.endTime,
    super.behaviorDefinitionId,
    super.observerId,
  });

  factory RecordingSessionModel.fromJson(Map<String, dynamic> json) {
    return RecordingSessionModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      behaviorDefinitionId: json['behavior_definition_id'] as String?,
      observerId: json['observer_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'behavior_definition_id': behaviorDefinitionId,
      'observer_id': observerId,
    };
  }

  factory RecordingSessionModel.fromEntity(RecordingSession entity) {
    return RecordingSessionModel(
      id: entity.id,
      patientId: entity.patientId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      behaviorDefinitionId: entity.behaviorDefinitionId,
      observerId: entity.observerId,
    );
  }

  RecordingSession toEntity() {
    return RecordingSession(
      id: id,
      patientId: patientId,
      startTime: startTime,
      endTime: endTime,
      behaviorDefinitionId: behaviorDefinitionId,
      observerId: observerId,
    );
  }
}
