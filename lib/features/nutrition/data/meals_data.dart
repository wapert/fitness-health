import '../../../core/models/nutrition.dart';

/// Curated meal recommendations. Macros are approximate per serving.
/// Each meal is tagged with the goals it best supports.
const List<Meal> meals = [
  // ── 增肌 Muscle Gain ──────────────────────────────────────────────────────
  Meal(
    id: 'mg_oat_bowl',
    name: '高蛋白燕麥碗',
    emoji: '🥣',
    type: MealType.breakfast,
    goals: [NutritionGoal.muscleGain],
    calories: 560, proteinG: 40, carbsG: 65, fatG: 15,
    ingredients: [
      '燕麥片 60g',
      '牛奶 250ml',
      '乳清蛋白 1 匙 (30g)',
      '香蕉 1 根',
      '花生醬 1 湯匙',
    ],
    steps: [
      '燕麥加牛奶微波 2 分鐘或煮至濃稠',
      '稍微放涼後拌入乳清蛋白粉',
      '鋪上切片香蕉與花生醬即可',
    ],
    tip: '訓練後當早餐，快速補充蛋白質與碳水。',
  ),
  Meal(
    id: 'mg_chicken_sweetpotato',
    name: '雞胸肉地瓜便當',
    emoji: '🍱',
    type: MealType.lunch,
    goals: [NutritionGoal.muscleGain, NutritionGoal.fatLoss],
    calories: 640, proteinG: 55, carbsG: 68, fatG: 12,
    ingredients: [
      '雞胸肉 200g',
      '地瓜 200g',
      '花椰菜 100g',
      '糙米飯 半碗',
      '橄欖油 1 茶匙、鹽、黑胡椒',
    ],
    steps: [
      '雞胸肉抹鹽與黑胡椒，煎或氣炸 12–15 分鐘',
      '地瓜蒸或烤 20 分鐘至軟',
      '花椰菜燙熟，全部裝盒配糙米飯',
    ],
    tip: '經典增肌便當，可一次備 3 天份冷藏。',
  ),
  Meal(
    id: 'mg_steak_rice',
    name: '牛排糙米飯',
    emoji: '🥩',
    type: MealType.dinner,
    goals: [NutritionGoal.muscleGain],
    calories: 700, proteinG: 50, carbsG: 58, fatG: 28,
    ingredients: [
      '沙朗牛排 180g',
      '糙米飯 1 碗',
      '蘆筍 100g',
      '橄欖油、海鹽',
    ],
    steps: [
      '牛排回溫後大火每面煎 2–3 分鐘，靜置 5 分鐘',
      '蘆筍以少油香煎至微焦',
      '切片牛排配糙米飯與蘆筍',
    ],
    tip: '紅肉提供鐵質與肌酸，適合大訓練日晚餐。',
  ),
  Meal(
    id: 'mg_yogurt_nuts',
    name: '希臘優格堅果杯',
    emoji: '🥛',
    type: MealType.snack,
    goals: [NutritionGoal.muscleGain, NutritionGoal.fasting],
    calories: 350, proteinG: 25, carbsG: 30, fatG: 15,
    ingredients: [
      '無糖希臘優格 200g',
      '藍莓 50g',
      '杏仁 20g',
      '蜂蜜 1 茶匙',
    ],
    steps: [
      '優格倒入杯中',
      '鋪上藍莓與杏仁，淋蜂蜜',
    ],
    tip: '睡前補充酪蛋白，幫助夜間肌肉修復。',
  ),

  // ── 減脂 Fat Loss ─────────────────────────────────────────────────────────
  Meal(
    id: 'fl_omelette',
    name: '蔬菜蛋白歐姆蛋',
    emoji: '🍳',
    type: MealType.breakfast,
    goals: [NutritionGoal.fatLoss, NutritionGoal.weightLoss],
    calories: 300, proteinG: 28, carbsG: 8, fatG: 18,
    ingredients: [
      '全蛋 2 顆 + 蛋白 2 份',
      '菠菜 1 把',
      '番茄 1 顆',
      '橄欖油 1 茶匙',
    ],
    steps: [
      '菠菜與番茄切好，橄欖油略炒',
      '倒入打散蛋液，小火煎至凝固對折',
    ],
    tip: '高蛋白低碳，早餐提供長時間飽足感。',
  ),
  Meal(
    id: 'fl_chicken_salad',
    name: '舒肥雞胸沙拉',
    emoji: '🥗',
    type: MealType.lunch,
    goals: [NutritionGoal.fatLoss, NutritionGoal.fasting],
    calories: 420, proteinG: 45, carbsG: 15, fatG: 20,
    ingredients: [
      '舒肥雞胸 150g',
      '綜合生菜 1 大把',
      '小番茄 8 顆',
      '酪梨 1/4 顆',
      '橄欖油醋醬 1 湯匙',
    ],
    steps: [
      '生菜、番茄、酪梨鋪盤',
      '雞胸切片放上，淋橄欖油醋醬',
    ],
    tip: '酪梨提供好油脂，增加飽足又不升血糖。',
  ),
  Meal(
    id: 'fl_salmon_broccoli',
    name: '烤鮭魚花椰菜',
    emoji: '🐟',
    type: MealType.dinner,
    goals: [NutritionGoal.fatLoss],
    calories: 450, proteinG: 40, carbsG: 12, fatG: 28,
    ingredients: [
      '鮭魚 150g',
      '花椰菜 150g',
      '蘆筍 80g',
      '檸檬、黑胡椒、橄欖油',
    ],
    steps: [
      '鮭魚抹鹽與黑胡椒，200°C 烤 12 分鐘',
      '花椰菜與蘆筍燙熟或同烤',
      '起鍋擠上檸檬汁',
    ],
    tip: 'Omega-3 有助降低發炎、支持減脂期恢復。',
  ),
  Meal(
    id: 'fl_egg_yogurt',
    name: '水煮蛋優格點心',
    emoji: '🥚',
    type: MealType.snack,
    goals: [NutritionGoal.fatLoss],
    calories: 220, proteinG: 25, carbsG: 8, fatG: 10,
    ingredients: [
      '水煮蛋 2 顆',
      '無糖希臘優格 100g',
      '黑胡椒少許',
    ],
    steps: [
      '水煮蛋剝殼對切',
      '搭配一小杯希臘優格',
    ],
    tip: '低熱量高蛋白，嘴饞時的理想選擇。',
  ),

  // ── 減肥 Weight Loss ──────────────────────────────────────────────────────
  Meal(
    id: 'wl_soymilk_oat',
    name: '無糖豆漿燕麥',
    emoji: '🥛',
    type: MealType.breakfast,
    goals: [NutritionGoal.weightLoss],
    calories: 280, proteinG: 14, carbsG: 45, fatG: 6,
    ingredients: [
      '燕麥片 40g',
      '無糖豆漿 300ml',
      '奇亞籽 1 茶匙',
      '藍莓 30g',
    ],
    steps: [
      '燕麥與豆漿加熱或泡隔夜燕麥',
      '拌入奇亞籽，鋪上藍莓',
    ],
    tip: '高纖低 GI，穩定血糖、延長飽足。',
  ),
  Meal(
    id: 'wl_chicken_soup',
    name: '蔬菜雞肉湯',
    emoji: '🍲',
    type: MealType.lunch,
    goals: [NutritionGoal.weightLoss],
    calories: 350, proteinG: 30, carbsG: 25, fatG: 12,
    ingredients: [
      '去皮雞腿 150g',
      '高麗菜 100g',
      '紅蘿蔔 半根',
      '番茄 1 顆、薑片、鹽',
    ],
    steps: [
      '雞腿切塊汆燙去血水',
      '所有食材加水煮滾轉小火 25 分鐘',
      '加鹽調味',
    ],
    tip: '大量蔬菜與湯水增加飽足感，熱量低。',
  ),
  Meal(
    id: 'wl_tofu_pot',
    name: '豆腐蔬菜煲',
    emoji: '🍜',
    type: MealType.dinner,
    goals: [NutritionGoal.weightLoss],
    calories: 300, proteinG: 22, carbsG: 20, fatG: 14,
    ingredients: [
      '板豆腐 1 塊',
      '香菇 3 朵',
      '青江菜 2 株',
      '醬油、薑、蒜',
    ],
    steps: [
      '豆腐切塊煎至微金黃',
      '加香菇、青江菜與少許醬油水燜煮 5 分鐘',
    ],
    tip: '植物性蛋白，低熱量又有飽足感。',
  ),
  Meal(
    id: 'wl_apple_nuts',
    name: '蘋果堅果',
    emoji: '🍎',
    type: MealType.snack,
    goals: [NutritionGoal.weightLoss, NutritionGoal.fasting],
    calories: 200, proteinG: 5, carbsG: 25, fatG: 10,
    ingredients: [
      '蘋果 1 顆',
      '杏仁 15g',
    ],
    steps: [
      '蘋果切片',
      '搭配一小把杏仁',
    ],
    tip: '纖維加好油脂，取代高糖零食。',
  ),

  // ── 斷食 Fasting ──────────────────────────────────────────────────────────
  Meal(
    id: 'fa_avocado_toast',
    name: '酪梨蛋吐司（開齋餐）',
    emoji: '🥑',
    type: MealType.breakfast,
    goals: [NutritionGoal.fasting],
    calories: 400, proteinG: 20, carbsG: 35, fatG: 22,
    ingredients: [
      '全麥吐司 2 片',
      '酪梨 半顆',
      '水煮蛋 2 顆',
      '鹽、黑胡椒、辣椒片',
    ],
    steps: [
      '吐司烤香',
      '酪梨壓泥抹上，鋪切片水煮蛋',
      '撒鹽、黑胡椒與辣椒片',
    ],
    tip: '結束斷食的第一餐，好油脂加蛋白溫和開胃。',
  ),
  Meal(
    id: 'fa_med_bowl',
    name: '地中海雞肉碗',
    emoji: '🥙',
    type: MealType.lunch,
    goals: [NutritionGoal.fasting, NutritionGoal.muscleGain],
    calories: 600, proteinG: 45, carbsG: 50, fatG: 22,
    ingredients: [
      '雞胸肉 150g',
      '藜麥 1 碗',
      '鷹嘴豆 50g',
      '小黃瓜、番茄、橄欖油',
    ],
    steps: [
      '藜麥煮熟放涼',
      '雞胸煎熟切條',
      '所有食材拌勻，淋橄欖油與檸檬',
    ],
    tip: '進食窗口的主餐，營養密度高、均衡完整。',
  ),
  Meal(
    id: 'fa_salmon_quinoa',
    name: '鮭魚藜麥沙拉',
    emoji: '🐟',
    type: MealType.dinner,
    goals: [NutritionGoal.fasting],
    calories: 550, proteinG: 38, carbsG: 40, fatG: 25,
    ingredients: [
      '鮭魚 130g',
      '藜麥 3/4 碗',
      '菠菜 1 把',
      '核桃 15g、橄欖油醋',
    ],
    steps: [
      '鮭魚煎或烤熟',
      '藜麥、菠菜、核桃拌勻',
      '放上鮭魚，淋橄欖油醋',
    ],
    tip: '進食窗口尾聲的營養晚餐，好油脂助恢復。',
  ),
  Meal(
    id: 'fa_darkchoc_nuts',
    name: '堅果黑巧克力',
    emoji: '🍫',
    type: MealType.snack,
    goals: [NutritionGoal.fasting],
    calories: 300, proteinG: 8, carbsG: 18, fatG: 24,
    ingredients: [
      '混合堅果 30g',
      '85% 黑巧克力 2 小格',
    ],
    steps: [
      '取一小把堅果',
      '搭配黑巧克力慢慢享用',
    ],
    tip: '進食窗口內的滿足點心，避免斷食後暴食。',
  ),
];

/// Meals matching a goal, grouped in meal-type order.
List<Meal> mealsForGoal(NutritionGoal goal) {
  const order = {
    MealType.breakfast: 0,
    MealType.lunch: 1,
    MealType.dinner: 2,
    MealType.snack: 3,
  };
  final list = meals.where((m) => m.goals.contains(goal)).toList();
  list.sort((a, b) => order[a.type]!.compareTo(order[b.type]!));
  return list;
}
