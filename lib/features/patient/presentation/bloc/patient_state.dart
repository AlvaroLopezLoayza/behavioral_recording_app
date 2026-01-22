import 'package:equatable/equatable.dart';
import '../../domain/entities/patient.dart';

abstract class PatientState extends Equatable {
  const PatientState();
  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientLoaded extends PatientState {
  final List<Patient> patients;

  const PatientLoaded(this.patients);

  @override
  List<Object?> get props => [patients];
}

class PatientOperationSuccess extends PatientState {
  final String message;
  const PatientOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PatientError extends PatientState {
  final String message;
  const PatientError(this.message);
  @override
  List<Object?> get props => [message];
}
