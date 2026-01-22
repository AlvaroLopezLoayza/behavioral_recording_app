import 'package:equatable/equatable.dart';
import 'access_role.dart';

class PatientAccess extends Equatable {
  final String id;
  final String patientId;
  final String userId;
  final String? userEmail; // For display purposes
  final AccessRole role;
  final String grantedBy;
  final DateTime createdAt;

  const PatientAccess({
    required this.id,
    required this.patientId,
    required this.userId,
    this.userEmail,
    required this.role,
    required this.grantedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        userId,
        userEmail,
        role,
        grantedBy,
        createdAt,
      ];
}
