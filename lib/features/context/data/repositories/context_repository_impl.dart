import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/context.dart';
import '../../domain/repositories/context_repository.dart';
import '../models/context_model.dart';
import '../datasources/context_remote_datasource.dart';

class ContextRepositoryImpl implements ContextRepository {
  final ContextRemoteDataSource remoteDataSource;

  ContextRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Context>> createContext(Context context) async {
    try {
      final model = ContextModel.fromEntity(context);
      final createdContext = await remoteDataSource.createContext(model);
      return Right(createdContext);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Context>>> getContextsForPatient(String patientId) async {
    try {
      final contexts = await remoteDataSource.getContextsForPatient(patientId);
      return Right(contexts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContext(String id) async {
    try {
      await remoteDataSource.deleteContext(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
