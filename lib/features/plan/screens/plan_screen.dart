import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/models/training_plan.dart';
import '../../../core/models/exercise.dart';
import '../data/exercise_lookup.dart';
import '../services/plan_service.dart';
import '../services/exercise_schedule_service.dart';
import '../widgets/activity_count_row.dart';
import '../widgets/week_preview.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _service = PlanService();
  final _scheduleService = ExerciseScheduleService();

  WeeklyPlanConfig _config = WeeklyPlanConfig(
    trainingDays: 3,
    stretchingDays: 2,
    joggingDays: 0,
    fastingDays: 1,
    startDate: DateTime.now(),
  );

  Map<String, CompletedDay> _completed = {};
  Map<int, PlanActivity> _editableTemplate = {}; // user-edited week template
  Map<int, List<String>> _exerciseSchedule = {}; // weekday → exerciseIds
  Map<String, Set<String>> _completedExercises =
      {}; // dateKey → done exerciseIds
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loaded = false;
  bool _showSetup = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cfg = await _service.loadConfig();
    final done = await _service.loadCompleted();
    final sched = await _scheduleService.load();
    final exDone = await _scheduleService.loadCompletedExercises();
    if (!mounted) return;
    setState(() {
      if (cfg != null) _config = cfg;
      _editableTemplate = (cfg ?? _config).effectiveTemplate;
      _completed = done;
      _exerciseSchedule = sched;
      _completedExercises = exDone;
      _loaded = true;
      _showSetup = cfg == null; // first launch → show setup
    });
  }

  List<Exercise> _exercisesForWeekday(int weekday) =>
      (_exerciseSchedule[weekday] ?? const [])
          .map(exerciseById)
          .whereType<Exercise>()
          .toList();

  int _exerciseCountFor(DateTime d) =>
      _exerciseSchedule[d.weekday]?.length ?? 0;

  /// How many of the day's scheduled exercises are marked done on this date.
  int _exerciseDoneCountFor(DateTime d) {
    final done = _completedExercises[CompletedDay.keyFor(d)];
    if (done == null) return 0;
    final scheduled = _exerciseSchedule[d.weekday] ?? const [];
    return scheduled.where(done.contains).length;
  }

  bool _isExerciseDone(DateTime d, String id) =>
      _completedExercises[CompletedDay.keyFor(d)]?.contains(id) ?? false;

  Future<void> _toggleExerciseDone(DateTime d, String id) async {
    final next = await _scheduleService.toggleExerciseDone(
        _completedExercises, CompletedDay.keyFor(d), id);
    setState(() => _completedExercises = next);
  }

  Future<void> _removeScheduledExercise(int weekday, String exerciseId) async {
    final next =
        await _scheduleService.toggle(_exerciseSchedule, weekday, exerciseId);
    setState(() => _exerciseSchedule = next);
  }

  Future<void> _saveConfig() async {
    // Persist the drag-drop template overrides together with the config
    final saved = _config.copyWith(customTemplate: _editableTemplate);
    await _service.saveConfig(saved);
    setState(() {
      _config = saved;
      _showSetup = false;
    });
  }

  // ── Event helpers ────────────────────────────────────────────────────────

  PlanActivity? _activityFor(DateTime day) => _editableTemplate[day.weekday];

  List<PlanActivity> _eventsForDay(DateTime day) {
    final a = _activityFor(day);
    return a != null ? [a] : [];
  }

  bool _isDone(DateTime day) =>
      _completed.containsKey(CompletedDay.keyFor(day));

  int get _completedThisWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      if (_isDone(d)) count++;
    }
    return count;
  }

  // ── Toggle completion ────────────────────────────────────────────────────

  Future<void> _toggleDay(DateTime day, PlanActivity activity) async {
    final wasDone = _isDone(day);
    await _service.toggleCompleted(day, activity, !wasDone, _completed);
    final done = await _service.loadCompleted();
    setState(() => _completed = done);
  }

  // ── Day detail bottom sheet ───────────────────────────────────────────────

  void _showDayDetail(DateTime day) {
    final activity = _activityFor(day);
    final scheduled = _exercisesForWeekday(day.weekday);

    // Nothing to show → brief rest-day toast.
    if (activity == null && !_isDone(day) && scheduled.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_dateLabel(day)} — 休息日 😴'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    final hasActivity = activity != null;
    final eff = activity ?? PlanActivity.training;
    final color = hasActivity ? Color(eff.colorValue) : Colors.blueGrey;
    final done = _isDone(day);
    final headerEmoji = hasActivity ? eff.emoji : '📋';
    final headerLabel = hasActivity ? eff.label : '自訂練習';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          final dayExercises = _exercisesForWeekday(day.weekday);
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(80),
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withAlpha(40),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(headerEmoji,
                              style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_dateLabel(day),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(headerLabel,
                                style: TextStyle(color: color, fontSize: 14)),
                          ],
                        ),
                      ),
                      if (done)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: Colors.green),
                              SizedBox(width: 4),
                              Text('完成', style: TextStyle(color: Colors.green)),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // ── Scheduled exercises ──────────────────────────────
                  if (dayExercises.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Builder(builder: (_) {
                      final doneCount = dayExercises
                          .where((e) => _isExerciseDone(day, e.id))
                          .length;
                      return Row(
                        children: [
                          const Icon(Icons.fitness_center, size: 16),
                          const SizedBox(width: 6),
                          Text('本日動作 ($doneCount/${dayExercises.length})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const Spacer(),
                          if (doneCount == dayExercises.length)
                            const Text('全部完成 ✓',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.green)),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                    ...dayExercises.map((e) {
                      final exDone = _isExerciseDone(day, e.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          dense: true,
                          leading: Checkbox(
                            value: exDone,
                            onChanged: (_) async {
                              await _toggleExerciseDone(day, e.id);
                              setSheetState(() {});
                            },
                          ),
                          title: Text(
                            e.nameChinese,
                            style: TextStyle(
                              fontSize: 14,
                              decoration:
                                  exDone ? TextDecoration.lineThrough : null,
                              color: exDone ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Text(
                            '${e.primaryMuscle.label} · '
                            '${e.type == ExerciseType.stretch ? '伸展' : '重訓'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: '移除',
                            onPressed: () async {
                              await _removeScheduledExercise(day.weekday, e.id);
                              setSheetState(() {});
                            },
                          ),
                        ),
                      );
                    }),
                  ],

                  // ── Complete toggle (only for planned activities) ────
                  if (hasActivity) ...[
                    const SizedBox(height: 20),
                    done
                        ? OutlinedButton.icon(
                            onPressed: () {
                              _toggleDay(day, eff);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.undo),
                            label: const Text('取消完成'),
                          )
                        : FilledButton.icon(
                            onPressed: () {
                              _toggleDay(day, eff);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('標記為完成 ✓'),
                            style: FilledButton.styleFrom(
                              backgroundColor: color,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _dateLabel(DateTime d) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '${d.month} 月 ${d.day} 日（週${weekdays[d.weekday - 1]}）';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('訓練計畫'),
        leading: _showSetup
            ? IconButton(
                icon: const Icon(Icons.calendar_today),
                tooltip: '查看日曆',
                onPressed: () => setState(() => _showSetup = false),
              )
            : null,
      ),
      body: _showSetup ? _buildSetup() : _buildCalendar(),
    );
  }

  // ── Setup panel ───────────────────────────────────────────────────────────

  Widget _buildSetup() {
    final template = _editableTemplate;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('設定每週訓練計畫',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 4),
          const Text('選擇每項活動每週進行幾次，系統自動安排在最佳日期',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ActivityCountRow(
                    activity: PlanActivity.training,
                    count: _config.trainingDays,
                    onChanged: (v) => setState(() {
                      _config = _config.copyWith(
                          trainingDays: v, customTemplate: null);
                      _editableTemplate = _config.weekTemplate;
                    }),
                  ),
                  const Divider(height: 20),
                  ActivityCountRow(
                    activity: PlanActivity.stretching,
                    count: _config.stretchingDays,
                    onChanged: (v) => setState(() {
                      _config = _config.copyWith(
                          stretchingDays: v, customTemplate: null);
                      _editableTemplate = _config.weekTemplate;
                    }),
                  ),
                  const Divider(height: 20),
                  ActivityCountRow(
                    activity: PlanActivity.jogging,
                    count: _config.joggingDays,
                    onChanged: (v) => setState(() {
                      _config = _config.copyWith(
                          joggingDays: v, customTemplate: null);
                      _editableTemplate = _config.weekTemplate;
                    }),
                  ),
                  const Divider(height: 20),
                  ActivityCountRow(
                    activity: PlanActivity.fasting,
                    count: _config.fastingDays,
                    onChanged: (v) => setState(() {
                      _config = _config.copyWith(
                          fastingDays: v, customTemplate: null);
                      _editableTemplate = _config.weekTemplate;
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text('每週預覽',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: WeekPreview(
                template: template,
                onTemplateChanged: (updated) =>
                    setState(() => _editableTemplate = updated),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.drag_indicator, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text('長按活動圖示可拖曳到其他日期',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 20),
          // Summary chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PlanActivity.values
                .where((a) => a != PlanActivity.rest)
                .map((a) {
              final count = switch (a) {
                PlanActivity.training => _config.trainingDays,
                PlanActivity.stretching => _config.stretchingDays,
                PlanActivity.jogging => _config.joggingDays,
                PlanActivity.fasting => _config.fastingDays,
                _ => 0,
              };
              if (count == 0) return const SizedBox.shrink();
              return Chip(
                avatar: Text(a.emoji),
                label: Text('${a.label} $count 次/週'),
                backgroundColor: Color(a.colorValue).withAlpha(30),
                side: BorderSide(color: Color(a.colorValue).withAlpha(80)),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _config.totalActiveDays > 0 ? _saveConfig : null,
              icon: const Icon(Icons.calendar_month),
              label: const Text('儲存並查看日曆'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Calendar panel ─────────────────────────────────────────────────────────

  Widget _buildCalendar() {
    final template = _editableTemplate;
    final scheme = Theme.of(context).colorScheme;
    final thisWeekTotal = _config.totalActiveDays;
    final thisWeekDone = _completedThisWeek;

    return Column(
      children: [
        // Weekly progress bar
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withAlpha(60),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('本週進度',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: scheme.primary)),
                  const Spacer(),
                  Text('$thisWeekDone / $thisWeekTotal',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: scheme.primary)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: thisWeekTotal == 0 ? 0 : thisWeekDone / thisWeekTotal,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: thisWeekDone >= thisWeekTotal
                      ? Colors.green
                      : scheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              WeekPreview(template: template),
              const SizedBox(height: 10),
              // Edit plan button — inside the card, always tappable
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showSetup = true),
                  icon: const Icon(Icons.edit_calendar, size: 16),
                  label: const Text('編輯計畫'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Colour legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...PlanActivity.values
                  .where((a) => a != PlanActivity.rest)
                  .map((a) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(a.colorValue),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(a.label,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      )),
              // Custom-exercise badge legend
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: _exerciseBadgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('N',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              height: 1)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('動作',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Calendar
        Expanded(
          child: SingleChildScrollView(
            child: TableCalendar<PlanActivity>(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2027, 12, 31),
              focusedDay: _focusedDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              rowHeight: 48, // compact rows so the month fits
              daysOfWeekHeight: 28,
              selectedDayPredicate: (d) =>
                  _selectedDay != null && isSameDay(_selectedDay!, d),
              eventLoader: _eventsForDay,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
                _showDayDetail(selected);
              },
              onPageChanged: (f) => setState(() => _focusedDay = f),

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              calendarStyle: const CalendarStyle(
                // disable default decorations — our builder handles everything
                todayDecoration: BoxDecoration(),
                selectedDecoration: BoxDecoration(),
                defaultDecoration: BoxDecoration(),
                weekendDecoration: BoxDecoration(),
                outsideDecoration: BoxDecoration(),
                markersMaxCount: 0,
              ),

              calendarBuilders: CalendarBuilders(
                markerBuilder: (_, __, ___) => const SizedBox.shrink(),
                defaultBuilder: (_, date, __) => _DayCell(
                  date: date,
                  activity: _activityFor(date),
                  done: _isDone(date),
                  isToday: false,
                  isSelected:
                      _selectedDay != null && isSameDay(_selectedDay!, date),
                  isOutside: false,
                  exerciseCount: _exerciseCountFor(date),
                  exerciseDoneCount: _exerciseDoneCountFor(date),
                ),
                todayBuilder: (_, date, __) => _DayCell(
                  date: date,
                  activity: _activityFor(date),
                  done: _isDone(date),
                  isToday: true,
                  isSelected:
                      _selectedDay != null && isSameDay(_selectedDay!, date),
                  isOutside: false,
                  exerciseCount: _exerciseCountFor(date),
                  exerciseDoneCount: _exerciseDoneCountFor(date),
                ),
                selectedBuilder: (_, date, __) => _DayCell(
                  date: date,
                  activity: _activityFor(date),
                  done: _isDone(date),
                  isToday: isSameDay(date, DateTime.now()),
                  isSelected: true,
                  isOutside: false,
                  exerciseCount: _exerciseCountFor(date),
                  exerciseDoneCount: _exerciseDoneCountFor(date),
                ),
                outsideBuilder: (_, date, __) => _DayCell(
                  date: date,
                  activity: null,
                  done: false,
                  isToday: false,
                  isSelected: false,
                  isOutside: true,
                  exerciseCount: 0,
                  exerciseDoneCount: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Day cell widget ────────────────────────────────────────────────────────────
//
//  Layout per cell (72px tall):
//
//   ┌───────────────┐
//   │      15       │  ← day number, large
//   │  [💪 重訓  ☑] │  ← colour strip: emoji + label + checkbox
//   └───────────────┘

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.activity,
    required this.done,
    required this.isToday,
    required this.isSelected,
    required this.isOutside,
    required this.exerciseCount,
    required this.exerciseDoneCount,
  });

  final DateTime date;
  final PlanActivity? activity;
  final bool done;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;
  final int exerciseCount;
  final int exerciseDoneCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final actColor = activity != null ? Color(activity!.colorValue) : null;
    final hasAct = activity != null;

    // Outer border for today / selected
    final border = isSelected
        ? Border.all(color: actColor ?? scheme.primary, width: 2)
        : isToday
            ? Border.all(color: scheme.primary, width: 1.5)
            : null;

    final cell = Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? (actColor ?? scheme.primary).withAlpha(30) : null,
        border: border,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Day number ─────────────────────────────────────
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  isToday || isSelected ? FontWeight.bold : FontWeight.w500,
              color: isOutside
                  ? Colors.grey.withAlpha(80)
                  : isToday
                      ? scheme.primary
                      : null,
            ),
          ),
          const SizedBox(height: 3),

          // ── Below the date: activity dot + custom-exercise badge ──
          //  Activity dot: SOLID while upcoming; HOLLOW once past or completed.
          //  Exercise badge: SOLID + count while pending; HOLLOW ring once all
          //  scheduled exercises for the date are completed.
          SizedBox(
            height: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasAct)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // empty ring until marked done; filled dot when completed
                      color: done ? actColor : Colors.transparent,
                      border: Border.all(color: actColor!, width: 1.5),
                    ),
                  ),
                if (hasAct && exerciseCount > 0 && !isOutside)
                  const SizedBox(width: 3),
                if (exerciseCount > 0 && !isOutside) _exerciseBadge(),
              ],
            ),
          ),
        ],
      ),
    );

    return cell;
  }

  /// Custom-exercise badge: solid blue circle with the count while any remain;
  /// a hollow blue ring once every scheduled exercise for the date is done.
  Widget _exerciseBadge() {
    final allDone = exerciseDoneCount >= exerciseCount;
    if (allDone) {
      // Blank circle (completed)
      return Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: _exerciseBadgeColor, width: 1.5),
        ),
      );
    }
    // Solid circle with remaining/total count
    return Container(
      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
      padding: const EdgeInsets.all(1.5),
      decoration: const BoxDecoration(
        color: _exerciseBadgeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$exerciseCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// Blue badge marking days with custom-scheduled exercises.
const Color _exerciseBadgeColor = Color(0xFF2563EB);
