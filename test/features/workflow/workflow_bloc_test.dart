import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:behavioral_recording_app/features/workflow/presentation/bloc/workflow_bloc.dart';
import 'package:behavioral_recording_app/features/workflow/presentation/bloc/workflow_event.dart';
import 'package:behavioral_recording_app/features/workflow/presentation/bloc/workflow_state.dart';
import 'package:behavioral_recording_app/features/patient/domain/entities/patient.dart';
import 'package:behavioral_recording_app/features/behavior_definition/domain/entities/behavior_definition.dart';
import 'package:behavioral_recording_app/features/context/domain/entities/clinical_context.dart';
import 'package:behavioral_recording_app/features/abc_recording/domain/entities/recording_session.dart';

// Mocks
class MockPatient extends Patient {
  MockPatient() : super(
    id: '1', 
    firstName: 'John', 
    lastName: 'Doe', 
    birthDate: null, 
    diagnosis: null, 
    ownerId: 'owner1', 
    createdAt: DateTime.now(), 
    updatedAt: DateTime.now()
  );
}

class MockBehavior extends BehaviorDefinition {
  MockBehavior() : super(
    id: '1', 
    name: 'Hit', 
    operationalDefinition: 'Hitting', 
    patientId: '1', 
    isObservable: true, 
    isMeasurable: true, 
    dimensions: const [], 
    createdBy: 'user1', 
    createdAt: DateTime.now(), 
    updatedAt: DateTime.now()
  );
}

class MockContext extends ClinicalContext {
  MockContext() : super(id: '1', name: 'School', type: 'physical', description: '', patientId: '1', createdBy: '', createdAt: DateTime.now()); 
}

class MockSession extends RecordingSession {
  MockSession() : super(id: '1', patientId: '1', startTime: DateTime.now(), endTime: DateTime.now());
}

void main() {
  group('WorkflowBloc', () {
    late WorkflowBloc workflowBloc;
    final patient = MockPatient();
    final behavior = MockBehavior();
    final contextDef = MockContext();
    final session = MockSession();

    setUp(() {
      workflowBloc = WorkflowBloc();
    });

    tearDown(() {
      workflowBloc.close();
    });

    test('initial state is correct', () {
      expect(workflowBloc.state, const WorkflowState());
      expect(workflowBloc.state.currentStep, WorkflowStep.patientSelection);
    });

    blocTest<WorkflowBloc, WorkflowState>(
      'moves to behaviorSelection when patient is selected',
      build: () => workflowBloc,
      act: (bloc) => bloc.add(WorkflowPatientSelected(patient)),
      expect: () => [
        isA<WorkflowState>()
            .having((s) => s.patient, 'patient', patient)
            .having((s) => s.currentStep, 'step', WorkflowStep.behaviorSelection)
      ],
    );

    blocTest<WorkflowBloc, WorkflowState>(
      'moves to contextSelection when behavior is selected',
      build: () => workflowBloc,
      seed: () => WorkflowState(patient: patient, currentStep: WorkflowStep.behaviorSelection),
      act: (bloc) => bloc.add(WorkflowBehaviorSelected(behavior)),
      expect: () => [
        isA<WorkflowState>()
            .having((s) => s.behavior, 'behavior', behavior)
            .having((s) => s.currentStep, 'step', WorkflowStep.contextSelection)
      ],
    );

    blocTest<WorkflowBloc, WorkflowState>(
      'moves to recording when context is selected',
      build: () => workflowBloc,
      seed: () => WorkflowState(
          patient: patient, 
          behavior: behavior, 
          currentStep: WorkflowStep.contextSelection
      ),
      act: (bloc) => bloc.add(WorkflowContextSelected(contextDef)),
      expect: () => [
        isA<WorkflowState>()
            .having((s) => s.context, 'context', contextDef)
            .having((s) => s.currentStep, 'step', WorkflowStep.recording)
      ],
    );

    blocTest<WorkflowBloc, WorkflowState>(
      'clears downstream state when backtracking (select patient again)',
      build: () => workflowBloc,
      seed: () => WorkflowState(
          patient: patient, behavior: behavior, context: contextDef, currentStep: WorkflowStep.recording),
      act: (bloc) => bloc.add(WorkflowPatientSelected(patient)),
      expect: () => [
        isA<WorkflowState>()
            .having((s) => s.behavior, 'cleared behavior', null)
            .having((s) => s.context, 'cleared context', null)
            .having((s) => s.currentStep, 'reset step', WorkflowStep.behaviorSelection)
      ],
    );
  });
}
