import 'package:equatable/equatable.dart';

import '../../domain/entities/access_role.dart';

abstract class PatientAccessEvent extends Equatable {
  const PatientAccessEvent();
  @override
  List<Object?> get props => [];
}

class LoadPatientAccess extends PatientAccessEvent {
  final String patientId;
  const LoadPatientAccess(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class SharePatientEvent extends PatientAccessEvent {
  final String patientId;
  final String email;
  final AccessRole role;

  const SharePatientEvent({
    required this.patientId,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [patientId, email, role];
}

class RevokeAccessEvent extends PatientAccessEvent {
  final String accessId;
  final String patientId; // Needed to reload list

  const RevokeAccessEvent({
    required this.accessId,
    required this.patientId,
  });

  @override
  List<Object?> get props => [accessId, patientId];
}
