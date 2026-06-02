import 'package:flutter/material.dart';
import '../../../core/models/training_plan.dart';

class WeekPreview extends StatelessWidget {
  const WeekPreview({
    super.key,
    required this.template,
    this.onTemplateChanged, // null = read-only
  });

  final Map<int, PlanActivity> template;
  final ValueChanged<Map<int, PlanActivity>>? onTemplateChanged;

  bool get _editable => onTemplateChanged != null;

  static const _days = ['一', '二', '三', '四', '五', '六', '日'];

  void _swap(int fromDay, int toDay) {
    if (fromDay == toDay) return;
    final newTemplate = Map<int, PlanActivity>.from(template);
    final fromAct = newTemplate[fromDay];
    final toAct   = newTemplate[toDay];
    if (fromAct != null) {
      newTemplate[toDay] = fromAct;
    } else {
      newTemplate.remove(toDay);
    }
    if (toAct != null) {
      newTemplate[fromDay] = toAct;
    } else {
      newTemplate.remove(fromDay);
    }
    onTemplateChanged!(newTemplate);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final weekday  = i + 1;
        final activity = template[weekday];

        if (_editable) {
          return _EditableDay(
            weekday:  weekday,
            dayLabel: _days[i],
            activity: activity,
            onSwap:   (fromDay) => _swap(fromDay, weekday),
          );
        }
        return _ReadOnlyDay(
          dayLabel: _days[i],
          activity: activity,
        );
      }),
    );
  }
}

// ── Read-only bubble (used in calendar view) ─────────────────────────────────

class _ReadOnlyDay extends StatelessWidget {
  const _ReadOnlyDay({required this.dayLabel, required this.activity});
  final String dayLabel;
  final PlanActivity? activity;

  @override
  Widget build(BuildContext context) {
    final color = activity != null ? Color(activity!.colorValue) : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(dayLabel,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        _Bubble(activity: activity, highlight: false, isDragTarget: false),
        const SizedBox(height: 4),
        Text(
          activity?.label ?? '休息',
          style: TextStyle(
              fontSize: 9,
              color: color ?? Colors.grey,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ── Editable day: draggable + drop target ─────────────────────────────────────

class _EditableDay extends StatefulWidget {
  const _EditableDay({
    required this.weekday,
    required this.dayLabel,
    required this.activity,
    required this.onSwap,
  });

  final int weekday;
  final String dayLabel;
  final PlanActivity? activity;
  final ValueChanged<int> onSwap; // called with the dragged-from weekday

  @override
  State<_EditableDay> createState() => _EditableDayState();
}

class _EditableDayState extends State<_EditableDay> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    Widget bubble = _Bubble(
      activity: activity,
      highlight: _isHovered,
      isDragTarget: false,
    );

    // Wrap with drag source if the day has an activity
    if (activity != null) {
      bubble = LongPressDraggable<int>(
        data: widget.weekday,
        hapticFeedbackOnStart: true,
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Bubble(
                    activity: activity, highlight: true, isDragTarget: false),
                const SizedBox(height: 2),
                Text(activity.label,
                    style: TextStyle(
                        fontSize: 9,
                        color: Color(activity.colorValue),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        childWhenDragging: _Bubble(
            activity: null, highlight: false, isDragTarget: false,
            faded: true),
        child: bubble,
      );
    }

    // Capture inner widget BEFORE wrapping in DragTarget to avoid closure recursion
    final innerWidget = bubble;

    // Wrap with drop target (always)
    bubble = DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != widget.weekday,
      onAcceptWithDetails: (details) {
        setState(() => _isHovered = false);
        widget.onSwap(details.data);
      },
      onMove: (_) => setState(() => _isHovered = true),
      onLeave: (_) => setState(() => _isHovered = false),
      builder: (context, candidates, _) => AnimatedScale(
        scale: candidates.isNotEmpty ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: innerWidget,   // ← use captured inner widget, not 'bubble'
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.dayLabel,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        bubble,
        const SizedBox(height: 4),
        Text(
          activity?.label ?? '休息',
          style: TextStyle(
              fontSize: 9,
              color: activity != null
                  ? Color(activity.colorValue)
                  : Colors.grey,
              fontWeight: FontWeight.w500),
        ),
        // Drag hint on first render
        if (activity != null)
          const Text('長按拖曳',
              style: TextStyle(fontSize: 7, color: Colors.grey)),
      ],
    );
  }
}

// ── Shared bubble widget ──────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.activity,
    required this.highlight,
    required this.isDragTarget,
    this.faded = false,
  });

  final PlanActivity? activity;
  final bool highlight;
  final bool isDragTarget;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final color = activity != null ? Color(activity!.colorValue) : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: highlight
            ? (color ?? Colors.grey).withAlpha(80)
            : activity != null
                ? color!.withAlpha(faded ? 25 : 45)
                : Colors.grey.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(
          color: highlight
              ? (color ?? Colors.grey)
              : activity != null
                  ? color!.withAlpha(faded ? 40 : 140)
                  : Colors.grey.withAlpha(40),
          width: highlight ? 2.5 : 1.5,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                    color: (color ?? Colors.grey).withAlpha(80),
                    blurRadius: 8,
                    spreadRadius: 2)
              ]
            : null,
      ),
      child: Center(
        child: Text(
          activity?.emoji ?? (isDragTarget ? '＋' : '—'),
          style: TextStyle(
              fontSize: activity != null ? 18 : 12,
              color: activity != null
                  ? null
                  : Colors.grey.withAlpha(faded ? 40 : 80)),
        ),
      ),
    );
  }
}
