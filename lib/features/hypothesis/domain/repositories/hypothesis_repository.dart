import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/functional_hypothesis.dart';

abstract class HypothesisRepository {
  Future<Either<Failure, FunctionalHypothesis>> createHypothesis(FunctionalHypothesis hypothesis);
  Future<Either<Failure, List<FunctionalHypothesis>>> getHypothesesByBehavior(String behaviorId);
  Future<Either<Failure, FunctionalHypothesis>> updateHypothesis(FunctionalHypothesis hypothesis);
  Future<Either<Failure, void>> deleteHypothesis(String id);
}
