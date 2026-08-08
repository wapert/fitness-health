import 'package:flutter/material.dart';
import '../../../core/models/muscle_group.dart';
import '../../../core/models/exercise.dart';
import '../data/exercises_data.dart';
import '../widgets/exercise_card.dart';

class TrainingHomeScreen extends StatefulWidget {
  const TrainingHomeScreen({super.key});

  @override
  State<TrainingHomeScreen> createState() => _TrainingHomeScreenState();
}

class _TrainingHomeScreenState extends State<TrainingHomeScreen> {
  MuscleGroup? _selected;

  List<Exercise> get _filtered => _selected == null
      ? strengthExercises
      : strengthExercises
          .where((e) => e.primaryMuscle == _selected || e.secondaryMuscles.contains(_selected))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('重訓 Weight Training')),
      body: Column(
        children: [
          _MuscleGroupFilter(
            selected: _selected,
            onSelect: (g) => setState(() => _selected = _selected == g ? null : g),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => ExerciseCard(
                key: ValueKey(_filtered[i].id),
                exercise: _filtered[i],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleGroupFilter extends StatelessWidget {
  const _MuscleGroupFilter({required this.selected, required this.onSelect});
  final MuscleGroup? selected;
  final ValueChanged<MuscleGroup> onSelect;

  // Only the groups relevant to weight training tab
  static const _groups = [
    MuscleGroup.chest,
    MuscleGroup.back,
    MuscleGroup.glutes,
    MuscleGroup.quads,
    MuscleGroup.hamstrings,
    MuscleGroup.calves,
    MuscleGroup.biceps,
    MuscleGroup.triceps,
    MuscleGroup.core,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: _groups.map((g) {
          final active = selected == g;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(g.label),
              selected: active,
              onSelected: (_) => onSelect(g),
              backgroundColor: scheme.surface,
              selectedColor: scheme.primaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }
}
