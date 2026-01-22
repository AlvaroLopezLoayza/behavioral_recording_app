import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/context.dart';

abstract class ContextRepository {
  Future<Either<Failure, Context>> createContext(Context context);
  Future<Either<Failure, List<Context>>> getContextsForPatient(String patientId);
  Future<Either<Failure, void>> deleteContext(String id);
}
