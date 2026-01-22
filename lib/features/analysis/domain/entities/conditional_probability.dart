import 'package:equatable/equatable.dart';

class ConditionalProbabilityItem extends Equatable {
  final String name;
  final int count;
  final double probability;

  const ConditionalProbabilityItem({
    required this.name,
    required this.count,
    required this.probability,
  });

  @override
  List<Object?> get props => [name, count, probability];
}

class ConditionalProbabilityResult extends Equatable {
  final String behaviorId;
  final int totalOccurrences;
  final List<ConditionalProbabilityItem> antecedentProbabilities;
  final List<ConditionalProbabilityItem> consequenceProbabilities;

  const ConditionalProbabilityResult({
    required this.behaviorId,
    required this.totalOccurrences,
    required this.antecedentProbabilities,
    required this.consequenceProbabilities,
  });

  @override
  List<Object?> get props => [
        behaviorId,
        totalOccurrences,
        antecedentProbabilities,
        consequenceProbabilities,
      ];
}
