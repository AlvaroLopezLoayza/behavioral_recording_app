import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'context_selector.dart';

class AbcFormWidget extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final VoidCallback onSave;
  final bool isLoading;
  final String patientId;
  final String? initialContextId;

  const AbcFormWidget({
    super.key,
    required this.formKey,
    required this.onSave,
    this.isLoading = false,
    required this.patientId,
    this.initialContextId,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      initialValue: {
        if (initialContextId != null) 'context_id': initialContextId,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
             padding: const EdgeInsets.symmetric(vertical: 8.0),
             child: Row(
               children: [
                 Icon(Icons.edit_note, color: Theme.of(context).colorScheme.primary),
                 const SizedBox(width: 8),
                 Text(
            'Detalles del Contexto',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    
    // Context Selection
    _buildInputCard(
      context, 
      label: 'Contexto / Ambiente', 
      child: ContextSelector(
        patientId: patientId,
        name: 'context_id',
      ),
    ),
    const SizedBox(height: 16),

    _buildInputCard(
      context,
      label: 'Antecedente',
      child: FormBuilderTextField(
        name: 'antecedent_description',
        decoration: const InputDecoration(
          hintText: '¿Qué pasó justo antes?',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        validator: FormBuilderValidators.required(),
        textCapitalization: TextCapitalization.sentences,
        maxLines: 2,
        minLines: 1,
      ),
    ),
    
    const SizedBox(height: 16),
    
    _buildInputCard(
      context,
      label: 'Consecuencia',
      child: FormBuilderTextField(
        name: 'consequence_description',
        decoration: const InputDecoration(
          hintText: '¿Qué pasó justo después?',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        validator: FormBuilderValidators.required(),
        textCapitalization: TextCapitalization.sentences,
        maxLines: 2,
        minLines: 1,
      ),
    ),
    
    const SizedBox(height: 24),
    
    Text(
      'Intensidad',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.secondary,
      ),
    ),
    const SizedBox(height: 8),
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withAlpha(50)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FormBuilderSlider(
        name: 'intensity',
        min: 1.0,
        max: 5.0,
        divisions: 4,
        initialValue: 3.0,
        activeColor: Theme.of(context).colorScheme.secondary,
        inactiveColor: Theme.of(context).colorScheme.secondary.withAlpha(50),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ),
      
    const SizedBox(height: 32),
    
    SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onSave,
        icon: isLoading 
            ? const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ) 
            : const Icon(Icons.check),
        label: const Text('Guardar Registro'),
      ),
    ),
  ],
),
);
}

Widget _buildInputCard(BuildContext context, {required String label, required Widget child}) {
return Container(
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(24),
   border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(20)),
),
padding: const EdgeInsets.all(20),
child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
