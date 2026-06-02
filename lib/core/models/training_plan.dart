enum PlanActivity {
  training('重訓', '💪', 0xFF2563EB),
  stretching('伸展', '🧘', 0xFF16A34A),
  jogging('超慢跑', '🏃', 0xFFEA580C),
  fasting('斷食', '⏱️', 0xFF7C3AED),
  rest('休息', '😴', 0xFF9CA3AF);

  const PlanActivity(this.label, this.emoji, this.colorValue);
  final String label;
  final String emoji;
  final int colorValue;
}

/// Weekly plan configuration — how many times per week for each activity
class WeeklyPlanConfig {
  const WeeklyPlanConfig({
    this.trainingDays  = 3,
    this.stretchingDays = 2,
    this.joggingDays   = 0,
    this.fastingDays   = 1,
    required this.startDate,
  });

  final int trainingDays;
  final int stretchingDays;
  final int joggingDays;
  final int fastingDays;
  final DateTime startDate;

  int get totalActiveDays =>
      trainingDays + stretchingDays + joggingDays + fastingDays;

  /// Auto-assigns activities to weekdays (Mon=1 … Sun=7)
  /// Strategy: spread activities as evenly as possible, no same-type on adjacent days
  Map<int, PlanActivity> get weekTemplate {
    final map = <int, PlanActivity>{};
    final used = <int>{};

    void assign(List<int> preferred, PlanActivity activity, int count) {
      final slots = preferred.where((d) => !used.contains(d)).toList();
      for (int i = 0; i < count && i < slots.length; i++) {
        map[slots[i]] = activity;
        used.add(slots[i]);
      }
    }

    assign([1, 3, 5, 6, 7, 2, 4], PlanActivity.training,   trainingDays);
    assign([2, 4, 6, 1, 3, 5, 7], PlanActivity.stretching,  stretchingDays);
    assign([2, 4, 6, 7, 1, 3, 5], PlanActivity.jogging,     joggingDays);
    assign([7, 3, 1, 2, 4, 5, 6], PlanActivity.fasting,     fastingDays);

    return map;
  }

  WeeklyPlanConfig copyWith({
    int? trainingDays,
    int? stretchingDays,
    int? joggingDays,
    int? fastingDays,
  }) =>
      WeeklyPlanConfig(
        trainingDays:   trainingDays   ?? this.trainingDays,
        stretchingDays: stretchingDays ?? this.stretchingDays,
        joggingDays:    joggingDays    ?? this.joggingDays,
        fastingDays:    fastingDays    ?? this.fastingDays,
        startDate:      startDate,
      );

  Map<String, dynamic> toJson() => {
        'training':   trainingDays,
        'stretching': stretchingDays,
        'jogging':    joggingDays,
        'fasting':    fastingDays,
        'start':      startDate.toIso8601String(),
      };

  factory WeeklyPlanConfig.fromJson(Map<String, dynamic> j) =>
      WeeklyPlanConfig(
        trainingDays:   (j['training']   as int?) ?? 3,
        stretchingDays: (j['stretching'] as int?) ?? 2,
        joggingDays:    (j['jogging']    as int?) ?? 0,
        fastingDays:    (j['fasting']    as int?) ?? 1,
        startDate: DateTime.tryParse(j['start'] ?? '') ?? DateTime.now(),
      );
}

/// A single day that the user has marked as completed
class CompletedDay {
  const CompletedDay({required this.date, required this.activity});
  final DateTime date;
  final PlanActivity activity;

  Map<String, dynamic> toJson() =>
      {'date': date.toIso8601String(), 'activity': activity.name};

  factory CompletedDay.fromJson(Map<String, dynamic> j) => CompletedDay(
        date: DateTime.parse(j['date'] as String),
        activity: PlanActivity.values.firstWhere(
          (a) => a.name == j['activity'],
          orElse: () => PlanActivity.training,
        ),
      );

  static String keyFor(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
