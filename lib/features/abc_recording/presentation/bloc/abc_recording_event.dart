import 'package:equatable/equatable.dart';

import '../../domain/entities/abc_record.dart';
import '../../domain/entities/recording_session.dart';

abstract class AbcRecordingEvent extends Equatable {
  const AbcRecordingEvent();

  @override
  List<Object?> get props => [];
}

/// Load records for a specific behavior definition
class LoadAbcRecords extends AbcRecordingEvent {
  final String behaviorDefinitionId;
  const LoadAbcRecords(this.behaviorDefinitionId);
  @override
  List<Object?> get props => [behaviorDefinitionId];
}

/// Save a new ABC record
class SaveAbcRecord extends AbcRecordingEvent {
  final AbcRecord record;
  const SaveAbcRecord(this.record);
  @override
  List<Object?> get props => [record];
}

/// Save a recording session
class SaveRecordingSession extends AbcRecordingEvent {
  final RecordingSession session;
  const SaveRecordingSession(this.session);
  @override
  List<Object?> get props => [session];
}

/// Delete a record
class DeleteAbcRecord extends AbcRecordingEvent {
  final String id;
  const DeleteAbcRecord(this.id);
  @override
  List<Object?> get props => [id];
}
