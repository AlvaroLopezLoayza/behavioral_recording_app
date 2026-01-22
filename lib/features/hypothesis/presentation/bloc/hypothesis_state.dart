import 'package:equatable/equatable.dart';
import '../../domain/entities/functional_hypothesis.dart';

abstract class HypothesisState extends Equatable {
  const HypothesisState();

  @override
  List<Object?> get props => [];
}

class HypothesisInitial extends HypothesisState {}

class HypothesisLoading extends HypothesisState {}

class HypothesisLoaded extends HypothesisState {
  final List<FunctionalHypothesis> hypotheses;

  const HypothesisLoaded(this.hypotheses);

  @override
  List<Object?> get props => [hypotheses];
}

class HypothesisError extends HypothesisState {
  final String message;

  const HypothesisError(this.message);

  @override
  List<Object?> get props => [message];
}

class HypothesisOperationSuccess extends HypothesisState {
  final String message;

  const HypothesisOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
