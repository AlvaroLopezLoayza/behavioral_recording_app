import '../../domain/entities/abc_record.dart';
import '../../domain/entities/behavior_occurrence.dart';

class AbcRecordModel extends AbcRecord {
  const AbcRecordModel({
    required super.id,
    required super.behaviorDefinitionId,
    required super.antecedent,
    required super.behaviorOccurrence,
    required super.consequence,
    required super.recordingType,
    super.sessionId,
    required super.observerId,
    required super.timestamp,
    super.location,
    super.notes,
  });

  factory AbcRecordModel.fromJson(Map<String, dynamic> json) {
    return AbcRecordModel(
      id: json['id'] as String,
      behaviorDefinitionId: json['behavior_definition_id'] as String,
      antecedent: json['antecedent'] as Map<String, dynamic>,
      behaviorOccurrence: _parseOccurrence(json['behavior_occurrence']),
      consequence: json['consequence'] as Map<String, dynamic>,
      recordingType: _parseRecordingType(json['recording_type'] as String),
      sessionId: json['session_id'] as String?,
      observerId: json['observer_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'behavior_definition_id': behaviorDefinitionId,
      'antecedent': antecedent,
      'behavior_occurrence': _occurrenceToJson(behaviorOccurrence),
      'consequence': consequence,
      'recording_type': recordingType.name,
      'session_id': sessionId,
      'observer_id': observerId,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'notes': notes,
    };
  }

  factory AbcRecordModel.fromEntity(AbcRecord entity) {
    return AbcRecordModel(
      id: entity.id,
      behaviorDefinitionId: entity.behaviorDefinitionId,
      antecedent: entity.antecedent,
      behaviorOccurrence: entity.behaviorOccurrence,
      consequence: entity.consequence,
      recordingType: entity.recordingType,
      sessionId: entity.sessionId,
      observerId: entity.observerId,
      timestamp: entity.timestamp,
      location: entity.location,
      notes: entity.notes,
    );
  }

  AbcRecord toEntity() {
    return AbcRecord(
      id: id,
      behaviorDefinitionId: behaviorDefinitionId,
      antecedent: antecedent,
      behaviorOccurrence: behaviorOccurrence,
      consequence: consequence,
      recordingType: recordingType,
      sessionId: sessionId,
      observerId: observerId,
      timestamp: timestamp,
      location: location,
      notes: notes,
    );
  }

  static BehaviorOccurrence _parseOccurrence(Map<String, dynamic> json) {
    return BehaviorOccurrence(
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      duration: json['duration_ms'] != null 
          ? Duration(milliseconds: json['duration_ms']) 
          : null,
      latency: json['latency_ms'] != null 
          ? Duration(milliseconds: json['latency_ms']) 
          : null,
      intensity: json['intensity'],
      frequency: json['frequency'],
      topography: json['topography'],
    );
  }

  static Map<String, dynamic> _occurrenceToJson(BehaviorOccurrence occurrence) {
    return {
      'start_time': occurrence.startTime.toIso8601String(),
      'end_time': occurrence.endTime?.toIso8601String(),
      'duration_ms': occurrence.duration?.inMilliseconds,
      'latency_ms': occurrence.latency?.inMilliseconds,
      'intensity': occurrence.intensity,
      'frequency': occurrence.frequency,
      'topography': occurrence.topography,
    };
  }

  static RecordingType _parseRecordingType(String value) {
    return RecordingType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecordingType.event,
    );
  }
}
