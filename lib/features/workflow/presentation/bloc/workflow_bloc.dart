import 'package:flutter_bloc/flutter_bloc.dart';
import 'workflow_event.dart';
import 'workflow_state.dart';

class WorkflowBloc extends Bloc<WorkflowEvent, WorkflowState> {
  WorkflowBloc() : super(const WorkflowState()) {
    on<WorkflowPatientSelected>(_onPatientSelected);
    on<WorkflowBehaviorSelected>(_onBehaviorSelected);
    on<WorkflowContextSelected>(_onContextSelected);
    on<WorkflowSessionCompleted>(_onSessionCompleted);
    on<WorkflowReset>(_onReset);
  }

  void _onPatientSelected(WorkflowPatientSelected event, Emitter<WorkflowState> emit) {
    // When a patient is selected, we move to step 1 (Behavior Selection)
    // We clear any previous downstream state
    emit(state.copyWith(
      patient: event.patient,
      currentStep: WorkflowStep.behaviorSelection,
      clearBehavior: true,
      clearContext: true,
      clearSession: true,
    ));
  }

  void _onBehaviorSelected(WorkflowBehaviorSelected event, Emitter<WorkflowState> emit) {
    // When a behavior is selected, we move to step 2 (Context Selection)
    emit(state.copyWith(
      behavior: event.behavior,
      currentStep: WorkflowStep.contextSelection,
      clearContext: true,
      clearSession: true,
    ));
  }

  void _onContextSelected(WorkflowContextSelected event, Emitter<WorkflowState> emit) {
    // When a context is selected, we move to step 3 (Recording)
    emit(state.copyWith(
      context: event.context,
      currentStep: WorkflowStep.recording,
      clearSession: true,
    ));
  }

  void _onSessionCompleted(WorkflowSessionCompleted event, Emitter<WorkflowState> emit) {
    // When recording is done, we move to step 4 (Analysis)
    emit(state.copyWith(
      session: event.session,
      currentStep: WorkflowStep.analysis,
    ));
  }

  void _onReset(WorkflowReset event, Emitter<WorkflowState> emit) {
    // Reset everything back to initial state
    emit(const WorkflowState());
  }
}
