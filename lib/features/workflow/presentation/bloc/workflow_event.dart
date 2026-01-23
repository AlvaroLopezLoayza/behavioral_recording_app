import 'package:equatable/equatable.dart';
import '../../../../features/behavior_definition/domain/entities/behavior_definition.dart';
import '../../../../features/context/domain/entities/clinical_context.dart';
import '../../../../features/patient/domain/entities/patient.dart';
import '../../../../features/abc_recording/domain/entities/recording_session.dart';

abstract class WorkflowEvent extends Equatable {
  const WorkflowEvent();

  @override
  List<Object?> get props => [];
}

/// Start a new workflow flow for a specific patient
class WorkflowPatientSelected extends WorkflowEvent {
  final Patient patient;

  const WorkflowPatientSelected(this.patient);

  @override
  List<Object?> get props => [patient];
}

/// Select a behavior to focus on (Step 2)
class WorkflowBehaviorSelected extends WorkflowEvent {
  final BehaviorDefinition behavior;

  const WorkflowBehaviorSelected(this.behavior);

  @override
  List<Object?> get props => [behavior];
}

/// Select a context (Step 3)
class WorkflowContextSelected extends WorkflowEvent {
  final ClinicalContext context;

  const WorkflowContextSelected(this.context);

  @override
  List<Object?> get props => [context];
}

/// Session recording completed (Step 4 -> 5)
class WorkflowSessionCompleted extends WorkflowEvent {
  final RecordingSession session;

  const WorkflowSessionCompleted(this.session);

  @override
  List<Object?> get props => [session];
}

/// Reset the workflow to start over or switch patients
class WorkflowReset extends WorkflowEvent {}
