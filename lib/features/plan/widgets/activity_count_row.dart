import 'package:flutter/material.dart';
import '../../../core/models/training_plan.dart';

class ActivityCountRow extends StatelessWidget {
  const ActivityCountRow({
    super.key,
    required this.activity,
    required this.count,
    required this.onChanged,
  });

  final PlanActivity activity;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Color(activity.colorValue);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Activity icon + label
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(activity.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(activity.label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          // Count stepper
          Row(
            children: [
              _StepBtn(
                icon: Icons.remove,
                onTap: count > 0 ? () => onChanged(count - 1) : null,
                color: color,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  count == 0 ? '休息' : '$count 次',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: count == 0 ? Colors.grey : color,
                  ),
                ),
              ),
              _StepBtn(
                icon: Icons.add,
                onTap: count < 7 ? () => onChanged(count + 1) : null,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap, required this.color});
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18,
            color: onTap != null ? color : Colors.grey.withAlpha(80)),
      ),
    );
  }
}
