import 'package:equatable/equatable.dart';

enum InterventionStrategyType {
  antecedent,
  replacement,
  consequence,
}

class InterventionStrategy extends Equatable {
  final String id;
  final String name;
  final String description;
  final InterventionStrategyType type;

  const InterventionStrategy({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, description, type];
}
