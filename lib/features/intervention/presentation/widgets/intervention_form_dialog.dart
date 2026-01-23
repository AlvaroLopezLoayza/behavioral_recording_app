import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';

import '../../../../main.dart';
import '../../domain/entities/intervention_plan.dart';
import '../../domain/entities/intervention_strategy.dart';
import 'intervention_utils.dart';

class InterventionFormDialog extends StatefulWidget {
  final String hypothesisId;
  final String patientId;
  final InterventionPlan? initialPlan;

  const InterventionFormDialog({
    super.key,
    required this.hypothesisId,
    required this.patientId,
    this.initialPlan,
  });

  @override
  State<InterventionFormDialog> createState() => _InterventionFormDialogState();
}

class _InterventionFormDialogState extends State<InterventionFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  late List<InterventionStrategy> _strategies;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the list
    _strategies = widget.initialPlan != null 
        ? List.from(widget.initialPlan!.strategies)
        : [];
  }

  void _addStrategy() {
    showDialog<InterventionStrategy>(
      context: context,
      builder: (context) => const StrategyDialog(),
    ).then((strategy) {
      if (strategy != null) {
        setState(() {
          _strategies.add(strategy);
        });
      }
    });
  }

  void _removeStrategy(int index) {
    setState(() {
      _strategies.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialPlan == null ? 'Nuevo Plan de Intervención' : 'Editar Plan'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: 'replacement_behavior',
                  initialValue: widget.initialPlan?.replacementBehavior,
                  decoration: const InputDecoration(
                    labelText: 'Conducta de Reemplazo',
                    // placeholder: 'Ej. Solicitar ayuda de forma verbal',
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estrategias', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).primaryColor,
                      onPressed: _addStrategy,
                    ),
                  ],
                ),
                const Divider(),
                if (_strategies.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!)
                    ),
                    child: const Text('No hay estrategias añadidas aún.\nPulsa + para agregar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  ),
                ..._strategies.asMap().entries.map((entry) {
                  final index = entry.key;
                  final strategy = entry.value;
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!)
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: getStrategyColor(strategy.type).withOpacity(0.2),
                        child: Text(strategy.type.displayName[0].toUpperCase(), 
                          style: TextStyle(fontSize: 10, color: getStrategyColor(strategy.type), fontWeight: FontWeight.bold)
                        ),
                      ),
                      title: Text(strategy.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(strategy.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                        onPressed: () => _removeStrategy(index),
                        splashRadius: 20,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                FormBuilderDropdown<InterventionStatus>(
                  name: 'status',
                  initialValue: widget.initialPlan?.status ?? InterventionStatus.proposed,
                  decoration: const InputDecoration(labelText: 'Estado del Plan'),
                  items: InterventionStatus.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.displayName),
                          ))
                      .toList(),
                ),
              ],
            ),
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

              final plan = InterventionPlan(
                id: widget.initialPlan?.id ?? const Uuid().v4(),
                hypothesisId: widget.hypothesisId,
                patientId: widget.patientId,
                replacementBehavior: values['replacement_behavior'],
                strategies: _strategies,
                status: values['status'],
                createdBy: supabase.auth.currentUser?.id ?? '',
                createdAt: widget.initialPlan?.createdAt ?? now,
                updatedAt: now,
              );

              Navigator.pop(context, plan);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class StrategyDialog extends StatefulWidget {
  const StrategyDialog({super.key});

  @override
  State<StrategyDialog> createState() => _StrategyDialogState();
}

class _StrategyDialogState extends State<StrategyDialog> {
  final _strategyFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir Estrategia'),
      content: FormBuilder(
        key: _strategyFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderDropdown<InterventionStrategyType>(
              name: 'type',
              initialValue: InterventionStrategyType.antecedent,
              decoration: const InputDecoration(labelText: 'Tipo de Estrategia'),
              items: InterventionStrategyType.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.displayName),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'name',
              decoration: const InputDecoration(labelText: 'Nombre de la Estrategia'),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'description',
              decoration: const InputDecoration(labelText: 'Descripción detallada'),
              maxLines: 2,
              validator: FormBuilderValidators.required(),
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
            if (_strategyFormKey.currentState?.saveAndValidate() ?? false) {
              final values = _strategyFormKey.currentState!.value;
              final strategy = InterventionStrategy(
                id: const Uuid().v4(),
                name: values['name'],
                description: values['description'],
                type: values['type'],
              );
              Navigator.pop(context, strategy);
            }
          },
          child: const Text('Añadir'),
        ),
      ],
    );
  }
}
