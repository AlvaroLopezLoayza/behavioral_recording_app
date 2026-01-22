enum FunctionType {
  socialPositive,
  socialNegative,
  automaticPositive,
  automaticNegative,
  unknown;

  String get label {
    switch (this) {
      case FunctionType.socialPositive:
        return 'Social Positivo (Atención/Tangible)';
      case FunctionType.socialNegative:
        return 'Social Negativo (Escape/Evitación)';
      case FunctionType.automaticPositive:
        return 'Automático Positivo (Estimulación)';
      case FunctionType.automaticNegative:
        return 'Automático Negativo (Atenuación)';
      case FunctionType.unknown:
        return 'Desconocido';
    }
  }
}
