import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/recording_session.dart';
import '../../domain/repositories/abc_recording_repository.dart';
import 'session_detail_page.dart';

class SessionHistoryPage extends StatefulWidget {
  final String patientId;

  const SessionHistoryPage({super.key, required this.patientId});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  late Future<List<RecordingSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsFuture = GetIt.I<AbcRecordingRepository>()
        .getSessionsByPatient(widget.patientId)
        .then((result) => result.fold(
              (failure) => throw Exception(failure.message),
              (sessions) => sessions,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Sesiones'),
      ),
      body: FutureBuilder<List<RecordingSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadSessions();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay sesiones registradas.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.history_edu),
                  ),
                  title: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(session.startTime),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    session.endTime != null
                        ? 'Duración: ${_formatDuration(session.endTime!.difference(session.startTime))}'
                        : 'En curso',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to session details/recording page implementation
                    // For now, we reuse RecordingSessionPage but in read-only mode if implemented,
                    // or just open it to view records.
                    // Assuming RecordingSessionPage takes session ID.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionDetailPage(
                          session: session,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }
}
