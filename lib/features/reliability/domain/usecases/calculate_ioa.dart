import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/reliability_repository.dart';

class CalculateIOA implements UseCase<double, CalculateIOAParams> {
  final ReliabilityRepository repository;

  CalculateIOA(this.repository);

  @override
  Future<Either<Failure, double>> call(CalculateIOAParams params) async {
    return await repository.calculateIOA(
      behaviorDefinitionId: params.behaviorDefinitionId,
      observer1Id: params.observer1Id,
      observer2Id: params.observer2Id,
      startTime: params.startTime,
      endTime: params.endTime,
      method: params.method,
      parameters: params.parameters,
    );
  }
}

class CalculateIOAParams {
  final String behaviorDefinitionId;
  final String observer1Id;
  final String observer2Id;
  final DateTime startTime;
  final DateTime endTime;
  final String method;
  final Map<String, dynamic>? parameters;

  CalculateIOAParams({
    required this.behaviorDefinitionId,
    required this.observer1Id,
    required this.observer2Id,
    required this.startTime,
    required this.endTime,
    required this.method,
    this.parameters,
  });
}
