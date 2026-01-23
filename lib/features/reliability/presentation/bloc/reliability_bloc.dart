import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/reliability_record.dart';
import '../../domain/usecases/calculate_ioa.dart';
import '../../domain/usecases/get_reliability_records.dart';
import '../../domain/usecases/save_reliability_record.dart';
import 'reliability_event.dart';
import 'reliability_state.dart';

class ReliabilityBloc extends Bloc<ReliabilityEvent, ReliabilityState> {
  final GetReliabilityRecords getReliabilityRecords;
  final CalculateIOA calculateIOA;
  final SaveReliabilityRecord saveReliabilityRecord;

  ReliabilityBloc({
    required this.getReliabilityRecords,
    required this.calculateIOA,
    required this.saveReliabilityRecord,
  }) : super(ReliabilityInitial()) {
    on<LoadReliabilityRecords>(_onLoadReliabilityRecords);
    on<CalculateAndSaveIOA>(_onCalculateAndSaveIOA);
  }

  Future<void> _onLoadReliabilityRecords(
    LoadReliabilityRecords event,
    Emitter<ReliabilityState> emit,
  ) async {
    emit(ReliabilityLoading());
    final result = await getReliabilityRecords(event.patientId);
    result.fold(
      (failure) => emit(ReliabilityError(failure.message)),
      (records) => emit(ReliabilityLoaded(records: records)),
    );
  }

  Future<void> _onCalculateAndSaveIOA(
    CalculateAndSaveIOA event,
    Emitter<ReliabilityState> emit,
  ) async {
    final currentState = state;
    List<ReliabilityRecord> existingRecords = [];
    if (currentState is ReliabilityLoaded) {
      existingRecords = currentState.records;
    }

    emit(ReliabilityLoading());

    final scoreResult = await calculateIOA(CalculateIOAParams(
      behaviorDefinitionId: event.behaviorDefinitionId,
      observer1Id: event.observer1Id,
      observer2Id: event.observer2Id,
      startTime: event.startTime,
      endTime: event.endTime,
      method: event.method,
      parameters: event.parameters,
    ));

    await scoreResult.fold(
      (failure) async => emit(ReliabilityError(failure.message)),
      (score) async {
        final record = ReliabilityRecord(
          id: const Uuid().v4(),
          patientId: event.patientId,
          behaviorDefinitionId: event.behaviorDefinitionId,
          observer1Id: event.observer1Id,
          observer2Id: event.observer2Id,
          method: event.method,
          score: score,
          startTime: event.startTime,
          endTime: event.endTime,
          parameters: event.parameters ?? {},
          createdAt: DateTime.now(),
        );

        final saveResult = await saveReliabilityRecord(record);
        saveResult.fold(
          (failure) => emit(ReliabilityError(failure.message)),
          (savedRecord) {
            emit(ReliabilityLoaded(
              records: [savedRecord, ...existingRecords],
              lastCalculatedScore: score,
            ));
          },
        );
      },
    );
  }
}
