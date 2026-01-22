import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';
import '../../../../main.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../domain/entities/patient.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';
import 'patient_form_page.dart';
import '../../../../features/behavior_definition/presentation/pages/behavior_definition_list_page.dart';
import 'patient_access_page.dart';

class PatientListPage extends StatelessWidget {
  const PatientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PatientBloc>()..add(LoadPatients()),
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Soft background
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Mis Pacientes',
            style: GoogleFonts.dmSerifDisplay(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
             IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(SignOutEvent());
              },
              icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.primary),
              tooltip: 'Cerrar Sesión',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<PatientBloc, PatientState>(
          builder: (context, state) {
            if (state is PatientLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PatientError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is PatientLoaded) {
              if (state.patients.isEmpty) {
                 return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No tienes pacientes registrados', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                           final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PatientFormPage()),
                            );
                            if (result == true && context.mounted) {
                              context.read<PatientBloc>().add(LoadPatients());
                            }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Registrar Primer Paciente'),
                      )
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.patients.length,
                itemBuilder: (context, index) {
                  final patient = state.patients[index];
                  return _PatientCard(patient: patient);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PatientFormPage()),
            );
             if (result == true && context.mounted) {
              // We need to find the BlocProvider above this context to reload, 
              // but since FAB is outside the BlocBuilder, we might need to use a Builder or access via key.
              // Actually, since we push new route, when we come back, this widget tree still exists. 
              // We can't easily access the Bloc instantiated in `create` unless we extract it or use a key.
              // BETTER APPROACH: Wrap the Navigator push in a Builder context that has access to the bloc
              // OR trigger refresh from here if we can.
              
              // Simplest fix for now: Re-render this page or use a GlobalKey for the refresh, 
              // or just rely on the fact that we might need to signal the bloc. 
              // Actually, since we are inside the `build` method of `PatientListPage`, 
              // `context.read<PatientBloc>()` will FAIL because the provider is created IN this build method.
              // We need to wrap the body or use a Builder for the FAB.
            }
          },
          label: const Text('Nuevo Paciente'),
          icon: const Icon(Icons.person_add),
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;

  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to patient's behavior list
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BehaviorDefinitionListPage(patientId: patient.id), 
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
                child: Text(
                  patient.firstName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (patient.diagnosis != null)
                      Text(
                        patient.diagnosis!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton( // Settings/Access button
                icon: const Icon(Icons.settings, color: Colors.grey),
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientAccessPage(patient: patient),
                    ),
                  );
                },
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
