import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uuid/uuid.dart';

import '../../../../injection_container.dart';
import '../../../../main.dart';
import '../../../behavior_definition/domain/entities/behavior_definition.dart';
import '../../../workflow/presentation/bloc/workflow_bloc.dart';
import '../../../workflow/presentation/bloc/workflow_event.dart';
import '../../../workflow/presentation/bloc/workflow_state.dart';
import '../../domain/entities/abc_record.dart';
import '../../domain/entities/behavior_occurrence.dart';
import '../../domain/entities/recording_session.dart';
import '../bloc/abc_recording_bloc.dart';
import '../bloc/abc_recording_event.dart';
import '../widgets/abc_form_widget.dart';
import '../widgets/active_recorder_widget.dart';
import '../widgets/event_stream_list_widget.dart';
import '../widgets/session_timer_widget.dart';

class RecordingSessionPage extends StatefulWidget {
  final BehaviorDefinition definition;

  const RecordingSessionPage({super.key, required this.definition});

  @override
  State<RecordingSessionPage> createState() => _RecordingSessionPageState();
}

class _RecordingSessionPageState extends State<RecordingSessionPage> {
  final _uuid = const Uuid();
  List<AbcRecord> _sessionRecords = [];
  late DateTime _sessionStartTime;
  
  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
  }

  void _onLogEvent() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    // Get current context from workflow state to tag the record
    final currentContext = context.read<WorkflowBloc>().state.context;

    // Create optimistic record
    final newRecord = AbcRecord(
      id: _uuid.v4(),
      behaviorDefinitionId: widget.definition.id,
      antecedent: const {}, // Empty initially
      consequence: const {}, // Empty initially
      behaviorOccurrence: BehaviorOccurrence(startTime: DateTime.now()),
      recordingType: RecordingType.event,
      observerId: userId,
      timestamp: DateTime.now(),
      contextId: currentContext?.id, 
    );

    setState(() {
      _sessionRecords.insert(0, newRecord); // Add to top of stream
    });

    // Save to backend
    context.read<AbcRecordingBloc>().add(SaveAbcRecord(newRecord));
  }
  
  void _onDeleteRecord(AbcRecord record) {
    // TODO: Implement actual delete in Bloc provider
    setState(() {
      _sessionRecords.removeWhere((r) => r.id == record.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registro eliminado'),
        action: SnackBarAction(label: 'Deshacer', onPressed: () {
           // Basic undo logic for UX demo
           setState(() => _sessionRecords.insert(0, record));
        }),
      ),
    );
  }

  void _showDetailSheet(AbcRecord record) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalles del Evento',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: AbcFormWidget(
                  formKey: GlobalKey<FormBuilderState>(),
                  patientId: widget.definition.patientId ?? '',
                  initialContextId: record.contextId,
                  onSave: () {
                     // Update record logic would go here
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Detalles actualizados')),
                     );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocListener to sync initial load if needed, but for "Session" 
    // we might start empty or only show records from *this* session.
    // usage of BlocProvider here is to keep access to the bloc.
    return BlocProvider.value(
      value: sl<AbcRecordingBloc>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // HUD
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          widget.definition.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                         ),
                         const SizedBox(height: 4),
                         BlocBuilder<WorkflowBloc, WorkflowState>(
                           builder: (context, state) {
                              return Row(
                                children: [
                                  const Icon(Icons.place, size: 16, color: Colors.blueGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    state.context?.name ?? 'Sin Contexto',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              );
                           },
                         ),
                      ],
                    ),
                    SessionTimerWidget(startTime: _sessionStartTime),
                  ],
                ),
              ),
              
              // Active Zone
              Expanded(
                flex: 4,
                child: Center(
                  child: ActiveRecorderWidget(
                    type: RecordingType.event, // Dynamic later
                    label: widget.definition.operationalDefinition,
                    onLogEvent: _onLogEvent,
                  ),
                ),
              ),
              
              const Divider(height: 1),
              
              // Stream Zone
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Actividad Reciente',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_sessionRecords.length} eventos',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.grey[100],
                  child: EventStreamListWidget(
                    records: _sessionRecords,
                    onTap: _showDetailSheet,
                    onDelete: _onDeleteRecord,
                  ),
                ),
              ),
              
              // Footer Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                           // Cancel / Discard
                           WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) Navigator.pop(context);
                           });
                        },
                        child: const Text('Descartar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                           // Finish Session
                           final session = RecordingSession(
                             id: _uuid.v4(),
                             patientId: widget.definition.patientId ?? '',
                             startTime: _sessionStartTime,
                             endTime: DateTime.now(),
                             behaviorDefinitionId: widget.definition.id,
                             observerId: supabase.auth.currentUser?.id,
                           );

                           context.read<AbcRecordingBloc>().add(
                             SaveRecordingSession(session)
                           );

                           context.read<WorkflowBloc>().add(
                             WorkflowSessionCompleted(session)
                           );
                           WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) Navigator.pop(context);
                           });
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Finalizar Sesión'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
