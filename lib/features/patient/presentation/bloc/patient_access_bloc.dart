import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/patient_repository.dart';
import 'patient_access_event.dart';
import 'patient_access_state.dart';

class PatientAccessBloc extends Bloc<PatientAccessEvent, PatientAccessState> {
  final PatientRepository repository;

  PatientAccessBloc({required this.repository}) : super(PatientAccessInitial()) {
    on<LoadPatientAccess>(_onLoadPatientAccess);
    on<SharePatientEvent>(_onSharePatient);
    on<RevokeAccessEvent>(_onRevokeAccess);
  }

  Future<void> _onLoadPatientAccess(
    LoadPatientAccess event,
    Emitter<PatientAccessState> emit,
  ) async {
    emit(PatientAccessLoading());
    final result = await repository.getPatientAccesses(event.patientId);
    result.fold(
      (failure) => emit(PatientAccessError(failure.message)),
      (accessList) => emit(PatientAccessLoaded(accessList)),
    );
  }

  Future<void> _onSharePatient(
    SharePatientEvent event,
    Emitter<PatientAccessState> emit,
  ) async {
    emit(PatientAccessLoading());
    final result = await repository.sharePatient(
      patientId: event.patientId,
      email: event.email,
      role: event.role,
    );
    
    result.fold(
      (failure) => emit(PatientAccessError(failure.message)),
      (_) {
        emit(const PatientAccessOperationSuccess('Invitación enviada correctamente'));
        add(LoadPatientAccess(event.patientId));
      },
    );
  }

  Future<void> _onRevokeAccess(
    RevokeAccessEvent event,
    Emitter<PatientAccessState> emit,
  ) async {
    emit(PatientAccessLoading());
    final result = await repository.revokeAccess(event.accessId);
    
    result.fold(
      (failure) => emit(PatientAccessError(failure.message)),
      (_) {
        emit(const PatientAccessOperationSuccess('Acceso revocado'));
        add(LoadPatientAccess(event.patientId));
      },
    );
  }
}
