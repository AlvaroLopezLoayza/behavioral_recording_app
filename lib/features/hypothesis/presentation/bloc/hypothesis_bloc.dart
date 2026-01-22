import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/hypothesis_repository.dart';
import 'hypothesis_event.dart';
import 'hypothesis_state.dart';

class HypothesisBloc extends Bloc<HypothesisEvent, HypothesisState> {
  final HypothesisRepository repository;

  HypothesisBloc({required this.repository}) : super(HypothesisInitial()) {
    on<LoadHypotheses>(_onLoadHypotheses);
    on<CreateHypothesis>(_onCreateHypothesis);
    on<UpdateHypothesis>(_onUpdateHypothesis);
    on<DeleteHypothesis>(_onDeleteHypothesis);
  }

  Future<void> _onLoadHypotheses(
    LoadHypotheses event,
    Emitter<HypothesisState> emit,
  ) async {
    emit(HypothesisLoading());
    final result = await repository.getHypothesesByBehavior(event.behaviorId);
    result.fold(
      (failure) => emit(HypothesisError(failure.message)),
      (hypotheses) => emit(HypothesisLoaded(hypotheses)),
    );
  }

  Future<void> _onCreateHypothesis(
    CreateHypothesis event,
    Emitter<HypothesisState> emit,
  ) async {
    final result = await repository.createHypothesis(event.hypothesis);
    result.fold(
      (failure) => emit(HypothesisError(failure.message)),
      (_) {
        emit(const HypothesisOperationSuccess('Hipótesis creada exitosamente'));
        add(LoadHypotheses(event.hypothesis.behaviorDefinitionId));
      },
    );
  }

  Future<void> _onUpdateHypothesis(
    UpdateHypothesis event,
    Emitter<HypothesisState> emit,
  ) async {
    final result = await repository.updateHypothesis(event.hypothesis);
    result.fold(
      (failure) => emit(HypothesisError(failure.message)),
      (_) {
        emit(const HypothesisOperationSuccess('Hipótesis actualizada exitosamente'));
        add(LoadHypotheses(event.hypothesis.behaviorDefinitionId));
      },
    );
  }

  Future<void> _onDeleteHypothesis(
    DeleteHypothesis event,
    Emitter<HypothesisState> emit,
  ) async {
    final result = await repository.deleteHypothesis(event.id);
    result.fold(
      (failure) => emit(HypothesisError(failure.message)),
      (_) {
        emit(const HypothesisOperationSuccess('Hipótesis eliminada exitosamente'));
        add(LoadHypotheses(event.behaviorId));
      },
    );
  }
}
