import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../../main.dart'; // To access global supabase client
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/behavior_definition.dart';
import '../bloc/behavior_definition_bloc.dart';
import '../bloc/behavior_definition_event.dart';
import '../bloc/behavior_definition_state.dart';

class BehaviorDefinitionFormPage extends StatefulWidget {
  final String? patientId;
  const BehaviorDefinitionFormPage({super.key, this.patientId});

  @override
  State<BehaviorDefinitionFormPage> createState() => _BehaviorDefinitionFormPageState();
}

class _BehaviorDefinitionFormPageState extends State<BehaviorDefinitionFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BehaviorDefinitionBloc>(),
      child: BlocConsumer<BehaviorDefinitionBloc, BehaviorDefinitionState>(
        listener: (context, state) {
          if (state is BehaviorDefinitionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Definición creada exitosamente')),
            );
            Navigator.pop(context, true);
          } else if (state is BehaviorDefinitionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Nueva Definición'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Define un comportamiento',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'name',
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Comportamiento',
                        hintText: 'ej. Agresión, Aleteo',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Requerido'),
                        FormBuilderValidators.minLength(3, errorText: 'Mínimo 3 caracteres'),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'operational_definition',
                      decoration: const InputDecoration(
                        labelText: 'Definición Operacional',
                        hintText: 'Describe excatamente cómo se ve...',
                        border: OutlineInputBorder(),
                        helperText: 'Debe ser observable y medible (min 10 caracteres)',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Requerido'),
                        FormBuilderValidators.minLength(10, errorText: 'Mínimo 10 caracteres'),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            FormBuilderCheckbox(
                              name: 'is_observable',
                              title: const Text('¿Es Observable?'),
                              subtitle: const Text('¿Puedes verlo o escucharlo?'),
                              initialValue: true,
                            ),
                            FormBuilderCheckbox(
                              name: 'is_measurable',
                              title: const Text('¿Es Medible?'),
                              subtitle: const Text('¿Puedes contarlo o medirlo?'),
                              initialValue: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderFilterChip<String>(
                      name: 'dimensions',
                      decoration: const InputDecoration(
                        labelText: 'Dimensiones a Registrar',
                        border: InputBorder.none,
                      ),
                      options: const [
                        FormBuilderChipOption(value: 'frequency', child: Text('Frecuencia')),
                        FormBuilderChipOption(value: 'duration', child: Text('Duración')),
                        FormBuilderChipOption(value: 'latency', child: Text('Latencia')),
                        FormBuilderChipOption(value: 'intensity', child: Text('Intensidad')),
                      ],
                      validator: FormBuilderValidators.required(errorText: 'Selecciona al menos una'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:state is BehaviorDefinitionLoading 
                          ? null 
                          : () {
                              if (_formKey.currentState?.saveAndValidate() ?? false) {
                                final values = _formKey.currentState!.value;
                                
                                final userId = supabase.auth.currentUser?.id;
                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Por favor inicia sesión')),
                                  );
                                  return;
                                }

                                final definition = BehaviorDefinition(
                                  id: _uuid.v4(),
                                  name: values['name'],
                                  operationalDefinition: values['operational_definition'],
                                  isObservable: values['is_observable'] ?? false,
                                  isMeasurable: values['is_measurable'] ?? false,
                                  dimensions: List<String>.from(values['dimensions'] ?? []),
                                  patientId: widget.patientId,
                                  createdBy: userId,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                );
                                
                                context.read<BehaviorDefinitionBloc>().add(
                                  CreateBehaviorDefinitionEvent(definition),
                                );
                              }
                            },
                      child: state is BehaviorDefinitionLoading
                          ? const CircularProgressIndicator()
                          : const Text('Crear Definición'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
