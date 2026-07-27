import 'package:flutter/material.dart';
import '../../../core/models/exercise.dart';
import '../services/exercise_schedule_service.dart';

/// Shows a bottom sheet to add/remove [exercise] on each weekday of the
/// recurring weekly schedule.
Future<void> showAddToScheduleSheet(
    BuildContext context, Exercise exercise) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddToScheduleSheet(exercise: exercise),
  );
}

const _weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];

class _AddToScheduleSheet extends StatefulWidget {
  const _AddToScheduleSheet({required this.exercise});
  final Exercise exercise;

  @override
  State<_AddToScheduleSheet> createState() => _AddToScheduleSheetState();
}

class _AddToScheduleSheetState extends State<_AddToScheduleSheet> {
  final _service = ExerciseScheduleService();
  Map<int, List<String>> _schedule = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _service.load();
    if (mounted) {
      setState(() {
        _schedule = s;
        _loaded = true;
      });
    }
  }

  bool _isOn(int weekday) =>
      _schedule[weekday]?.contains(widget.exercise.id) ?? false;

  Future<void> _toggle(int weekday) async {
    final next =
        await _service.toggle(_schedule, weekday, widget.exercise.id);
    if (mounted) setState(() => _schedule = next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = widget.exercise;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Text(e.primaryMuscle.label[0],
                    style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.nameChinese,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('加入每週計畫',
                        style: TextStyle(
                            fontSize: 13, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('選擇要練習的日子（可多選）',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),

          if (!_loaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final weekday = i + 1;
                final on = _isOn(weekday);
                return GestureDetector(
                  onTap: () => _toggle(weekday),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 40, height: 52,
                    decoration: BoxDecoration(
                      color: on ? scheme.primary : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: on ? scheme.primary : scheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('週', style: TextStyle(
                            fontSize: 10,
                            color: on ? Colors.white70 : scheme.onSurfaceVariant)),
                        Text(_weekdayLabels[i],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: on ? Colors.white : scheme.onSurface,
                            )),
                        if (on)
                          const Icon(Icons.check, size: 12, color: Colors.white70)
                        else
                          const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              }),
            ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('完成'),
            ),
          ),
        ],
      ),
    );
  }
}
