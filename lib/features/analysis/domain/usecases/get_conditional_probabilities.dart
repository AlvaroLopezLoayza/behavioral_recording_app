import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../abc_recording/domain/repositories/abc_recording_repository.dart';
import '../entities/conditional_probability.dart';

class GetConditionalProbabilities implements UseCase<ConditionalProbabilityResult, Params> {
  final AbcRecordingRepository repository;

  GetConditionalProbabilities(this.repository);

  @override
  Future<Either<Failure, ConditionalProbabilityResult>> call(Params params) async {
    final result = await repository.getRecordsByBehavior(params.behaviorId);

    return result.map((records) {
      final total = records.length;
      if (total == 0) {
        return ConditionalProbabilityResult(
          behaviorId: params.behaviorId,
          totalOccurrences: 0,
          antecedentProbabilities: const [],
          consequenceProbabilities: const [],
        );
      }

      // Calculate Antecedent Counts
      final antecedentCounts = <String, int>{};
      for (var record in records) {
        final String ant = record.antecedent['description']?.toString().trim() ?? 'Sin Dato';
        if (ant.isEmpty) {
          antecedentCounts['Sin Información'] = (antecedentCounts['Sin Información'] ?? 0) + 1;
        } else {
          antecedentCounts[ant] = (antecedentCounts[ant] ?? 0) + 1;
        }
      }

      // Calculate Consequence Counts
      final consequenceCounts = <String, int>{};
      for (var record in records) {
        final String con = record.consequence['description']?.toString().trim() ?? 'Sin Dato';
        if (con.isEmpty) {
          consequenceCounts['Sin Información'] = (consequenceCounts['Sin Información'] ?? 0) + 1;
        } else {
          consequenceCounts[con] = (consequenceCounts[con] ?? 0) + 1;
        }
      }

      // Convert to Items
      final antecedentItems = antecedentCounts.entries.map((e) {
        return ConditionalProbabilityItem(
          name: e.key,
          count: e.value,
          probability: e.value / total,
        );
      }).toList();

      final consequenceItems = consequenceCounts.entries.map((e) {
        return ConditionalProbabilityItem(
          name: e.key,
          count: e.value,
          probability: e.value / total,
        );
      }).toList();

      // Sort by probability descending
      antecedentItems.sort((a, b) => b.probability.compareTo(a.probability));
      consequenceItems.sort((a, b) => b.probability.compareTo(a.probability));

      return ConditionalProbabilityResult(
        behaviorId: params.behaviorId,
        totalOccurrences: total,
        antecedentProbabilities: antecedentItems,
        consequenceProbabilities: consequenceItems,
      );
    });
  }
}

class Params {
  final String behaviorId;

  const Params({required this.behaviorId});
}
