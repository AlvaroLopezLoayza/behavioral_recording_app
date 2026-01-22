import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/intervention_repository.dart';
import 'intervention_event.dart';
import 'intervention_state.dart';

class InterventionBloc extends Bloc<InterventionEvent, InterventionState> {
  final InterventionRepository repository;

  InterventionBloc({required this.repository}) : super(InterventionInitial()) {
    on<LoadInterventionPlans>(_onLoadInterventionPlans);
    on<CreateInterventionPlan>(_onCreateInterventionPlan);
    on<UpdateInterventionPlan>(_onUpdateInterventionPlan);
    on<DeleteInterventionPlan>(_onDeleteInterventionPlan);
  }

  Future<void> _onLoadInterventionPlans(
    LoadInterventionPlans event,
    Emitter<InterventionState> emit,
  ) async {
    emit(InterventionLoading());
    final result = await repository.getPlansByHypothesis(event.hypothesisId);
    result.fold(
      (failure) => emit(const InterventionError('Error al cargar planes de intervención')),
      (plans) => emit(InterventionLoaded(plans)),
    );
  }

  Future<void> _onCreateInterventionPlan(
    CreateInterventionPlan event,
    Emitter<InterventionState> emit,
  ) async {
    final result = await repository.createPlan(event.plan);
    result.fold(
      (failure) => emit(const InterventionError('Error al crear plan de intervención')),
      (_) {
        emit(InterventionOperationSuccess());
        add(LoadInterventionPlans(event.plan.hypothesisId));
      },
    );
  }

  Future<void> _onUpdateInterventionPlan(
    UpdateInterventionPlan event,
    Emitter<InterventionState> emit,
  ) async {
    final result = await repository.updatePlan(event.plan);
    result.fold(
      (failure) => emit(const InterventionError('Error al actualizar plan de intervención')),
      (_) {
        emit(InterventionOperationSuccess());
        add(LoadInterventionPlans(event.plan.hypothesisId));
      },
    );
  }

  Future<void> _onDeleteInterventionPlan(
    DeleteInterventionPlan event,
    Emitter<InterventionState> emit,
  ) async {
    final result = await repository.deletePlan(event.planId);
    result.fold(
      (failure) => emit(const InterventionError('Error al eliminar plan de intervención')),
      (_) => emit(InterventionOperationSuccess()),
    );
  }
}
