import 'package:equatable/equatable.dart';
import '../../domain/entities/context.dart';

abstract class ContextState extends Equatable {
  const ContextState();
  
  @override
  List<Object> get props => [];
}

class ContextInitial extends ContextState {}

class ContextLoading extends ContextState {}

class ContextLoaded extends ContextState {
  final List<Context> contexts;

  const ContextLoaded(this.contexts);

  @override
  List<Object> get props => [contexts];
}

class ContextOperationSuccess extends ContextState {
  final String message;

  const ContextOperationSuccess(this.message);
  
  @override
  List<Object> get props => [message];
}

class ContextError extends ContextState {
  final String message;

  const ContextError(this.message);

  @override
  List<Object> get props => [message];
}
