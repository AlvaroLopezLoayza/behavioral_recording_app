import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../behavior_definition/domain/entities/behavior_definition.dart';
import '../bloc/analysis_bloc.dart';
import '../bloc/analysis_event.dart';
import '../bloc/analysis_state.dart';
import '../widgets/trend_chart_widget.dart';

class AnalysisPage extends StatelessWidget {
  final BehaviorDefinition definition;

  const AnalysisPage({super.key, required this.definition});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnalysisBloc>()..add(LoadTrendAnalysis(definition.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Análisis'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                definition.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                definition.operationalDefinition,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              
              BlocBuilder<AnalysisBloc, AnalysisState>(
                builder: (context, state) {
                  if (state is AnalysisLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AnalysisLoaded) {
                    return Column(
                      children: [
                        TrendChartWidget(data: state.data),
                        const SizedBox(height: 24),
                        // Additional stats could go here
                        _buildSummaryCard(context, state.data),
                      ],
                    );
                  } else if (state is AnalysisError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, dynamic data) {
    return Card(
        // Use default theme card
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(context, 'Total', data.dataPoints.fold(0, (sum, item) => sum + item.count).toString()),
          _buildStat(context, 'Máx/Día', data.maxFrequency.toString()),
          _buildStat(context, 'Prom/Día', data.averageFrequency.toStringAsFixed(1)),
        ],
      ),
    ));
  }
  
  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        )),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
