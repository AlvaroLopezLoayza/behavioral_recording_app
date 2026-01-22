import 'package:equatable/equatable.dart';
import '../../domain/entities/patient.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();
  @override
  List<Object?> get props => [];
}

class LoadPatients extends PatientEvent {}

class CreatePatientEvent extends PatientEvent {
  final String firstName;
  final String lastName;
  final String? diagnosis;
  final DateTime? birthDate;

  const CreatePatientEvent({
    required this.firstName,
    required this.lastName,
    this.diagnosis,
    this.birthDate,
  });

  @override
  List<Object?> get props => [firstName, lastName, diagnosis, birthDate];
}
