import 'package:equatable/equatable.dart';

abstract class ReliabilityEvent extends Equatable {
  const ReliabilityEvent();

  @override
  List<Object?> get props => [];
}

class LoadReliabilityRecords extends ReliabilityEvent {
  final String patientId;

  const LoadReliabilityRecords(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class CalculateAndSaveIOA extends ReliabilityEvent {
  final String patientId;
  final String behaviorDefinitionId;
  final String observer1Id;
  final String observer2Id;
  final DateTime startTime;
  final DateTime endTime;
  final String method;
  final Map<String, dynamic>? parameters;

  const CalculateAndSaveIOA({
    required this.patientId,
    required this.behaviorDefinitionId,
    required this.observer1Id,
    required this.observer2Id,
    required this.startTime,
    required this.endTime,
    required this.method,
    this.parameters,
  });

  @override
  List<Object?> get props => [
        patientId,
        behaviorDefinitionId,
        observer1Id,
        observer2Id,
        startTime,
        endTime,
        method,
        parameters,
      ];
}
