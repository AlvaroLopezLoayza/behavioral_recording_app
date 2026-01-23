import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../abc_recording/presentation/pages/recording_session_page.dart';
import '../../../abc_recording/presentation/pages/session_history_page.dart';
import '../../../analysis/presentation/pages/analysis_page.dart';
// Workflow Pages
import '../../../behavior_definition/presentation/pages/behavior_definition_list_page.dart';
import '../../../context/presentation/pages/context_list_page.dart';
import '../../../workflow/presentation/bloc/workflow_bloc.dart';
import '../../../workflow/presentation/bloc/workflow_event.dart';
import '../../../workflow/presentation/bloc/workflow_state.dart';
import '../../domain/entities/patient.dart';
import 'patient_form_page.dart';

class PatientWorkflowDashboard extends StatefulWidget {
  final Patient patient;

  const PatientWorkflowDashboard({super.key, required this.patient});

  @override
  State<PatientWorkflowDashboard> createState() => _PatientWorkflowDashboardState();
}

class _PatientWorkflowDashboardState extends State<PatientWorkflowDashboard> {
  @override
  void initState() {
    super.initState();
    // Initialize workflow for this patient
    context.read<WorkflowBloc>().add(WorkflowPatientSelected(widget.patient));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<WorkflowBloc, WorkflowState>(
        listener: (context, state) {
          // Listen for navigation triggers if needed, but for now we'll drive it from UI buttons
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _buildCurrentStepCard(context, state),
                    const SizedBox(height: 24),
                    Text(
                      'Gestión y Datos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyMenu(context),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.patient.firstName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient.fullName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.patient.diagnosis != null)
                              Text(
                                widget.patient.diagnosis!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepCard(BuildContext context, WorkflowState state) {
    String title;
    String description;
    String buttonText;
    IconData icon;
    VoidCallback onTap;
    Color color = Theme.of(context).colorScheme.primary;

    switch (state.currentStep) {
      case WorkflowStep.patientSelection:
      case WorkflowStep.behaviorSelection:
        title = 'Paso 1: Definir Conducta';
        description = 'Selecciona o crea la definición operacional de la conducta a observar.';
        buttonText = 'Seleccionar Conducta';
        icon = Icons.psychology;
        onTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BehaviorDefinitionListPage(
                patientId: widget.patient.id,
                mode: BehaviorListMode.recording, // This mode selects and fires event
              ),
            ),
          );
        };
        break;
      case WorkflowStep.contextSelection:
        title = 'Paso 2: Contexto';
        description = 'Define el entorno donde ocurrirá la observación (Lugar, actividad, personas).';
        buttonText = 'Seleccionar Contexto';
        icon = Icons.place;
        color = Colors.orange;
        onTap = () {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContextListPage(patientId: widget.patient.id),
            ),
          );
        };
        break;
      case WorkflowStep.recording:
        title = 'Paso 3: Registro ABC';
        description = 'Realiza la observación directa registrando Antecedentes, Conductas y Consecuencias.';
        buttonText = 'Comenzar Registro';
        icon = Icons.play_circle_fill;
        color = Colors.green;
        onTap = () {
           if (state.behavior != null) { // Gate check
             // Ensure keyboard is dismissed before navigating
             FocusScope.of(context).unfocus();
             
             Navigator.push(
              context,
              MaterialPageRoute(
                // We pass the definition but the bloc holds the state too
                builder: (context) => RecordingSessionPage(
                  definition: state.behavior!,
                ),
              ),
            );
           }
        };
        break;
      case WorkflowStep.analysis:
        title = 'Paso 4: Análisis';
        description = 'Revisa los datos recolectados, visualiza tendencias y patrones condicionales.';
        buttonText = 'Ver Análisis';
        icon = Icons.analytics;
        color = Colors.purple;
        onTap = () {
           if (state.behavior != null) {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnalysisPage(definition: state.behavior!),
              ),
            );
           }
        };
        break;
      default:
        title = 'Flujo Completado';
        description = 'Ciclo finalizado.';
        buttonText = 'Reiniciar';
        icon = Icons.check_circle;
        onTap = () {
           context.read<WorkflowBloc>().add(WorkflowPatientSelected(widget.patient));
        };
    }

    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acción Requerida',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
            if (state.behavior != null && state.currentStep.index > 1) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Conducta: ${state.behavior?.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
             if (state.context != null && state.currentStep.index > 2) ...[
              const SizedBox(height: 8),
               Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Contexto: ${state.context?.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
             ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuOption(
          context,
          title: 'Definiciones de Conducta',
          subtitle: 'Gestionar catálogo de conductas',
          icon: Icons.list_alt,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BehaviorDefinitionListPage(
                  patientId: widget.patient.id,
                  mode: BehaviorListMode.management,
                ),
              ),
            );
          },
        ),
        _buildMenuOption(
          context,
          title: 'Historial de Sesiones',
          subtitle: 'Ver registros anteriores',
          icon: Icons.history,
          onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => SessionHistoryPage(
                   patientId: widget.patient.id,
                 ),
               ),
             );
          },
        ),
        _buildMenuOption(
            context,
            title: 'Configuración del Paciente',
            subtitle: 'Editar datos personales',
            icon: Icons.settings_outlined,
            onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientFormPage(
                      patient: widget.patient,
                    ),
                  ),
                );
            },
        ),
      ],
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.grey[700]),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
