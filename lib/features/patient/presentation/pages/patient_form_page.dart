import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../injection_container.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class PatientFormPage extends StatefulWidget {
  const PatientFormPage({super.key});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PatientBloc>(),
      child: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is PatientOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context, true);
          } else if (state is PatientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Nuevo Paciente'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Información del Paciente',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    FormBuilderTextField(
                      name: 'firstName',
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: FormBuilderValidators.compose([
                         FormBuilderValidators.required(errorText: 'Requerido'),
                         FormBuilderValidators.minLength(2),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'lastName',
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: FormBuilderValidators.compose([
                         FormBuilderValidators.required(errorText: 'Requerido'),
                         FormBuilderValidators.minLength(2),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderDateTimePicker(
                      name: 'birthDate',
                      inputType: InputType.date,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Nacimiento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                         validator: FormBuilderValidators.required(errorText: 'Requerido'),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'diagnosis',
                      decoration: const InputDecoration(
                        labelText: 'Diagnóstico (Opcional)',
                        border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.medical_services_outlined),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: state is PatientLoading 
                          ? null 
                          : () {
                              if (_formKey.currentState?.saveAndValidate() ?? false) {
                                final values = _formKey.currentState!.value;
                                context.read<PatientBloc>().add(
                                  CreatePatientEvent(
                                    firstName: values['firstName'],
                                    lastName: values['lastName'],
                                    birthDate: values['birthDate'],
                                    diagnosis: values['diagnosis'],
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is PatientLoading
                          ? const SizedBox(
                              height: 20, 
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Guardar Paciente'),
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
