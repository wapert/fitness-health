// 超慢跑 (Super Slow Jogging) — based on Prof. Hiroaki Tanaka's Slow Jogging method

enum JoggingLevel { beginner, intermediate, advanced }

class JoggingSession {
  const JoggingSession({
    required this.label,
    required this.durationMin,
    required this.description,
    this.walkBreakMin = 0,
  });

  final String label;
  final int durationMin;       // total jogging minutes
  final String description;
  final int walkBreakMin;      // walk break between jog intervals (0 = continuous)
}

class JoggingPlan {
  const JoggingPlan({
    required this.level,
    required this.label,
    required this.weeks,
    required this.description,
    required this.sessions,    // sessions per week
  });

  final JoggingLevel level;
  final String label;
  final int weeks;
  final String description;
  final List<JoggingWeek> sessions;
}

class JoggingWeek {
  const JoggingWeek({
    required this.week,
    required this.days,
  });

  final int week;
  final List<JoggingSession> days; // typically 3–5 sessions per week
}

class JoggingTechniqueTip {
  const JoggingTechniqueTip({
    required this.title,
    required this.description,
    required this.icon,
    this.videoId,
  });

  final String title;
  final String description;
  final String icon;           // emoji icon
  final String? videoId;
}

/// Niko-Niko pace: 138 - 0.7 × age  (beats per minute)
/// The pace at which you can hold a conversation and smile
int nikoNikoBpm(int age) => (138 - 0.7 * age).round().clamp(100, 135);
