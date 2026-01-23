import 'package:equatable/equatable.dart';

class PhaseChange extends Equatable {
  final DateTime date;
  final String newStatus;
  final String? planId;

  const PhaseChange({
    required this.date,
    required this.newStatus,
    this.planId,
  });

  @override
  List<Object?> get props => [date, newStatus, planId];
}
