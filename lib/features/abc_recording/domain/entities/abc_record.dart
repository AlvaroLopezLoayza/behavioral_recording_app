import 'package:equatable/equatable.dart';
import 'behavior_occurrence.dart';

enum RecordingType { event, interval, continuous }

/// Entity representing a single ABC (Antecedent-Behavior-Consequence) record
class AbcRecord extends Equatable {
  final String id;
  final String behaviorDefinitionId;
  final Map<String, dynamic> antecedent; // Flexible structure for now
  final BehaviorOccurrence behaviorOccurrence;
  final Map<String, dynamic> consequence; // Flexible structure for now
  final RecordingType recordingType;
  final String? sessionId;
  final String observerId;
  final DateTime timestamp;
  final String? location;
  final String? notes;

  const AbcRecord({
    required this.id,
    required this.behaviorDefinitionId,
    required this.antecedent,
    required this.behaviorOccurrence,
    required this.consequence,
    required this.recordingType,
    this.sessionId,
    required this.observerId,
    required this.timestamp,
    this.location,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        behaviorDefinitionId,
        antecedent,
        behaviorOccurrence,
        consequence,
        recordingType,
        sessionId,
        observerId,
        timestamp,
        location,
        notes,
      ];
}
