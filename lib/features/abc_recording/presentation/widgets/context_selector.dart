import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../injection_container.dart';
import '../../../context/domain/entities/clinical_context.dart';
import '../../../context/presentation/bloc/context_bloc.dart';
import '../../../context/presentation/bloc/context_event.dart';
import '../../../context/presentation/bloc/context_state.dart';

class ContextSelector extends StatelessWidget {
  final String patientId;
  final String name;

  const ContextSelector({
    super.key,
    required this.patientId,
    this.name = 'context_id',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContextBloc>()..add(LoadContexts(patientId)),
      child: BlocBuilder<ContextBloc, ContextState>(
        builder: (context, state) {
          List<ClinicalContext> items = [];
          bool isLoading = true;

          if (state is ContextLoaded) {
            items = state.contexts;
            isLoading = false;
          } else if (state is ContextError) {
            isLoading = false;
            // Optionally handle error visually
          }

          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (items.isEmpty) {
             return const Text('No hay contextos disponibles');
          }

          return FormBuilderDropdown<String>(
            name: name,
            decoration: const InputDecoration(
              labelText: 'Contexto / Ambiente',
              prefixIcon: Icon(Icons.place),
            ),
            validator: FormBuilderValidators.required(errorText: 'Selecciona un contexto'),
            items: items.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text(c.name),
            )).toList(),
          );
        },
      ),
    );
  }
}
