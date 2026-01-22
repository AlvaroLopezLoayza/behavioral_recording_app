import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../behavior_definition/domain/entities/behavior_definition.dart';
import '../bloc/analysis_bloc.dart';
import '../bloc/analysis_event.dart';
import '../bloc/analysis_state.dart';
import '../widgets/trend_chart_widget.dart';
import '../../hypothesis/presentation/bloc/hypothesis_bloc.dart';
import '../../hypothesis/presentation/bloc/hypothesis_event.dart';
import '../../hypothesis/presentation/widgets/hypothesis_list_widget.dart';

class AnalysisPage extends StatelessWidget {
  final BehaviorDefinition definition;

  const AnalysisPage({super.key, required this.definition});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AnalysisBloc>()
            ..add(LoadTrendAnalysis(definition.id))
            ..add(LoadConditionalProbabilities(definition.id)),
        ),
        BlocProvider(
          create: (_) => sl<HypothesisBloc>()..add(LoadHypotheses(definition.id)),
        ),
      ],
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Análisis'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Tendencia'),
                Tab(text: 'Probabilidad Condicional'),
                Tab(text: 'Hipótesis'),
              ],
            ),
          ),
          body: BlocBuilder<AnalysisBloc, AnalysisState>(
            builder: (context, state) {
              if (state is AnalysisLoading && (state is! AnalysisLoaded)) { // Only show full loading if no data
                return const Center(child: CircularProgressIndicator());
              } else if (state is AnalysisError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is AnalysisLoaded) {
                return TabBarView(
                  children: [
                    _buildTrendView(context, state),
                    _buildProbabilityView(context, state),
                    _buildHypothesisView(context),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrendView(BuildContext context, AnalysisLoaded state) {
    final data = state.trendData;
    if (data == null) {
      return const Center(child: Text('No hay datos de tendencia disponibles'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(definition.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(definition.operationalDefinition, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          TrendChartWidget(data: data),
          const SizedBox(height: 24),
          _buildSummaryCard(context, data),
        ],
      ),
    );
  }

  Widget _buildProbabilityView(BuildContext context, AnalysisLoaded state) {
    final data = state.probabilityData;
    if (data == null) {
      return const Center(child: Text('No hay datos de probabilidad disponibles'));
    }

    if (data.totalOccurrences == 0) {
      return const Center(child: Text('No hay registros suficientes para calcular probabilidades.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Total de Ocurrencias: ${data.totalOccurrences}', 
             style: Theme.of(context).textTheme.titleLarge,
           ),
           const SizedBox(height: 24),
           _buildProbabilitySection(context, 'Antecedentes (¿Qué pasó antes?)', data.antecedentProbabilities),
           const SizedBox(height: 24),
           _buildProbabilitySection(context, 'Consecuencias (¿Qué pasó después?)', data.consequenceProbabilities),
        ],
      ),
    );
  }

  Widget _buildProbabilitySection(BuildContext context, String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map((item) => _buildProbabilityBar(context, item)),
      ],
    );
  }

  Widget _buildProbabilityBar(BuildContext context, dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.name),
              Text('${(item.probability * 100).toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: item.probability,
            backgroundColor: Colors.grey[200],
            color: Theme.of(context).colorScheme.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, dynamic data) {
    return Card(
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
  
  Widget _buildHypothesisView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: HypothesisListWidget(behavior: definition),
    );
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
