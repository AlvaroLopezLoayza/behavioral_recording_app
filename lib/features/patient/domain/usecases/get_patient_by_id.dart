import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetPatientById implements UseCase<Patient, String> {
  final PatientRepository repository;

  GetPatientById(this.repository);

  @override
  Future<Either<Failure, Patient>> call(String patientId) async {
    return await repository.getPatientById(patientId);
  }
}
