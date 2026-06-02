enum NutritionGoal {
  muscleGain('增肌', '高蛋白、熱量盈餘'),
  fatLoss('減脂', '高蛋白、熱量赤字'),
  weightLoss('減肥', '均衡飲食、控制熱量'),
  fasting('斷食', '間歇性斷食協議');

  const NutritionGoal(this.label, this.description);
  final String label;
  final String description;
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.nameChinese,
    required this.servingGrams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final String id;
  final String name;
  final String nameChinese;
  final double servingGrams;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

class DailyLog {
  const DailyLog({
    required this.date,
    required this.goal,
    required this.items,
    required this.targetCalories,
    required this.targetProteinG,
  });

  final DateTime date;
  final NutritionGoal goal;
  final List<FoodItem> items;
  final double targetCalories;
  final double targetProteinG;

  double get totalCalories => items.fold(0, (s, f) => s + f.calories);
  double get totalProtein  => items.fold(0, (s, f) => s + f.proteinG);
  double get totalCarbs    => items.fold(0, (s, f) => s + f.carbsG);
  double get totalFat      => items.fold(0, (s, f) => s + f.fatG);
}
