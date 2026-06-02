import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/models/training_plan.dart';
import '../services/plan_service.dart';
import '../widgets/activity_count_row.dart';
import '../widgets/week_preview.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _service = PlanService();

  WeeklyPlanConfig _config = WeeklyPlanConfig(
    trainingDays: 3,
    stretchingDays: 2,
    joggingDays: 0,
    fastingDays: 1,
    startDate: DateTime.now(),
  );

  Map<String, CompletedDay> _completed = {};
  Map<int, PlanActivity> _editableTemplate = {};  // user-edited week template
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
    final cfg  = await _service.loadConfig();
    final done = await _service.loadCompleted();
    setState(() {
      if (cfg != null) _config = cfg;
      _editableTemplate = (cfg ?? _config).weekTemplate;
      _completed = done;
      _loaded = true;
      _showSetup = cfg == null; // first launch → show setup
    });
  }

  Future<void> _saveConfig() async {
    await _service.saveConfig(_config);
    setState(() => _showSetup = false);
  }

  // ── Event helpers ────────────────────────────────────────────────────────

  PlanActivity? _activityFor(DateTime day) =>
      _editableTemplate[day.weekday];

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
    if (activity == null && !_isDone(day)) {
      // Rest day — show briefly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_dateLabel(day)} — 休息日 😴'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    final eff = activity ?? PlanActivity.training;
    final color = Color(eff.colorValue);
    final done = _isDone(day);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(80),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: color.withAlpha(40),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(eff.emoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_dateLabel(day),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(eff.label,
                        style: TextStyle(color: color, fontSize: 14)),
                  ],
                ),
                const Spacer(),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: done
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
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime d) {
    const weekdays = ['一','二','三','四','五','六','日'];
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
                      _config = _config.copyWith(trainingDays: v);
                      _editableTemplate = _config.weekTemplate;
                    }),
                  ),
                  const Divider(height: 20),
                  ActivityCountRow(
                    activity: PlanActivity.stretching,
                    count: _config.stretchingDays,
                    onChanged: (v) => setState(() {
                      _config = _config.copyWith(stretchingDays: v);
                      _editableTemplate = _config.weekTemplate;
                    }),
                  ),
                  const Divider(height: 20),
                  ActivityCountRow(
                    activity: PlanActivity.jogging,
                    count: _config.joggingDays,
                    onChanged: (v) => setState(() {
                      _config = _config.copyWith(joggingDays: v);
                      _editableTemplate = _config.weekTemplate;
                    }),
                  ),
                  const Divider(height: 20),
                  ActivityCountRow(
                    activity: PlanActivity.fasting,
                    count: _config.fastingDays,
                    onChanged: (v) => setState(() {
                      _config = _config.copyWith(fastingDays: v);
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
          Row(
            children: const [
              Icon(Icons.drag_indicator, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text('長按活動圖示可拖曳到其他日期',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 20),
          // Summary chips
          Wrap(
            spacing: 8, runSpacing: 8,
            children: PlanActivity.values
                .where((a) => a != PlanActivity.rest)
                .map((a) {
              final count = switch (a) {
                PlanActivity.training   => _config.trainingDays,
                PlanActivity.stretching => _config.stretchingDays,
                PlanActivity.jogging    => _config.joggingDays,
                PlanActivity.fasting    => _config.fastingDays,
                _                       => 0,
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
    final scheme   = Theme.of(context).colorScheme;
    final thisWeekTotal = _config.totalActiveDays;
    final thisWeekDone  = _completedThisWeek;

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
                          fontWeight: FontWeight.bold,
                          color: scheme.primary)),
                  const Spacer(),
                  Text('$thisWeekDone / $thisWeekTotal',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: thisWeekTotal == 0
                      ? 0
                      : thisWeekDone / thisWeekTotal,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceVariant,
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
            children: PlanActivity.values
                .where((a) => a != PlanActivity.rest)
                .map((a) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12, height: 12,
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
                    ))
                .toList(),
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
              rowHeight: 72,            // taller rows
              daysOfWeekHeight: 28,
              selectedDayPredicate: (d) =>
                  _selectedDay != null && isSameDay(_selectedDay!, d),
              eventLoader: _eventsForDay,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay  = focused;
                });
                _showDayDetail(selected);
              },
              onPageChanged: (f) => setState(() => _focusedDay = f),

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              calendarStyle: const CalendarStyle(
                // disable default decorations — our builder handles everything
                todayDecoration:    BoxDecoration(),
                selectedDecoration: BoxDecoration(),
                defaultDecoration:  BoxDecoration(),
                weekendDecoration:  BoxDecoration(),
                outsideDecoration:  BoxDecoration(),
                markersMaxCount: 0,
              ),

              calendarBuilders: CalendarBuilders(
                markerBuilder: (_, __, ___) => const SizedBox.shrink(),
                defaultBuilder: (_, date, __) => _DayCell(
                  date: date, activity: _activityFor(date),
                  done: _isDone(date), isToday: false,
                  isSelected: _selectedDay != null && isSameDay(_selectedDay!, date),
                  isOutside: false,
                ),
                todayBuilder: (_, date, __) => _DayCell(
                  date: date, activity: _activityFor(date),
                  done: _isDone(date), isToday: true,
                  isSelected: _selectedDay != null && isSameDay(_selectedDay!, date),
                  isOutside: false,
                ),
                selectedBuilder: (_, date, __) => _DayCell(
                  date: date, activity: _activityFor(date),
                  done: _isDone(date),
                  isToday: isSameDay(date, DateTime.now()),
                  isSelected: true,
                  isOutside: false,
                ),
                outsideBuilder: (_, date, __) => _DayCell(
                  date: date, activity: null,
                  done: false, isToday: false,
                  isSelected: false, isOutside: true,
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
  });

  final DateTime date;
  final PlanActivity? activity;
  final bool done;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  @override
  Widget build(BuildContext context) {
    final scheme   = Theme.of(context).colorScheme;
    final actColor = activity != null ? Color(activity!.colorValue) : null;
    final hasAct   = activity != null;

    // Outer border for today / selected
    final border = isSelected
        ? Border.all(color: actColor ?? scheme.primary, width: 2)
        : isToday
            ? Border.all(color: scheme.primary, width: 1.5)
            : null;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? (actColor ?? scheme.primary).withAlpha(30)
            : null,
        border: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Day number ─────────────────────────────────────
          Expanded(
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isOutside
                      ? Colors.grey.withAlpha(80)
                      : isToday
                          ? scheme.primary
                          : null,
                ),
              ),
            ),
          ),

          // ── Activity colour strip ──────────────────────────
          if (hasAct)
            Container(
              height: 26,
              decoration: BoxDecoration(
                color: done
                    ? actColor!.withAlpha(220)   // solid when done
                    : actColor!.withAlpha(55),   // subtle when pending
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(activity!.emoji,
                      style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 2),
                  // Checkbox icon
                  Icon(
                    done
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 14,
                    color: done ? Colors.white : actColor,
                  ),
                ],
              ),
            )
          else
            // Rest day — thin neutral bottom bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(isOutside ? 10 : 25),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(6)),
              ),
            ),
        ],
      ),
    );
  }
}
