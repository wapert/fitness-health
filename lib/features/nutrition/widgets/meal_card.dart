import 'package:flutter/material.dart';
import '../../../core/models/nutrition.dart';

class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text(meal.emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(meal.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${meal.type.emoji} ${meal.type.label}  ·  ${meal.calories} kcal  ·  蛋白 ${meal.proteinG}g',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // ── Macro chips ────────────────────────────────────────────
          Row(
            children: [
              _Macro('熱量', '${meal.calories}', 'kcal', scheme.primary),
              _Macro('蛋白', '${meal.proteinG}', 'g', Colors.red.shade400),
              _Macro('碳水', '${meal.carbsG}', 'g', Colors.amber.shade700),
              _Macro('脂肪', '${meal.fatG}', 'g', Colors.blue.shade400),
            ],
          ),
          const SizedBox(height: 14),

          // ── Ingredients ────────────────────────────────────────────
          _sectionTitle('食材'),
          const SizedBox(height: 6),
          ...meal.ingredients.map(
            (ing) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(ing)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Steps ──────────────────────────────────────────────────
          _sectionTitle('作法'),
          const SizedBox(height: 6),
          ...meal.steps.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${e.key + 1}. ${e.value}'),
                ),
              ),

          // ── Tip ────────────────────────────────────────────────────
          if (meal.tip != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withAlpha(90),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 '),
                  Expanded(
                    child: Text(meal.tip!,
                        style: TextStyle(
                            fontSize: 13, color: scheme.onSecondaryContainer)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String s) =>
      Text(s, style: const TextStyle(fontWeight: FontWeight.w600));
}

class _Macro extends StatelessWidget {
  const _Macro(this.label, this.value, this.unit, this.color);
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(28),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: color)),
            const SizedBox(height: 2),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15, color: color)),
              TextSpan(
                  text: ' $unit',
                  style: TextStyle(fontSize: 10, color: color)),
            ])),
          ],
        ),
      ),
    );
  }
}
