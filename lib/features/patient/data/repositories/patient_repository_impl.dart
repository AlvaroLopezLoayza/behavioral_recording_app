import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/access_role.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/patient_access.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';
import '../models/patient_model.dart'; // Import needed for type conversion if necessary

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Patient>> createPatient(Patient patient) async {
    try {
      final model = PatientModel.fromEntity(patient);
      final result = await remoteDataSource.createPatient(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Patient>>> getPatients() async {
    try {
      final result = await remoteDataSource.getPatients();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, Patient>> getPatientById(String id) async {
    try {
      final result = await remoteDataSource.getPatientById(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PatientAccess>>> getPatientAccesses(String patientId) async {
    try {
      final result = await remoteDataSource.getPatientAccesses(patientId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PatientAccess>> sharePatient({required String patientId, required String email, required AccessRole role}) async {
    try {
      final result = await remoteDataSource.sharePatient(patientId, email, role);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePatient(String id) async {
    // Implement delete logic in datasource
    return Left(ServerFailure("Not implemented"));
  }

  @override
  Future<Either<Failure, Patient>> updatePatient(Patient patient) async {
    try {
      final model = PatientModel.fromEntity(patient);
      final result = await remoteDataSource.updatePatient(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateAccessRole({required String accessId, required AccessRole newRole}) {
    // TODO: implement updateAccessRole
    throw UnimplementedError();
  }
  
  @override
  Future<Either<Failure, void>> revokeAccess(String accessId) async {
    try {
      await remoteDataSource.revokeAccess(accessId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
