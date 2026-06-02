import 'package:flutter/material.dart';
import '../../../core/models/nutrition.dart';

class NutritionHomeScreen extends StatefulWidget {
  const NutritionHomeScreen({super.key});

  @override
  State<NutritionHomeScreen> createState() => _NutritionHomeScreenState();
}

class _NutritionHomeScreenState extends State<NutritionHomeScreen> {
  NutritionGoal _goal = NutritionGoal.muscleGain;

  // Macro targets per goal (calories, protein g/kg, example for 70kg person)
  static const _targets = {
    NutritionGoal.muscleGain:  (calories: 2800.0, protein: 168.0, carbs: 350.0, fat: 78.0),
    NutritionGoal.fatLoss:     (calories: 2200.0, protein: 175.0, carbs: 220.0, fat: 73.0),
    NutritionGoal.weightLoss:  (calories: 1800.0, protein: 140.0, carbs: 180.0, fat: 60.0),
    NutritionGoal.fasting:     (calories: 2000.0, protein: 150.0, carbs: 200.0, fat: 67.0),
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final target = _targets[_goal]!;

    return Scaffold(
      appBar: AppBar(title: const Text('飲食營養 Nutrition')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Goal selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('目標', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: NutritionGoal.values.map((g) {
                      final active = _goal == g;
                      return ChoiceChip(
                        label: Text(g.label),
                        selected: active,
                        onSelected: (_) => setState(() => _goal = g),
                        selectedColor: scheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(_goal.description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Macro targets card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('每日目標 (70kg 範例)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _MacroRow('熱量', '${target.calories.toInt()} kcal', scheme.primary),
                  _MacroRow('蛋白質', '${target.protein.toInt()} g', Colors.red.shade400),
                  _MacroRow('碳水化合物', '${target.carbs.toInt()} g', Colors.amber.shade600),
                  _MacroRow('脂肪', '${target.fat.toInt()} g', Colors.blue.shade400),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Goal-specific tips
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_goal.label} 飲食策略',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ..._goalTips(_goal).map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline, size: 18, color: scheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(tip)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _goalTips(NutritionGoal goal) => switch (goal) {
        NutritionGoal.muscleGain => [
            '每公斤體重攝取 2.0–2.4g 蛋白質',
            '熱量盈餘 200–500 kcal/天',
            '訓練後 30–60 分鐘補充蛋白質與碳水',
            '優先選擇雞胸肉、鮭魚、雞蛋、豆腐等高蛋白食物',
            '碳水以地瓜、糙米、燕麥為主',
          ],
        NutritionGoal.fatLoss => [
            '熱量赤字 300–500 kcal/天',
            '維持高蛋白（每公斤體重 2.0–2.4g）保留肌肉',
            '提高蔬菜攝取增加飽足感',
            '避免液態熱量（含糖飲料、酒精）',
            '訓練前後優先安排碳水攝取',
          ],
        NutritionGoal.weightLoss => [
            '以 500 kcal/天赤字為目標，每週減 0.5kg',
            '選擇低 GI 食物延長飽足感',
            '多吃原型食物，減少加工食品',
            '每餐先吃蔬菜和蛋白質，最後吃碳水',
            '每天至少喝 2000ml 水',
          ],
        NutritionGoal.fasting => [
            '16:8 最易執行：12pm–8pm 進食窗口',
            '斷食期間可飲水、黑咖啡、無糖茶',
            '進食窗口內仍需達到每日蛋白質目標',
            '訓練可安排在進食窗口前後',
            '斷食初期可能有輕微頭暈，屬正常適應期',
          ],
      };
}

class _MacroRow extends StatelessWidget {
  const _MacroRow(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: color, margin: const EdgeInsets.only(right: 10)),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
