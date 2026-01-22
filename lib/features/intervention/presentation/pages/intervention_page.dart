import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../hypothesis/domain/entities/functional_hypothesis.dart';
import '../bloc/intervention_bloc.dart';
import '../widgets/intervention_list_widget.dart';

class InterventionPage extends StatelessWidget {
  final FunctionalHypothesis hypothesis;
  final String patientId;

  const InterventionPage({
    super.key,
    required this.hypothesis,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InterventionBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plan de Intervención (BIP)'),
        ),
        body: Column(
          children: [
            _buildHypothesisSummary(context),
            const Divider(),
            Expanded(
              child: InterventionListWidget(
                hypothesisId: hypothesis.id,
                patientId: patientId,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHypothesisSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 16),
              const SizedBox(width: 8),
              Text(
                'Hipótesis: ${hypothesis.functionType.label}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hypothesis.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
