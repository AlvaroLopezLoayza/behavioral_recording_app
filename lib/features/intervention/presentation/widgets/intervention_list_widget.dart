import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/intervention_plan.dart';
import '../../domain/entities/intervention_strategy.dart';
import '../bloc/intervention_bloc.dart';
import '../bloc/intervention_event.dart';
import '../bloc/intervention_state.dart';
import 'intervention_form_dialog.dart';
import 'intervention_utils.dart';

class InterventionListWidget extends StatefulWidget {
  final String hypothesisId;
  final String patientId;

  const InterventionListWidget({
    super.key,
    required this.hypothesisId,
    required this.patientId,
  });

  @override
  State<InterventionListWidget> createState() => _InterventionListWidgetState();
}

class _InterventionListWidgetState extends State<InterventionListWidget> {
  @override
  void initState() {
    super.initState();
    // Dispatch event to load plans when widget initializes
    context.read<InterventionBloc>().add(LoadInterventionPlans(widget.hypothesisId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InterventionBloc, InterventionState>(
      builder: (context, state) {
        if (state is InterventionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InterventionError) {
          return Center(child: Text(state.message));
        } else if (state is InterventionLoaded) {
          final plans = state.plans;
          return Scaffold(
             // Use Scaffold inside the widget to easily get a FAB scoped to this view if needed, 
             // or just a Stack. Since this is likely a child of another Scaffold column, 
             // we should be careful. 
             // actually, better to use a Stack or just a Column with a FAB if the parent allows.
             // Given the parent is likely a Column in a page, let's use a Column but improved.
             backgroundColor: Colors.transparent,
             body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(Icons.assignment_turned_in, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Planes de Intervención',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      // Removed the big button here to avoid overflow. 
                      // Using a small icon button or relying on a bottom action.
                      // Let's keep a compact button if needed, or better, use a FAB approach 
                      // handled by the parent or an overlay.
                      // For now, a compact icon button is safe.
                      IconButton.filledTonal(
                         onPressed: () => _showPlanDialog(context),
                         icon: const Icon(Icons.add),
                         tooltip: 'Crear Nuevo Plan',
                      )
                    ],
                  ),
                ),
                if (plans.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_note, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay planes definidos.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () => _showPlanDialog(context), 
                            child: const Text('Crear Primer Plan')
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Padding for potential FAB
                      itemCount: plans.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return _InterventionPlanCard(plan: plan);
                      },
                    ),
                  ),
              ],
            ),
             floatingActionButton: plans.isNotEmpty ? FloatingActionButton(
                onPressed: () => _showPlanDialog(context),
                child: const Icon(Icons.add),
                tooltip: 'Nuevo Plan',
             ) : null,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showPlanDialog(BuildContext context, [InterventionPlan? plan]) {
    showDialog<InterventionPlan>(
      context: context,
      builder: (context) => InterventionFormDialog(
        hypothesisId: widget.hypothesisId,
        patientId: widget.patientId,
        initialPlan: plan,
      ),
    ).then((newPlan) {
      if (newPlan != null && mounted) {
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildStatusIcon(plan.status),
        title: Text(
          plan.replacementBehavior,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${plan.strategies.length} Estrategias',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estrategias Detalladas', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
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
                    )
                  ],
                ),
                const SizedBox(height: 8),
                if (plan.strategies.isEmpty)
                   const Text('No estrategias definidas.', style: TextStyle(fontStyle: FontStyle.italic)),
                ...plan.strategies.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StrategyTypeBadge(type: s.type),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  if (s.description.isNotEmpty)
                                    Text(s.description, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(InterventionStatus status) {
    Color color;
    IconData icon;
    switch (status) {
      case InterventionStatus.proposed:
        color = Colors.orange;
        icon = Icons.pending_outlined;
        break;
      case InterventionStatus.active:
        color = Colors.green;
        icon = Icons.play_circle_outline;
        break;
      case InterventionStatus.discontinued:
        color = Colors.grey;
        icon = Icons.stop_circle_outlined;
        break;
    }
    return Tooltip(
      message: status.displayName,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _StrategyTypeBadge extends StatelessWidget {
  final InterventionStrategyType type;

  const _StrategyTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color = getStrategyColor(type);

    return Tooltip(
      message: type.displayName,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color),
        ),
        child: Text(
          type.displayName[0].toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
