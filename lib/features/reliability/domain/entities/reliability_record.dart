import 'package:equatable/equatable.dart';

class ReliabilityRecord extends Equatable {
  final String id;
  final String patientId;
  final String behaviorDefinitionId;
  final String observer1Id;
  final String observer2Id;
  final String method;
  final double score;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic> parameters;
  final DateTime createdAt;

  const ReliabilityRecord({
    required this.id,
    required this.patientId,
    required this.behaviorDefinitionId,
    required this.observer1Id,
    required this.observer2Id,
    required this.method,
    required this.score,
    required this.startTime,
    required this.endTime,
    required this.parameters,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        behaviorDefinitionId,
        observer1Id,
        observer2Id,
        method,
        score,
        startTime,
        endTime,
        parameters,
        createdAt,
      ];
}
