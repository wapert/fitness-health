import 'package:flutter/material.dart';
import '../../../core/models/muscle_group.dart';
import '../../../core/models/exercise.dart';
import '../data/stretches_data.dart';
import '../../training/widgets/exercise_card.dart';

class StretchingHomeScreen extends StatefulWidget {
  const StretchingHomeScreen({super.key});

  @override
  State<StretchingHomeScreen> createState() => _StretchingHomeScreenState();
}

class _StretchingHomeScreenState extends State<StretchingHomeScreen> {
  MuscleGroup? _selected;

  List<Exercise> get _filtered => _selected == null
      ? stretchingExercises
      : stretchingExercises.where((e) => e.primaryMuscle == _selected).toList();

  static const _groups = [
    MuscleGroup.chest,
    MuscleGroup.back,
    MuscleGroup.glutes,
    MuscleGroup.quads,
    MuscleGroup.hamstrings,
    MuscleGroup.calves,
    MuscleGroup.biceps,
    MuscleGroup.triceps,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('伸展 Stretching'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _groups.map((g) {
                final active = _selected == g;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(g.label),
                    selected: active,
                    onSelected: (_) => setState(() => _selected = active ? null : g),
                    selectedColor: scheme.secondaryContainer,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('此肌群暫無伸展動作'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => ExerciseCard(exercise: _filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
