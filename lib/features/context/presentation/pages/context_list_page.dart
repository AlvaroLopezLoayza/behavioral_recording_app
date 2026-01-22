import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/context.dart';
import '../bloc/context_bloc.dart';
import '../bloc/context_event.dart';
import '../bloc/context_state.dart';

class ContextListPage extends StatelessWidget {
  final String patientId;

  const ContextListPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContextBloc>()..add(LoadContexts(patientId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contextos y Ambientes'),
        ),
        body: const ContextListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddContextDialog(context, patientId),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddContextDialog(BuildContext parentContext, String patientId) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        // Use BlocProvider.value to pass the bloc from parent context
        return BlocProvider.value(
          value: BlocProvider.of<ContextBloc>(parentContext),
          child: _AddContextDialog(patientId: patientId),
        );
      },
    );
  }
}

class ContextListView extends StatelessWidget {
  const ContextListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContextBloc, ContextState>(
      listener: (context, state) {
        if (state is ContextError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        } else if (state is ContextOperationSuccess) {
           Navigator.of(context).popUntil((route) => route.settings.name != 'submit'); // Close dialog if open? 
           // Actually simpler to handle dialog close inside the dialog widget
        }
      },
      builder: (context, state) {
        if (state is ContextLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ContextLoaded) {
          if (state.contexts.isEmpty) {
            return const Center(
              child: Text(
                'No hay contextos definidos.\nAgrega lugares como "Casa", "Escuela", etc.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.contexts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = state.contexts[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.place)),
                  title: Text(item.name),
                  subtitle: Text(item.type + (item.description.isNotEmpty ? ' - ${item.description}' : '')),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      context.read<ContextBloc>().add(
                        DeleteContextEvent(id: item.id, patientId: item.patientId),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AddContextDialog extends StatelessWidget {
  final String patientId;
  final _formKey = GlobalKey<FormBuilderState>();

  _AddContextDialog({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo Contexto'),
      content: FormBuilder(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderTextField(
              name: 'name',
              decoration: const InputDecoration(labelText: 'Nombre (ej. Casa)'),
              validator: FormBuilderValidators.required(errorText: 'Requerido'),
            ),
            const SizedBox(height: 10),
            FormBuilderDropdown<String>(
              name: 'type',
              initialValue: 'physical',
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: const [
                DropdownMenuItem(value: 'physical', child: Text('Físico (Lugar)')),
                DropdownMenuItem(value: 'social', child: Text('Social')),
                DropdownMenuItem(value: 'activity', child: Text('Actividad')),
              ],
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              name: 'description',
              decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final values = _formKey.currentState!.value;
              context.read<ContextBloc>().add(
                CreateContextEvent(
                  patientId: patientId,
                  name: values['name'],
                  type: values['type'],
                  description: values['description'] ?? '',
                ),
              );
              Navigator.pop(context); // Close immediately
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
