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
        add(LoadPatients()); // Reload list
      },
    );
  }
}
