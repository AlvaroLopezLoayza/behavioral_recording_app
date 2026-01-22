import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import 'patient.dart';
import 'patient_access.dart';
import 'access_role.dart';

abstract class PatientRepository {
  // Patient CRUD
  Future<Either<Failure, Patient>> createPatient(Patient patient);
  Future<Either<Failure, Patient>> updatePatient(Patient patient);
  Future<Either<Failure, void>> deletePatient(String id);
  Future<Either<Failure, Patient>> getPatientById(String id);
  
  // List patients the user has access to (owned + shared)
  Future<Either<Failure, List<Patient>>> getPatients();
  
  // Access Management
  Future<Either<Failure, List<PatientAccess>>> getPatientAccesses(String patientId);
  Future<Either<Failure, PatientAccess>> sharePatient({
    required String patientId,
    required String email,
    required AccessRole role,
  });
  Future<Either<Failure, void>> updateAccessRole({
    required String accessId,
    required AccessRole newRole,
  });
  Future<Either<Failure, void>> revokeAccess(String accessId);
}
