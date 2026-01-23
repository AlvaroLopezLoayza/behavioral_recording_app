import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/util/report_export_service.dart';
import '../../../../injection_container.dart';
import '../../../behavior_definition/domain/entities/behavior_definition.dart';
import '../../../hypothesis/presentation/bloc/hypothesis_bloc.dart';
import '../../../hypothesis/presentation/bloc/hypothesis_event.dart';
import '../../../hypothesis/presentation/widgets/hypothesis_list_widget.dart';
import '../../domain/entities/conditional_probability.dart';
import '../../domain/entities/trend_analysis.dart';
import '../bloc/analysis_bloc.dart';
import '../bloc/analysis_event.dart';
import '../bloc/analysis_state.dart';
import '../widgets/trend_chart_widget.dart';

class AnalysisPage extends StatelessWidget {
  final BehaviorDefinition definition;

  const AnalysisPage({super.key, required this.definition});

  void _showExportOptions(BuildContext context, AnalysisLoaded state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Exportar Resumen (PDF)'),
              onTap: () {
                Navigator.pop(context);
                ReportExportService.exportAnalysisToPdf(
                  patientName: 'Paciente',
                  records: [], 
                  antecedentProbabilities: {
                    for (var p in state.probabilityData?.antecedentProbabilities ?? [])
                      p.name: p.probability
                  },
                  consequenceProbabilities: {
                    for (var p in state.probabilityData?.consequenceProbabilities ?? [])
                      p.name: p.probability
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Exportar Datos Raw (CSV)'),
              onTap: () {
                Navigator.pop(context);
                ReportExportService.exportAbcRecordsToCsv([], 'Paciente');
              },
            ),
          ],
        ),
      ),
    );
  }

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
            title: const Text('Paso 4: Análisis'),
            actions: [
              BlocBuilder<AnalysisBloc, AnalysisState>(
                builder: (context, state) {
                  if (state is AnalysisLoaded) {
                    return IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _showExportOptions(context, state),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
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
              TrendAnalysis? trendData;
              ConditionalProbabilityResult? probabilityData;
              bool isLoading = false;

              if (state is AnalysisLoading) {
                trendData = state.previousTrendData;
                probabilityData = state.previousProbabilityData;
                isLoading = true;
              } else if (state is AnalysisLoaded) {
                trendData = state.trendData;
                probabilityData = state.probabilityData;
              } else if (state is AnalysisError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              if (isLoading && trendData == null && probabilityData == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                children: [
                   TabBarView(
                    children: [
                      _buildTrendView(context, trendData, probabilityData),
                      _buildProbabilityView(context, probabilityData),
                      _buildHypothesisView(context),
                    ],
                  ),
                  if (isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrendView(BuildContext context, TrendAnalysis? data, ConditionalProbabilityResult? probabilityData) {
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

  Widget _buildProbabilityView(BuildContext context, ConditionalProbabilityResult? data) {
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
