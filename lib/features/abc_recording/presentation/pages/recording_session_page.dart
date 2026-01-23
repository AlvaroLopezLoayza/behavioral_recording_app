import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uuid/uuid.dart';
import '../../../../main.dart'; // To access global supabase client

import '../../../../injection_container.dart';
import '../../../behavior_definition/domain/entities/behavior_definition.dart';
import '../../domain/entities/abc_record.dart';
import '../../domain/entities/behavior_occurrence.dart';
import '../bloc/abc_recording_bloc.dart';
import '../bloc/abc_recording_event.dart';
import '../bloc/abc_recording_state.dart';
import '../widgets/duration_recording_widget.dart';
import '../widgets/interval_recording_widget.dart';
import '../widgets/abc_form_widget.dart';
import '../widgets/event_counter_widget.dart';

class RecordingSessionPage extends StatefulWidget {
  final BehaviorDefinition definition;

  const RecordingSessionPage({
    super.key,
    required this.definition,
  });

  @override
  State<RecordingSessionPage> createState() => _RecordingSessionPageState();
}

class _RecordingSessionPageState extends State<RecordingSessionPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _sessionCount = 0;
  final _uuid = const Uuid();
  bool _showForm = false;
  RecordingType _selectedType = RecordingType.event;
  BehaviorOccurrence? _pendingOccurrence;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AbcRecordingBloc>()..add(LoadAbcRecords(widget.definition.id)),
      child: BlocConsumer<AbcRecordingBloc, AbcRecordingState>(
        listener: (context, state) {
          if (state is AbcRecordSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro guardado exitosamente')),
            );
            _formKey.currentState?.reset();
            setState(() {
              _showForm = false;
              _pendingOccurrence = null;
            });
          } else if (state is AbcRecordingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Registrando: ${widget.definition.name}'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mode Selector
                  Center(
                    child: SegmentedButton<RecordingType>(
                      segments: const [
                        ButtonSegment(value: RecordingType.event, label: Text('Evento'), icon: Icon(Icons.touch_app)),
                        ButtonSegment(value: RecordingType.continuous, label: Text('Duración'), icon: Icon(Icons.timer)),
                        ButtonSegment(value: RecordingType.interval, label: Text('Intervalo'), icon: Icon(Icons.grid_on)),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (set) {
                        setState(() {
                          _selectedType = set.first;
                          _showForm = false;
                          _pendingOccurrence = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active Tool
                  if (!_showForm) ...[
                    if (_selectedType == RecordingType.event)
                      EventCounterWidget(
                        label: widget.definition.operationalDefinition,
                        count: _sessionCount,
                        onIncrement: () {
                          setState(() {
                            _sessionCount++;
                            _pendingOccurrence = BehaviorOccurrence(startTime: DateTime.now());
                            _showForm = true;
                          });
                        },
                        onDecrement: _sessionCount > 0 
                            ? () => setState(() => _sessionCount--) 
                            : null,
                      ),
                    if (_selectedType == RecordingType.continuous)
                      DurationRecordingWidget(
                        label: widget.definition.operationalDefinition,
                        onStop: (start, end, duration) {
                          setState(() {
                             _pendingOccurrence = BehaviorOccurrence(
                               startTime: start,
                               endTime: end,
                               duration: duration,
                             );
                             _showForm = true;
                          });
                        },
                      ),
                    if (_selectedType == RecordingType.interval)
                      IntervalRecordingWidget(
                        label: widget.definition.operationalDefinition,
                        onComplete: (intervals, length) {
                          setState(() {
                            _pendingOccurrence = BehaviorOccurrence(
                              startTime: DateTime.now(), // Group timestamp
                              notes: 'Intervalos activos: ${intervals.join(', ')} ($length s c/u)',
                            );
                            _showForm = true;
                          });
                        },
                      ),
                  ],
                  
                  if (_showForm) ...[
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        const Divider(),
                        if (_selectedType == RecordingType.continuous)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Chip(
                              label: Text('Duración capturada: ${_pendingOccurrence?.duration?.inSeconds}s'),
                              avatar: const Icon(Icons.timer_outlined),
                            ),
                          ),
                        if (_selectedType == RecordingType.interval)
                           const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Chip(
                              label: Text('Registro de Intervalos listo'),
                              avatar: Icon(Icons.grid_on),
                            ),
                          ),
                      ],
                    ),
                    AbcFormWidget(
                      formKey: _formKey,
                      isLoading: state is AbcRecordingLoading,
                      patientId: widget.definition.patientId ?? '',
                      onSave: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final values = _formKey.currentState!.value;
                          
                          final userId = supabase.auth.currentUser?.id;
                          if (userId == null) return;

                          final record = AbcRecord(
                            id: _uuid.v4(),
                            behaviorDefinitionId: widget.definition.id,
                            antecedent: {'description': values['antecedent_description']},
                            consequence: {'description': values['consequence_description']},
                            behaviorOccurrence: BehaviorOccurrence(
                              startTime: _pendingOccurrence?.startTime ?? DateTime.now(),
                              endTime: _pendingOccurrence?.endTime,
                              duration: _pendingOccurrence?.duration,
                              intensity: (values['intensity'] as double?)?.toInt(),
                              notes: _pendingOccurrence?.notes, // Carry over interval info if exists
                            ),
                            recordingType: _selectedType,
                            observerId: userId,
                            timestamp: DateTime.now(),
                            contextId: values['context_id'] as String?,
                          );
                          
                          context.read<AbcRecordingBloc>().add(SaveAbcRecord(record));
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _showForm = false),
                      child: const Text('Cancelar / Volver'),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Registros Recientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (state is AbcRecordingLoaded)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.records.length,
                      itemBuilder: (context, index) {
                        final record = state.records[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(_getIconForType(record.recordingType)),
                            title: Text('A: ${record.antecedent['description']}'),
                            subtitle: Text('C: ${record.consequence['description']}'),
                            trailing: Text(
                              '${record.timestamp.hour}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        );
                      },
                    )
                  else if (state is AbcRecordingLoading && !_showForm)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(RecordingType type) {
    switch (type) {
      case RecordingType.event: return Icons.touch_app;
      case RecordingType.continuous: return Icons.timer;
      case RecordingType.interval: return Icons.grid_on;
    }
  }
}
