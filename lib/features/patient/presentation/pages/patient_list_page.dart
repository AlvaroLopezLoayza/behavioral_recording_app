import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../features/behavior_definition/presentation/pages/behavior_definition_list_page.dart';
import '../../../../features/patient/presentation/pages/patient_workflow_dashboard.dart';
import '../../../../injection_container.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../domain/entities/patient.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';
import 'patient_access_page.dart';
import 'patient_form_page.dart';

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
            style: Theme.of(context).textTheme.displaySmall,
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
              
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PatientBloc>().add(LoadPatients());
                  // Wait a bit for the bloc to process
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.patients.length,
                  itemBuilder: (context, index) {
                    final patient = state.patients[index];
                    return _PatientCard(patient: patient);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
          builder: (builderContext) => FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PatientFormPage()),
              );
              if (result == true && builderContext.mounted) {
                builderContext.read<PatientBloc>().add(LoadPatients());
              }
            },
            label: const Text('Nuevo Paciente'),
            icon: const Icon(Icons.person_add),
          ),
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 1, // Subtler shadow
        shadowColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            // Navigate to patient's workflow dashboard
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientWorkflowDashboard(patient: patient), 
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Hero(
                  tag: 'avatar_${patient.id}',
                  child: CircleAvatar(
                    radius: 28, // Slightly larger
                    backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
                    child: Text(
                      patient.firstName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
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
      ),
    );
  }
}

