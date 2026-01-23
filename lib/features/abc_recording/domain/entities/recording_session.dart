import 'package:equatable/equatable.dart';

class RecordingSession extends Equatable {
  final String id;
  final String patientId;
  final DateTime startTime;
  final DateTime? endTime;
  final String? behaviorDefinitionId;
  final String? observerId;

  const RecordingSession({
    required this.id,
    required this.patientId,
    required this.startTime,
    this.endTime,
    this.behaviorDefinitionId,
    this.observerId,
  });

  @override
  List<Object?> get props => [id, patientId, startTime, endTime, behaviorDefinitionId, observerId];
}
