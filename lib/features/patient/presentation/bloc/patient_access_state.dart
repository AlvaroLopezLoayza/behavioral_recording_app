import 'package:equatable/equatable.dart';

import '../../domain/entities/patient_access.dart';

abstract class PatientAccessState extends Equatable {
  const PatientAccessState();
  @override
  List<Object?> get props => [];
}

class PatientAccessInitial extends PatientAccessState {}

class PatientAccessLoading extends PatientAccessState {}

class PatientAccessLoaded extends PatientAccessState {
  final List<PatientAccess> accessList;
  const PatientAccessLoaded(this.accessList);
  @override
  List<Object?> get props => [accessList];
}

class PatientAccessOperationSuccess extends PatientAccessState {
  final String message;
  const PatientAccessOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PatientAccessError extends PatientAccessState {
  final String message;
  const PatientAccessError(this.message);
  @override
  List<Object?> get props => [message];
}
