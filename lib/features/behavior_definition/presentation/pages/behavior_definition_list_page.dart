import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/behavior_definition_bloc.dart';
import '../bloc/behavior_definition_event.dart';
import '../bloc/behavior_definition_state.dart';
import '../../../../features/abc_recording/presentation/pages/recording_session_page.dart';
import '../../../../features/analysis/presentation/pages/analysis_page.dart';
import 'behavior_definition_form_page.dart';

class BehaviorDefinitionListPage extends StatelessWidget {
  const BehaviorDefinitionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BehaviorDefinitionBloc>()..add(LoadBehaviorDefinitions()),
      child: Scaffold(
        body: BlocBuilder<BehaviorDefinitionBloc, BehaviorDefinitionState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: true,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Comportamientos',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
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
                              child: _BehaviorCard(definition: definition),
                            );
                          },
                          childCount: state.definitions.length,
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BehaviorDefinitionFormPage(),
                  ),
                );
                
                if (result == true && context.mounted) {
                  context.read<BehaviorDefinitionBloc>().add(LoadBehaviorDefinitions());
                }
              },
              label: const Text('Nuevo'),
              icon: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

class _BehaviorCard extends StatelessWidget {
  final dynamic definition; // Typing as dynamic to simplify for now, should be BehaviorDefinition

  const _BehaviorCard({required this.definition});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordingSessionPage(
                definition: definition,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      definition.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary.withAlpha(100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Event', // Placeholder for recording type
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                definition.operationalDefinition,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.visibility_outlined, 
                    size: 16, 
                    color: Theme.of(context).colorScheme.primary.withAlpha(150)
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Observable',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary.withAlpha(150),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.secondary),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
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
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('View Analysis'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.tertiary,
                    side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
