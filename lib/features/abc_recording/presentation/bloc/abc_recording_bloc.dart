import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_abc_record.dart';
import '../../domain/usecases/get_records_by_behavior.dart';
import 'abc_recording_event.dart';
import 'abc_recording_state.dart';

class AbcRecordingBloc extends Bloc<AbcRecordingEvent, AbcRecordingState> {
  final CreateAbcRecord createAbcRecord;
  final GetRecordsByBehavior getRecordsByBehavior;

  AbcRecordingBloc({
    required this.createAbcRecord,
    required this.getRecordsByBehavior,
  }) : super(AbcRecordingInitial()) {
    on<LoadAbcRecords>(_onLoadAbcRecords);
    on<SaveAbcRecord>(_onSaveAbcRecord);
  }

  Future<void> _onLoadAbcRecords(
    LoadAbcRecords event,
    Emitter<AbcRecordingState> emit,
  ) async {
    emit(AbcRecordingLoading());
    final result = await getRecordsByBehavior(
      GetRecordsByBehaviorParams(event.behaviorDefinitionId),
    );
    result.fold(
      (failure) => emit(AbcRecordingError(failure.message)),
      (records) => emit(AbcRecordingLoaded(records)),
    );
  }

  Future<void> _onSaveAbcRecord(
    SaveAbcRecord event,
    Emitter<AbcRecordingState> emit,
  ) async {
    // Keep current state to reload after save or use better state management
    // For simplicity, just emit loading then saved
    emit(AbcRecordingLoading());
    final result = await createAbcRecord(event.record);
    result.fold(
      (failure) => emit(AbcRecordingError(failure.message)),
      (_) {
        emit(AbcRecordSaved());
        // Reload list for the affected behavior definition
        add(LoadAbcRecords(event.record.behaviorDefinitionId));
      },
    );
  }
}
