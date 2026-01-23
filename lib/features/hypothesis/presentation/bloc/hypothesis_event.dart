import 'package:equatable/equatable.dart';

import '../../domain/entities/functional_hypothesis.dart';

abstract class HypothesisEvent extends Equatable {
  const HypothesisEvent();

  @override
  List<Object?> get props => [];
}

class LoadHypotheses extends HypothesisEvent {
  final String behaviorId;

  const LoadHypotheses(this.behaviorId);

  @override
  List<Object?> get props => [behaviorId];
}

class CreateHypothesis extends HypothesisEvent {
  final FunctionalHypothesis hypothesis;

  const CreateHypothesis(this.hypothesis);

  @override
  List<Object?> get props => [hypothesis];
}

class UpdateHypothesis extends HypothesisEvent {
  final FunctionalHypothesis hypothesis;

  const UpdateHypothesis(this.hypothesis);

  @override
  List<Object?> get props => [hypothesis];
}

class DeleteHypothesis extends HypothesisEvent {
  final String id;
  final String behaviorId;

  const DeleteHypothesis({required this.id, required this.behaviorId});

  @override
  List<Object?> get props => [id, behaviorId];
}
