enum NutritionGoal {
  muscleGain('增肌', '高蛋白、熱量盈餘'),
  fatLoss('減脂', '高蛋白、熱量赤字'),
  weightLoss('減肥', '均衡飲食、控制熱量'),
  fasting('斷食', '間歇性斷食協議');

  const NutritionGoal(this.label, this.description);
  final String label;
  final String description;
}

enum MealType {
  breakfast('早餐', '🌅'),
  lunch('午餐', '☀️'),
  dinner('晚餐', '🌙'),
  snack('點心', '🍎');

  const MealType(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// A curated recommended meal with ingredients, macros and a simple recipe.
class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.goals,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.ingredients,
    required this.steps,
    this.tip,
  });

  final String id;
  final String name;
  final String emoji;
  final MealType type;
  final List<NutritionGoal> goals;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final List<String> ingredients;
  final List<String> steps;
  final String? tip;
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
