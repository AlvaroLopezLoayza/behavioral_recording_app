import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../behavior_definition/domain/entities/behavior_definition.dart';
import '../../../intervention/presentation/pages/intervention_page.dart';
import '../bloc/hypothesis_bloc.dart';
import '../bloc/hypothesis_event.dart';
import '../bloc/hypothesis_state.dart';
import '../widgets/hypothesis_form_dialog.dart';
import '../../domain/entities/functional_hypothesis.dart';

class HypothesisListWidget extends StatelessWidget {
  final BehaviorDefinition behavior;

  const HypothesisListWidget({super.key, required this.behavior});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HypothesisBloc, HypothesisState>(
      listener: (context, state) {
        if (state is HypothesisOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is HypothesisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        if (state is HypothesisLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HypothesisLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hipótesis Funcionales',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _showForm(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.hypotheses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay hipótesis definidas aún.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.hypotheses.length,
                  itemBuilder: (context, index) {
                    final hypothesis = state.hypotheses[index];
                    return _buildHypothesisCard(context, hypothesis);
                  },
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHypothesisCard(BuildContext context, FunctionalHypothesis hypothesis) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(hypothesis.functionType.label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hypothesis.description),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(hypothesis.status),
                const SizedBox(width: 8),
                Text('Confianza: ${(hypothesis.confidence * 100).toInt()}%'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'bip') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InterventionPage(
                    hypothesis: hypothesis,
                    patientId: behavior.patientId ?? '',
                  ),
                ),
              );
            } else if (value == 'edit') {
              _showForm(context, initialHypothesis: hypothesis);
            } else if (value == 'delete') {
              _confirmDelete(context, hypothesis);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'bip', child: Text('Planes de Intervención')),
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(HypothesisStatus status) {
    Color color;
    switch (status) {
      case HypothesisStatus.draft:
        color = Colors.grey;
        break;
      case HypothesisStatus.active:
        color = Colors.blue;
        break;
      case HypothesisStatus.disproven:
        color = Colors.red;
        break;
      case HypothesisStatus.verified:
        color = Colors.green;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showForm(BuildContext context, {FunctionalHypothesis? initialHypothesis}) async {
    final result = await showDialog<FunctionalHypothesis>(
      context: context,
      builder: (context) => HypothesisFormDialog(
        behaviorId: behavior.id,
        initialHypothesis: initialHypothesis,
      ),
    );

    if (result != null && context.mounted) {
      if (initialHypothesis == null) {
        context.read<HypothesisBloc>().add(CreateHypothesis(result));
      } else {
        context.read<HypothesisBloc>().add(UpdateHypothesis(result));
      }
    }
  }

  void _confirmDelete(BuildContext context, FunctionalHypothesis hypothesis) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Hipótesis'),
        content: const Text('¿Estás seguro de que deseas eliminar esta hipótesis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<HypothesisBloc>().add(
                    DeleteHypothesis(id: hypothesis.id, behaviorId: behavior.id),
                  );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
