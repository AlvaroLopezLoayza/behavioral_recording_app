import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/abc_record.dart';
import '../../domain/entities/recording_session.dart';
import '../../domain/repositories/abc_recording_repository.dart';
import '../widgets/event_stream_list_widget.dart';

class SessionDetailPage extends StatefulWidget {
  final RecordingSession session;

  const SessionDetailPage({super.key, required this.session});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  late Future<List<AbcRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    _recordsFuture = GetIt.I<AbcRecordingRepository>()
        .getRecordsBySession(widget.session.id)
        .then((result) => result.fold(
              (failure) => throw Exception(failure.message),
              (records) => records,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Sesión'),
      ),
      body: Column(
        children: [
          _buildSessionInfo(),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<AbcRecord>>(
              future: _recordsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay registros en esta sesión.'));
                }

                return EventStreamListWidget(
                  records: snapshot.data!,
                  // Future: add onTap to view details
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy').format(widget.session.startTime)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Iniciada: ${DateFormat('HH:mm').format(widget.session.startTime)}',
          ),
          if (widget.session.endTime != null)
            Text(
              'Finalizada: ${DateFormat('HH:mm').format(widget.session.endTime!)}',
            ),
        ],
      ),
    );
  }
}
