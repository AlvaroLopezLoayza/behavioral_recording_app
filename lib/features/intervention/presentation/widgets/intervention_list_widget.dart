import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/intervention_plan.dart';
import '../../domain/entities/intervention_strategy.dart';
import '../bloc/intervention_bloc.dart';
import '../bloc/intervention_event.dart';
import '../bloc/intervention_state.dart';
import 'intervention_form_dialog.dart';

class InterventionListWidget extends StatelessWidget {
  final String hypothesisId;
  final String patientId;

  const InterventionListWidget({
    super.key,
    required this.hypothesisId,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BlocProvider.of<InterventionBloc>(context, listen: false)
        ..add(LoadInterventionPlans(hypothesisId)),
      child: BlocBuilder<InterventionBloc, InterventionState>(
        builder: (context, state) {
          if (state is InterventionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InterventionError) {
            return Center(child: Text(state.message));
          } else if (state is InterventionLoaded) {
            final plans = state.plans;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Planes de Intervención',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showPlanDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo Plan'),
                      ),
                    ],
                  ),
                ),
                if (plans.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No hay planes de intervención definidos para esta hipótesis.'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return _InterventionPlanCard(plan: plan);
                      },
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showPlanDialog(BuildContext context, [InterventionPlan? plan]) {
    showDialog<InterventionPlan>(
      context: context,
      builder: (context) => InterventionFormDialog(
        hypothesisId: hypothesisId,
        patientId: patientId,
        initialPlan: plan,
      ),
    ).then((newPlan) {
      if (newPlan != null) {
        if (plan == null) {
          context.read<InterventionBloc>().add(CreateInterventionPlan(newPlan));
        } else {
          context.read<InterventionBloc>().add(UpdateInterventionPlan(newPlan));
        }
      }
    });
  }
}

class _InterventionPlanCard extends StatelessWidget {
  final InterventionPlan plan;

  const _InterventionPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text('Reemplazo: ${plan.replacementBehavior}'),
        subtitle: Text('Estado: ${plan.status.name.toUpperCase()}'),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            // Need to pass the context of the InterventionBloc
            final bloc = context.read<InterventionBloc>();
            showDialog<InterventionPlan>(
              context: context,
              builder: (context) => InterventionFormDialog(
                hypothesisId: plan.hypothesisId,
                patientId: plan.patientId,
                initialPlan: plan,
              ),
            ).then((updatedPlan) {
              if (updatedPlan != null) {
                bloc.add(UpdateInterventionPlan(updatedPlan));
              }
            });
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estrategias:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...plan.strategies.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StrategyTypeBadge(type: s.type),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text(s.description, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StrategyTypeBadge extends StatelessWidget {
  final InterventionStrategyType type;

  const _StrategyTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case InterventionStrategyType.antecedent:
        color = Colors.blue;
        break;
      case InterventionStrategyType.replacement:
        color = Colors.green;
        break;
      case InterventionStrategyType.consequence:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        type.name[0].toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
