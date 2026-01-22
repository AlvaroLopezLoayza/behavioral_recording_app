import 'package:equatable/equatable.dart';

/// Captures the dimensions of the behavior occurrence
class BehaviorOccurrence extends Equatable {
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final Duration? latency;
  final int? intensity; // Scale 1-5 usually
  final int? frequency;
  final String? topography;

  const BehaviorOccurrence({
    required this.startTime,
    this.endTime,
    this.duration,
    this.latency,
    this.intensity,
    this.frequency,
    this.topography,
  });

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        duration,
        latency,
        intensity,
        frequency,
        topography,
      ];
}
