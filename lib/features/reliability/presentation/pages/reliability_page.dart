import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/util/report_export_service.dart';
import '../../../../features/behavior_definition/presentation/bloc/behavior_definition_bloc.dart';
import '../../../../features/behavior_definition/presentation/bloc/behavior_definition_event.dart';
import '../../../../features/behavior_definition/presentation/bloc/behavior_definition_state.dart';
import '../../../../features/patient/domain/entities/patient.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/reliability_record.dart';
import '../bloc/reliability_bloc.dart';
import '../bloc/reliability_event.dart';
import '../bloc/reliability_state.dart';

class ReliabilityPage extends StatefulWidget {
  final Patient patient;

  const ReliabilityPage({super.key, required this.patient});

  @override
  State<ReliabilityPage> createState() => _ReliabilityPageState();
}

class _ReliabilityPageState extends State<ReliabilityPage> {
  String? _selectedBehaviorId;
  DateTimeRange? _dateRange;
  String _method = 'total_count';
  final TextEditingController _intervalController = TextEditingController(text: '60');

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ReliabilityBloc>()..add(LoadReliabilityRecords(widget.patient.id))),
        BlocProvider(create: (_) => sl<BehaviorDefinitionBloc>()..add(LoadBehaviorDefinitions(patientId: widget.patient.id))),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fiabilidad / IOA'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfigurationCard(),
              const SizedBox(height: 24),
              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Builder(
      builder: (context) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo Reporte IOA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Behavior Selection
                BlocBuilder<BehaviorDefinitionBloc, BehaviorDefinitionState>(
                  builder: (context, state) {
                    if (state is BehaviorDefinitionLoaded) {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Conducta'),
                        value: _selectedBehaviorId,
                        items: state.definitions.map((d) => DropdownMenuItem(
                          value: d.id,
                          child: Text(d.name),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedBehaviorId = val),
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                const SizedBox(height: 12),

                // Date Range Selection
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Rango de Fechas'),
                  subtitle: Text(_dateRange == null 
                    ? 'Seleccionar rango' 
                    : '${DateFormat.yMMMd().format(_dateRange!.start)} - ${DateFormat.yMMMd().format(_dateRange!.end)}'),
                  trailing: const Icon(Icons.date_range),
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _dateRange = picked);
                  },
                ),
                const Divider(),

                // Method Selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Método IOA'),
                  value: _method,
                  items: const [
                    DropdownMenuItem(value: 'total_count', child: Text('Total Count IOA')),
                    DropdownMenuItem(value: 'exact_agreement', child: Text('Exact Agreement (Interval)')),
                  ],
                  onChanged: (val) => setState(() => _method = val!),
                ),

                if (_method == 'exact_agreement') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Tamaño del Intervalo (seg)',
                      helperText: 'ej. 60 para intervalos de 1 minuto',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canCalculate() ? () => _runCalculation(context) : null,
                    child: const Text('Calcular y Guardar IOA'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Reportes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        BlocBuilder<ReliabilityBloc, ReliabilityState>(
          builder: (context, state) {
            if (state is ReliabilityLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReliabilityLoaded) {
              if (state.records.isEmpty) {
                return const Center(child: Text('No hay reportes generados aún.'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.records.length,
                itemBuilder: (context, index) {
                  final record = state.records[index];
                  return _buildRecordCard(record);
                },
              );
            } else if (state is ReliabilityError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildRecordCard(ReliabilityRecord record) {
    return BlocBuilder<BehaviorDefinitionBloc, BehaviorDefinitionState>(
      builder: (context, state) {
        String behaviorName = 'Conducta';
        if (state is BehaviorDefinitionLoaded) {
          final defs = state.definitions.where((d) => d.id == record.behaviorDefinitionId);
          if (defs.isNotEmpty) {
            behaviorName = defs.first.name;
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('${record.score.toStringAsFixed(1)}% de Acuerdo'),
            subtitle: Text('${record.method.replaceAll('_', ' ')} • ${DateFormat.yMMMd().format(record.createdAt)}'),
            trailing: IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => ReportExportService.exportReliabilityReport(
                record, 
                widget.patient.fullName, 
                behaviorName
              ),
            ),
          ),
        );
      },
    );
  }

  bool _canCalculate() {
    return _selectedBehaviorId != null && _dateRange != null;
  }

  void _runCalculation(BuildContext context) {
    final userId = sl<SupabaseClient>().auth.currentUser?.id;
    if (userId == null) return;

    context.read<ReliabilityBloc>().add(CalculateAndSaveIOA(
      patientId: widget.patient.id,
      behaviorDefinitionId: _selectedBehaviorId!,
      observer1Id: userId,
      observer2Id: userId, 
      startTime: _dateRange!.start,
      endTime: _dateRange!.end,
      method: _method,
      parameters: _method == 'exact_agreement' 
        ? {'interval_seconds': int.tryParse(_intervalController.text) ?? 60}
        : null,
    ));
  }
}
