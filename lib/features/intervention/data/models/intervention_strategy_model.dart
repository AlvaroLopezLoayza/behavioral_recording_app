import '../domain/entities/intervention_strategy.dart';

class InterventionStrategyModel extends InterventionStrategy {
  const InterventionStrategyModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
  });

  factory InterventionStrategyModel.fromJson(Map<String, dynamic> json) {
    return InterventionStrategyModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: InterventionStrategyType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InterventionStrategyType.antecedent,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
    };
  }

  static InterventionStrategyModel fromEntity(InterventionStrategy strategy) {
    return InterventionStrategyModel(
      id: strategy.id,
      name: strategy.name,
      description: strategy.description,
      type: strategy.type,
    );
  }
}
