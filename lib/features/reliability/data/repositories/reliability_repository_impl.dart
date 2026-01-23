import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reliability_record.dart';
import '../../domain/repositories/reliability_repository.dart';
import '../datasources/reliability_remote_datasource.dart';
import '../models/reliability_record_model.dart';

class ReliabilityRepositoryImpl implements ReliabilityRepository {
  final ReliabilityRemoteDataSource remoteDataSource;

  ReliabilityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReliabilityRecord>>> getReliabilityByPatient(String patientId) async {
    try {
      final results = await remoteDataSource.getReliabilityByPatient(patientId);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReliabilityRecord>> saveReliabilityRecord(ReliabilityRecord record) async {
    try {
      final model = ReliabilityRecordModel.fromEntity(record);
      final result = await remoteDataSource.saveReliabilityRecord(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> calculateIOA({
    required String behaviorDefinitionId,
    required String observer1Id,
    required String observer2Id,
    required DateTime startTime,
    required DateTime endTime,
    required String method,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final records1 = await remoteDataSource.getABCRecordsForIOA(
        behaviorDefinitionId: behaviorDefinitionId,
        observerId: observer1Id,
        startTime: startTime,
        endTime: endTime,
      );

      final records2 = await remoteDataSource.getABCRecordsForIOA(
        behaviorDefinitionId: behaviorDefinitionId,
        observerId: observer2Id,
        startTime: startTime,
        endTime: endTime,
      );

      if (method == 'total_count') {
        return Right(_calculateTotalCountIOA(records1.length, records2.length));
      } else if (method == 'exact_agreement') {
        final intervalSeconds = parameters?['interval_seconds'] ?? 60;
        return Right(_calculateExactAgreementIOA(records1, records2, startTime, endTime, intervalSeconds));
      }

      return const Left(ServerFailure('Unsupported IOA method'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  double _calculateTotalCountIOA(int count1, int count2) {
    if (count1 == 0 && count2 == 0) return 100.0;
    final smaller = min(count1, count2);
    final larger = max(count1, count2);
    if (larger == 0) return 100.0;
    return (smaller / larger) * 100.0;
  }

  double _calculateExactAgreementIOA(
    List<Map<String, dynamic>> records1,
    List<Map<String, dynamic>> records2,
    DateTime start,
    DateTime end,
    int intervalSeconds,
  ) {
    final duration = end.difference(start).inSeconds;
    final totalIntervals = (duration / intervalSeconds).ceil();
    if (totalIntervals <= 0) return 100.0;

    int agreements = 0;

    for (int i = 0; i < totalIntervals; i++) {
      final intervalStart = start.add(Duration(seconds: i * intervalSeconds));
      final intervalEnd = start.add(Duration(seconds: (i + 1) * intervalSeconds));

      final hasRecord1 = records1.any((r) {
        final ts = DateTime.parse(r['timestamp']);
        return ts.isAfter(intervalStart) && ts.isBefore(intervalEnd);
      });

      final hasRecord2 = records2.any((r) {
        final ts = DateTime.parse(r['timestamp']);
        return ts.isAfter(intervalStart) && ts.isBefore(intervalEnd);
      });

      if (hasRecord1 == hasRecord2) {
        agreements++;
      }
    }

    return (agreements / totalIntervals) * 100.0;
  }
}
