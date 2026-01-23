import 'package:equatable/equatable.dart';

import '../../../../features/abc_recording/domain/entities/recording_session.dart';
import '../../../../features/behavior_definition/domain/entities/behavior_definition.dart';
import '../../../../features/context/domain/entities/clinical_context.dart';
import '../../../../features/patient/domain/entities/patient.dart';

enum WorkflowStep {
  patientSelection, // 0
  behaviorSelection, // 1
  contextSelection, // 2
  recording, // 3
  analysis, // 4
  hypothesis, // 5
  intervention, // 6
  results // 7
}

class WorkflowState extends Equatable {
  final Patient? patient;
  final BehaviorDefinition? behavior;
  final ClinicalContext? context;
  final RecordingSession? session;
  final WorkflowStep currentStep;

  const WorkflowState({
    this.patient,
    this.behavior,
    this.context,
    this.session,
    this.currentStep = WorkflowStep.patientSelection,
  });

  WorkflowState copyWith({
    Patient? patient,
    BehaviorDefinition? behavior,
    ClinicalContext? context,
    RecordingSession? session,
    WorkflowStep? currentStep,
    bool clearBehavior = false,
    bool clearContext = false,
    bool clearSession = false,
  }) {
    return WorkflowState(
      patient: patient ?? this.patient,
      behavior: clearBehavior ? null : (behavior ?? this.behavior),
      context: clearContext ? null : (context ?? this.context),
      session: clearSession ? null : (session ?? this.session),
      currentStep: currentStep ?? this.currentStep,
    );
  }

  /// Computed properties to help UI gates
  bool get hasPatient => patient != null;
  bool get hasBehavior => behavior != null;
  bool get hasContext => context != null;
  bool get hasSession => session != null;

  bool get canRecord => hasPatient && hasBehavior && hasContext;
  bool get canAnalyze => hasSession || (hasPatient && hasBehavior); // Can view historical analysis

  @override
  List<Object?> get props => [patient, behavior, context, session, currentStep];
}
