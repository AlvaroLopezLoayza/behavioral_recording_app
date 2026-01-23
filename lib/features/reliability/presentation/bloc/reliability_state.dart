import 'package:equatable/equatable.dart';

import '../../domain/entities/reliability_record.dart';

abstract class ReliabilityState extends Equatable {
  const ReliabilityState();

  @override
  List<Object?> get props => [];
}

class ReliabilityInitial extends ReliabilityState {}

class ReliabilityLoading extends ReliabilityState {}

class ReliabilityLoaded extends ReliabilityState {
  final List<ReliabilityRecord> records;
  final double? lastCalculatedScore;

  const ReliabilityLoaded({required this.records, this.lastCalculatedScore});

  @override
  List<Object?> get props => [records, lastCalculatedScore];
}

class ReliabilityError extends ReliabilityState {
  final String message;

  const ReliabilityError(this.message);

  @override
  List<Object?> get props => [message];
}
