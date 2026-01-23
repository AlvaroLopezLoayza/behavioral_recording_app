import 'package:equatable/equatable.dart';
import '../../domain/entities/clinical_context.dart';

abstract class ContextEvent extends Equatable {
  const ContextEvent();

  @override
  List<Object> get props => [];
}

class LoadContexts extends ContextEvent {
  final String patientId;

  const LoadContexts(this.patientId);
}

class CreateContextEvent extends ContextEvent {
  final String patientId;
  final String name;
  final String description;
  final String type;

  const CreateContextEvent({
    required this.patientId,
    required this.name,
    this.description = '',
    this.type = 'physical',
  });
}

class DeleteContextEvent extends ContextEvent {
  final String id;
  final String patientId; // Needed to reload list

  const DeleteContextEvent({required this.id, required this.patientId});
}
