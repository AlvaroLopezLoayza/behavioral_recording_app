import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';
import '../../../../main.dart';
import '../../domain/entities/function_type.dart';
import '../../domain/entities/functional_hypothesis.dart';

class HypothesisFormDialog extends StatefulWidget {
  final String behaviorId;
  final FunctionalHypothesis? initialHypothesis;

  const HypothesisFormDialog({
    super.key,
    required this.behaviorId,
    this.initialHypothesis,
  });

  @override
  State<HypothesisFormDialog> createState() => _HypothesisFormDialogState();
}

class _HypothesisFormDialogState extends State<HypothesisFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialHypothesis == null ? 'Nueva Hipótesis' : 'Editar Hipótesis'),
      content: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderDropdown<FunctionType>(
                name: 'function_type',
                initialValue: widget.initialHypothesis?.functionType ?? FunctionType.socialPositive,
                decoration: const InputDecoration(labelText: 'Función Probable'),
                items: FunctionType.values
                    .where((e) => e != FunctionType.unknown)
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.label),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                initialValue: widget.initialHypothesis?.description,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Notas',
                  hintText: 'Ej. Mantenido por atención del profesor...',
                ),
                maxLines: 3,
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              const Text('Nivel de Confianza'),
              FormBuilderSlider(
                name: 'confidence',
                initialValue: widget.initialHypothesis?.confidence ?? 0.5,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                displayValues: DisplayValues.current,
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<HypothesisStatus>(
                name: 'status',
                initialValue: widget.initialHypothesis?.status ?? HypothesisStatus.draft,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: HypothesisStatus.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name.toUpperCase()),
                        ))
                    .toList(),
              ),
            ],
          ),
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
              final now = DateTime.now();
              
              final hypothesis = FunctionalHypothesis(
                id: widget.initialHypothesis?.id ?? const Uuid().v4(),
                behaviorDefinitionId: widget.behaviorId,
                functionType: values['function_type'],
                description: values['description'],
                confidence: values['confidence'],
                status: values['status'],
                createdBy: supabase.auth.currentUser?.id ?? '',
                createdAt: widget.initialHypothesis?.createdAt ?? now,
                updatedAt: now,
              );
              
              Navigator.pop(context, hypothesis);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
