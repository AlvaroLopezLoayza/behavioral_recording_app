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
              title: Text('Grabando: ${widget.definition.name}'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EventCounterWidget(
                    label: widget.definition.operationalDefinition,
                    count: _sessionCount,
                    onIncrement: () {
                      setState(() {
                        _sessionCount++;
                        _showForm = true; // Show form on first count or every count?
                      });
                    },
                    onDecrement: _sessionCount > 0 
                        ? () => setState(() => _sessionCount--) 
                        : null,
                  ),
                  
                  if (_showForm) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    AbcFormWidget(
                      formKey: _formKey,
                      isLoading: state is AbcRecordingLoading,
                      onSave: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final values = _formKey.currentState!.value;
                          
                          final occurrence = BehaviorOccurrence(
                             startTime: DateTime.now(), // Ideally capture when button was trapped
                             intensity: (values['intensity'] as double?)?.toInt(),
                          );
                          
                          final userId = supabase.auth.currentUser?.id;
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Por favor inicia sesión')),
                            );
                            return;
                          }

                          final record = AbcRecord(
                            id: _uuid.v4(),
                            behaviorDefinitionId: widget.definition.id,
                            antecedent: {'description': values['antecedent_description']},
                            consequence: {'description': values['consequence_description']},
                            behaviorOccurrence: occurrence,
                            recordingType: RecordingType.event,
                            observerId: userId,
                            timestamp: DateTime.now(),
                          );
                          
                          context.read<AbcRecordingBloc>().add(SaveAbcRecord(record));
                        }
                      },
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
                            title: Text('A: ${record.antecedent['description']}'),
                            subtitle: Text('C: ${record.consequence['description']}'),
                            trailing: Text(
                              '${record.timestamp.hour}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        );
                      },
                    )
                  else if (state is AbcRecordingLoading)
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
}
