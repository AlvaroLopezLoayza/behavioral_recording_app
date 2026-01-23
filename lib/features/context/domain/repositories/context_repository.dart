import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/clinical_context.dart';

abstract class ContextRepository {
  Future<Either<Failure, ClinicalContext>> createContext(ClinicalContext context);
  Future<Either<Failure, List<ClinicalContext>>> getContextsForPatient(String patientId);
  Future<Either<Failure, void>> deleteContext(String id);
}
