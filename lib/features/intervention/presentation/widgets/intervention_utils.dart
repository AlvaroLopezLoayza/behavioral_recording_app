import 'package:flutter/material.dart';

import '../../domain/entities/intervention_plan.dart';
import '../../domain/entities/intervention_strategy.dart';

Color getStrategyColor(InterventionStrategyType type) {
    switch (type) {
      case InterventionStrategyType.antecedent:
        return Colors.blue;
      case InterventionStrategyType.replacement:
        return Colors.green;
      case InterventionStrategyType.consequence:
        return Colors.orange;
    }
}

extension InterventionStatusX on InterventionStatus {
  String get displayName {
    switch (this) {
      case InterventionStatus.proposed:
        return 'Propuesto';
      case InterventionStatus.active:
        return 'Activo';
      case InterventionStatus.discontinued:
        return 'Discontinuado';
    }
  }
}

extension InterventionStrategyTypeX on InterventionStrategyType {
  String get displayName {
    switch (this) {
      case InterventionStrategyType.antecedent:
        return 'Antecedente';
      case InterventionStrategyType.replacement:
        return 'Reemplazo';
      case InterventionStrategyType.consequence:
        return 'Consecuencia';
    }
  }
}
