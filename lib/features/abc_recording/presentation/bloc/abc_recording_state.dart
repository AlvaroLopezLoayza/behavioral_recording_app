import 'package:equatable/equatable.dart';

import '../../domain/entities/abc_record.dart';

abstract class AbcRecordingState extends Equatable {
  const AbcRecordingState();
  
  @override
  List<Object?> get props => [];
}

class AbcRecordingInitial extends AbcRecordingState {}

class AbcRecordingLoading extends AbcRecordingState {}

class AbcRecordingLoaded extends AbcRecordingState {
  final List<AbcRecord> records;
  const AbcRecordingLoaded(this.records);
  @override
  List<Object?> get props => [records];
}

class AbcRecordingError extends AbcRecordingState {
  final String message;
  const AbcRecordingError(this.message);
  @override
  List<Object?> get props => [message];
}

class AbcRecordSaved extends AbcRecordingState {}

class RecordingSessionSaved extends AbcRecordingState {}
