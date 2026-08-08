import 'package:flutter/material.dart';
import '../../../core/models/muscle_group.dart';
import '../../../core/models/exercise.dart';
import '../../training/data/exercises_data.dart';
import '../../stretching/data/stretches_data.dart';
import '../../training/widgets/exercise_card.dart';
import '../widgets/muscle_map.dart';

class BodyMapScreen extends StatefulWidget {
  const BodyMapScreen({super.key});

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen>
    with SingleTickerProviderStateMixin {
  MuscleGroup? _selected;
  bool _front = true;
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
    final src = type == ExerciseType.strength
        ? strengthExercises
        : stretchingExercises;
    if (_selected == null) return src;
    return src.where((e) => e.primaryMuscle == _selected).toList();
  }

  /// Selecting from the chip row also switches the diagram to whichever
  /// side (front/back) actually shows that muscle group.
  void _selectFromChip(MuscleGroup g) {
    setState(() {
      final wasSelected = _selected == g;
      _selected = wasSelected ? null : g;
      if (!wasSelected) {
        _front = muscleGroupIsFront[g] ?? _front;
      }
    });
  }

  /// Selecting by tapping the diagram itself: whatever was tapped is, by
  /// definition, already on the currently-shown side, so the side never
  /// needs to change here.
  void _selectFromDiagram(MuscleGroup g) =>
      setState(() => _selected = _selected == g ? null : g);

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
          // ── Interactive anatomy diagram ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: MuscleMap(
              front: _front,
              onFrontChanged: (f) => setState(() => _front = f),
              selected: _selected,
              onSelect: _selectFromDiagram,
            ),
          ),

          // ── Compact chip selector (precise picks) ──────────────────
          _ChipSelector(selected: _selected, onSelect: _selectFromChip),
          const Divider(height: 1),

          // ── Exercises for the selected muscle ──────────────────────
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

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({required this.selected, required this.onSelect});
  final MuscleGroup? selected;
  final ValueChanged<MuscleGroup> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: MuscleGroup.values.map((g) {
          final active = selected == g;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: active
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? scheme.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  g.label,
                  style: TextStyle(
                    color: active
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('此肌群尚無對應動作，試試其他肌群 💪',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: exercises.length,
      itemBuilder: (_, i) => ExerciseCard(
        key: ValueKey(exercises[i].id),
        exercise: exercises[i],
      ),
    );
  }
}
