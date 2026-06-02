import 'package:flutter/material.dart';
import '../../../core/models/jogging.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan});
  final JoggingPlan plan;

  Color get _levelColor => switch (plan.level) {
        JoggingLevel.beginner    => const Color(0xFF4CAF50),
        JoggingLevel.intermediate => Colors.orange,
        JoggingLevel.advanced    => Colors.red,
      };

  String get _levelLabel => switch (plan.level) {
        JoggingLevel.beginner    => '初學',
        JoggingLevel.intermediate => '進階',
        JoggingLevel.advanced    => '高階',
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _levelColor.withAlpha(40),
          child: Text(_levelLabel[0],
              style: TextStyle(
                  color: _levelColor, fontWeight: FontWeight.bold)),
        ),
        title: Text(plan.label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(plan.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: plan.sessions.map((week) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _levelColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '第 ${week.week} 週',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...week.days.map((session) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(session.label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(session.description,
                                        style: const TextStyle(fontSize: 13)),
                                    Text(
                                      '共 ${session.durationMin} 分鐘'
                                      '${session.walkBreakMin > 0 ? "（含走路休息）" : ""}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: _levelColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (week.week < plan.weeks) const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
