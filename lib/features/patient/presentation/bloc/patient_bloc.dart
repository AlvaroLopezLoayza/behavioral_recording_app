import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Access global client if needed, or better via DI
import 'package:uuid/uuid.dart';

import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import 'patient_event.dart';
import 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository repository;
  final SupabaseClient supabaseClient; // To get current user ID

  PatientBloc({required this.repository, required this.supabaseClient}) : super(PatientInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<CreatePatientEvent>(_onCreatePatient);
    on<UpdatePatientEvent>(_onUpdatePatient);
  }

  Future<void> _onLoadPatients(LoadPatients event, Emitter<PatientState> emit) async {
    emit(PatientLoading());
    final result = await repository.getPatients();
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patients) => emit(PatientLoaded(patients)),
    );
  }

  Future<void> _onCreatePatient(CreatePatientEvent event, Emitter<PatientState> emit) async {
    emit(PatientLoading());
    
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      emit(const PatientError("User not authenticated"));
      return;
    }

    final newPatient = Patient(
      id: const Uuid().v4(), // We might let DB generate this, but model expects it. Best practice: Let DB generate or use UUID v4.
      firstName: event.firstName,
      lastName: event.lastName,
      birthDate: event.birthDate,
      diagnosis: event.diagnosis,
      ownerId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await repository.createPatient(newPatient);
    
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) {
        emit(const PatientOperationSuccess("Paciente creado exitosamente"));
        // Note: PatientListPage will reload when it receives the navigation result (true)
        // No need to trigger LoadPatients here as this bloc is isolated to the form page
      },
    );
  }

  Future<void> _onUpdatePatient(UpdatePatientEvent event, Emitter<PatientState> emit) async {
    emit(PatientLoading());
    
    // In a real app we might want to fetch current patient to ensure we don't overwrite other fields,
    // but here we just construct with what we have + existing ID.
    // However, Patient model is immutable. We need to construct a "patch" or full object.
    // Ideally the repository gets the current one or we pass the full object from UI.
    // For now, let's assume we need to re-fetch or trust the UI sent everything.
    // A better approach is usually `repository.getPatientById` then copyWith.
    
    // Optimization: Since we are in the form, we likely have the 'existing' patient data from the previous screen.
    // But to be safe and simple:
    
    try {
      final currentResult = await repository.getPatientById(event.id);
      
      await currentResult.fold(
        (failure) async => emit(PatientError(failure.message)),
        (currentPatient) async {
          final updatedPatient = currentPatient.copyWith(
            firstName: event.firstName,
            lastName: event.lastName,
            birthDate: event.birthDate,
            diagnosis: event.diagnosis,
            updatedAt: DateTime.now(),
          );

          final result = await repository.updatePatient(updatedPatient);
          result.fold(
            (failure) => emit(PatientError(failure.message)),
            (patient) => emit(const PatientOperationSuccess("Paciente actualizado exitosamente")),
          );
        },
      );
    } catch (e) {
      emit(PatientError(e.toString()));
    }
  }
}
