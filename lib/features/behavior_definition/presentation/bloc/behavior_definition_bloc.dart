import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/create_behavior_definition.dart';
import '../../domain/usecases/get_behavior_definitions.dart';
import 'behavior_definition_event.dart';
import 'behavior_definition_state.dart';

class BehaviorDefinitionBloc extends Bloc<BehaviorDefinitionEvent, BehaviorDefinitionState> {
  final GetBehaviorDefinitions getBehaviorDefinitions;
  final CreateBehaviorDefinition createBehaviorDefinition;

  BehaviorDefinitionBloc({
    required this.getBehaviorDefinitions,
    required this.createBehaviorDefinition,
  }) : super(BehaviorDefinitionInitial()) {
    on<LoadBehaviorDefinitions>(_onLoadBehaviorDefinitions);
    on<CreateBehaviorDefinitionEvent>(_onCreateBehaviorDefinition);
    // on<ValidateDefinitionEvent>(_onValidateDefinition); // To be implemented with repository
  }

  Future<void> _onLoadBehaviorDefinitions(
    LoadBehaviorDefinitions event,
    Emitter<BehaviorDefinitionState> emit,
  ) async {
    emit(BehaviorDefinitionLoading());
    final result = await getBehaviorDefinitions(GetBehaviorDefinitionsParams(patientId: event.patientId));
    result.fold(
      (failure) => emit(BehaviorDefinitionError(failure.message)),
      (definitions) => emit(BehaviorDefinitionLoaded(definitions)),
    );
  }

  Future<void> _onCreateBehaviorDefinition(
    CreateBehaviorDefinitionEvent event,
    Emitter<BehaviorDefinitionState> emit,
  ) async {
    emit(BehaviorDefinitionLoading());
    final result = await createBehaviorDefinition(
      CreateBehaviorDefinitionParams(
        definition: event.definition,
        // For now, passing the operational definition from the object itself for validation context
        operationalDefinition: event.definition.operationalDefinition, 
      ),
    );
    
    result.fold(
      (failure) => emit(BehaviorDefinitionError(failure.message)),
      (_) {
        emit(BehaviorDefinitionCreated());
        // Reload definitions after successful creation
        add(const LoadBehaviorDefinitions());
      },
    );
  }
}
