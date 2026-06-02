import 'package:flutter/material.dart';
import '../../../core/models/muscle_group.dart';
import '../../../core/models/exercise.dart';
import '../../training/data/exercises_data.dart';
import '../../stretching/data/stretches_data.dart';

class BodyMapScreen extends StatefulWidget {
  const BodyMapScreen({super.key});

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen>
    with SingleTickerProviderStateMixin {
  MuscleGroup? _selected;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Exercise> _exercises(ExerciseType type) {
    final src = type == ExerciseType.strength ? strengthExercises : stretchingExercises;
    if (_selected == null) return src;
    return src.where((e) => e.primaryMuscle == _selected).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('肌群地圖 Body Map'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '重訓'), Tab(text: '伸展')],
        ),
      ),
      body: Column(
        children: [
          // Simplified body-map grid (placeholder until SVG asset added)
          _BodyMapGrid(
            selected: _selected,
            onSelect: (g) => setState(() => _selected = _selected == g ? null : g),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ExerciseList(exercises: _exercises(ExerciseType.strength)),
                _ExerciseList(exercises: _exercises(ExerciseType.stretch)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyMapGrid extends StatelessWidget {
  const _BodyMapGrid({required this.selected, required this.onSelect});
  final MuscleGroup? selected;
  final ValueChanged<MuscleGroup> onSelect;

  static const _groups = [
    (group: MuscleGroup.chest,      icon: Icons.airline_seat_flat),
    (group: MuscleGroup.back,       icon: Icons.arrow_back),
    (group: MuscleGroup.shoulders,  icon: Icons.expand_less),
    (group: MuscleGroup.biceps,     icon: Icons.fitness_center),
    (group: MuscleGroup.triceps,    icon: Icons.fitness_center),
    (group: MuscleGroup.core,       icon: Icons.crop_square),
    (group: MuscleGroup.glutes,     icon: Icons.airline_seat_recline_normal),
    (group: MuscleGroup.quads,      icon: Icons.directions_walk),
    (group: MuscleGroup.hamstrings, icon: Icons.directions_walk),
    (group: MuscleGroup.calves,     icon: Icons.directions_run),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _groups.map((item) {
          final active = selected == item.group;
          return GestureDetector(
            onTap: () => onSelect(item.group),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: active ? scheme.primaryContainer : scheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? scheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 16,
                      color: active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    item.group.label,
                    style: TextStyle(
                      color: active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  const _ExerciseList({required this.exercises});
  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return const Center(child: Text('請從上方選擇肌群'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: exercises.length,
      itemBuilder: (_, i) {
        final e = exercises[i];
        return ListTile(
          leading: const Icon(Icons.play_circle_outline),
          title: Text(e.nameChinese),
          subtitle: Text(e.name),
          trailing: e.holdSeconds != null
              ? Text('${e.holdSeconds}秒')
              : Text('${e.sets}組×${e.reps}'),
        );
      },
    );
  }
}
