import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/abc_recording/presentation/pages/recording_session_page.dart';
import '../../../../features/analysis/presentation/pages/analysis_page.dart';
import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../../features/authentication/presentation/bloc/auth_event.dart';
import '../../../../features/patient/domain/usecases/get_patient_by_id.dart';
import '../../../../features/reliability/presentation/pages/reliability_page.dart';
import '../../../../injection_container.dart';
import '../../../workflow/presentation/bloc/workflow_bloc.dart';
import '../../../workflow/presentation/bloc/workflow_event.dart';
import '../bloc/behavior_definition_bloc.dart';
import '../bloc/behavior_definition_event.dart';
import '../bloc/behavior_definition_state.dart';
import 'behavior_definition_form_page.dart';

enum BehaviorListMode {
  management, // Edit definitions
  recording,  // Select for recording
  analysis    // Select for analysis
}

class BehaviorDefinitionListPage extends StatelessWidget {
  final String? patientId;
  final BehaviorListMode mode;
  
  const BehaviorDefinitionListPage({
    super.key, 
    this.patientId,
    this.mode = BehaviorListMode.management,
  });

  String get _title {
    switch (mode) {
      case BehaviorListMode.management:
        return 'Paso 2: Comportamientos';
      case BehaviorListMode.recording:
        return 'Seleccionar para Registrar';
      case BehaviorListMode.analysis:
        return 'Seleccionar para Analizar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BehaviorDefinitionBloc>()..add(LoadBehaviorDefinitions(patientId: patientId)),
      child: Scaffold(
        body: BlocBuilder<BehaviorDefinitionBloc, BehaviorDefinitionState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BehaviorDefinitionBloc>().add(LoadBehaviorDefinitions(patientId: patientId));
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120.0,
                    floating: true,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        _title,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                           color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.sort_rounded),
                          tooltip: 'Ordenar'),
                      if (patientId != null && mode == BehaviorListMode.management)
                        IconButton(
                          onPressed: () async {
                            final getPatient = sl<GetPatientById>();
                            final result = await getPatient(patientId!);
                            result.fold(
                              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(failure.message)),
                              ),
                              (patient) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReliabilityPage(patient: patient),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.handshake_outlined),
                          tooltip: 'Fiabilidad / IOA',
                        ),
                      IconButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(SignOutEvent());
                          },
                          icon: const Icon(Icons.logout_rounded),
                          tooltip: 'Cerrar Sesión'),
                      const SizedBox(width: 8),
                    ],
                  ),
                  if (state is BehaviorDefinitionLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state is BehaviorDefinitionError)
                    SliverFillRemaining(
                      child: Center(child: Text('Error: ${state.message}')),
                    )
                  else if (state is BehaviorDefinitionLoaded)
                    if (state.definitions.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.spa_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No hay comportamientos', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final definition = state.definitions[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _BehaviorCard(
                                  definition: definition,
                                  mode: mode,
                                  patientId: patientId,
                                ),
                              );
                            },
                            childCount: state.definitions.length,
                          ),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: mode == BehaviorListMode.management 
          ? Builder(
              builder: (context) {
                return FloatingActionButton.extended(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BehaviorDefinitionFormPage(patientId: patientId),
                      ),
                    );
                    
                    if (result == true && context.mounted) {
                      context.read<BehaviorDefinitionBloc>().add(LoadBehaviorDefinitions(patientId: patientId));
                    }
                  },
                  label: const Text('Nuevo'),
                  icon: const Icon(Icons.add),
                );
              },
            )
          : null,
      ),
    );
  }
}

class _BehaviorCard extends StatelessWidget {
  final dynamic definition; // Typing as dynamic to simplify for now, should be BehaviorDefinition
  final BehaviorListMode mode;
  final String? patientId;

  const _BehaviorCard({
    required this.definition,
    required this.mode,
    this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    // Determine recording type color for the tag
    final typeColor = Theme.of(context).colorScheme.tertiary;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.withAlpha(30)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Dismiss keyboard if active
            FocusScope.of(context).unfocus();
            
            if (mode == BehaviorListMode.management) {
               // Management mode: View details / Edit (Future impl)
               // For now, same as Recording session just to have navigation
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordingSessionPage(
                    definition: definition,
                    patientId: definition.patientId ?? patientId ?? '',
                  ),
                ),
              );
            } else if (mode == BehaviorListMode.recording) {
              // Workflow Selection
              context.read<WorkflowBloc>().add(
                WorkflowBehaviorSelected(definition)
              );
              // Delay pop to ensure clean unmounting and state propagation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) Navigator.pop(context);
              });
            } else if (mode == BehaviorListMode.analysis) {
               // Direct navigation to analysis
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalysisPage(
                    definition: definition,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'behavior_name_${definition.id}',
                        child: Text(
                          definition.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: typeColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'Evento', // Placeholder for recording type
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  definition.operationalDefinition,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.withAlpha(30)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFeatureTag(
                      context, 
                      Icons.visibility_outlined, 
                      'Observable',
                      Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildFeatureTag(
                      context, 
                      Icons.straighten_outlined, 
                      'Medible',
                      Theme.of(context).colorScheme.secondary,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getActionIconForMode(mode), 
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                if (mode == BehaviorListMode.management) ...[
                   const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnalysisPage(
                                definition: definition,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics_rounded, size: 20),
                        label: const Text('Análisis Longitudinal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.tertiary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Theme.of(context).colorScheme.tertiary.withAlpha(100)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getActionIconForMode(BehaviorListMode mode) {
    switch (mode) {
      case BehaviorListMode.management:
        return Icons.edit_outlined;
      case BehaviorListMode.recording:
        return Icons.play_arrow_rounded;
      case BehaviorListMode.analysis:
        return Icons.analytics_outlined;
    }
  }

  Widget _buildFeatureTag(BuildContext context, IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withAlpha(200)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withAlpha(200),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
