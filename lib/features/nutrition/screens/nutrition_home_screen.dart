import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/nutrition.dart';
import '../data/meals_data.dart';
import '../widgets/meal_card.dart';

class NutritionHomeScreen extends StatefulWidget {
  const NutritionHomeScreen({super.key});

  @override
  State<NutritionHomeScreen> createState() => _NutritionHomeScreenState();
}

class _NutritionHomeScreenState extends State<NutritionHomeScreen> {
  NutritionGoal _goal = NutritionGoal.muscleGain;

  // Macro targets per goal (calories, protein g/kg, example for 70kg person)
  static const _targets = {
    NutritionGoal.muscleGain: (
      calories: 2800.0,
      protein: 168.0,
      carbs: 350.0,
      fat: 78.0
    ),
    NutritionGoal.fatLoss: (
      calories: 2200.0,
      protein: 175.0,
      carbs: 220.0,
      fat: 73.0
    ),
    NutritionGoal.weightLoss: (
      calories: 1800.0,
      protein: 140.0,
      carbs: 180.0,
      fat: 60.0
    ),
    NutritionGoal.fasting: (
      calories: 2000.0,
      protein: 150.0,
      carbs: 200.0,
      fat: 67.0
    ),
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
                  const Text('目標',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  Text(_goal.description,
                      style: Theme.of(context).textTheme.bodySmall),
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
                  const Text('每日營養範例（70kg 成人）',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    '以下為一般性示範，並非依個人年齡、性別、活動量或健康狀況計算的目標。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  _MacroRow(
                      '熱量', '${target.calories.toInt()} kcal', scheme.primary),
                  _MacroRow('蛋白質', '${target.protein.toInt()} g',
                      Colors.red.shade400),
                  _MacroRow('碳水化合物', '${target.carbs.toInt()} g',
                      Colors.amber.shade600),
                  _MacroRow(
                      '脂肪', '${target.fat.toInt()} g', Colors.blue.shade400),
                  const Divider(height: 24),
                  TextButton.icon(
                    onPressed: () => _showNutritionSources(context),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('資料來源與健康聲明'),
                  ),
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
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ..._goalTips(_goal).map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: scheme.primary),
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
          const SizedBox(height: 20),

          // Recommended meals for the selected goal
          Row(
            children: [
              const Text('🍽️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('${_goal.label}推薦餐點',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('點擊展開查看食材、作法與營養資訊（每份為概略估算）',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          ...mealsForGoal(_goal).map((m) => MealCard(meal: m)),
        ],
      ),
    );
  }

  List<String> _goalTips(NutritionGoal goal) => switch (goal) {
        NutritionGoal.muscleGain => [
            '運動成人每日蛋白質可參考每公斤體重 1.4–2.0g',
            '熱量盈餘 200–500 kcal/天',
            '在訓練前後安排含蛋白質的餐點',
            '優先選擇雞胸肉、鮭魚、雞蛋、豆腐等高蛋白食物',
            '碳水以地瓜、糙米、燕麥為主',
          ],
        NutritionGoal.fatLoss => [
            '熱量赤字 300–500 kcal/天',
            '減脂期間的蛋白質需求因訓練量與個人狀況而異',
            '提高蔬菜攝取增加飽足感',
            '避免液態熱量（含糖飲料、酒精）',
            '訓練前後優先安排碳水攝取',
          ],
        NutritionGoal.weightLoss => [
            '以緩慢、穩定的速度減重，並依個人狀況調整',
            '選擇低 GI 食物延長飽足感',
            '多吃原型食物，減少加工食品',
            '每餐先吃蔬菜和蛋白質，最後吃碳水',
            '水分需求依體型、活動量、氣候與健康狀況而異',
          ],
        NutritionGoal.fasting => [
            '16:8 是限時進食的一種形式，並非適合所有人',
            '斷食期間可飲水、黑咖啡、無糖茶',
            '進食窗口內仍需達到每日蛋白質目標',
            '訓練可安排在進食窗口前後',
            '若出現頭暈、不適或低血糖症狀，請停止並諮詢醫療專業人員',
          ],
      };

  Future<void> _showNutritionSources(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('資料來源與健康聲明'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '本頁僅提供一般健康教育與餐點示範，不構成醫療診斷或個人化營養建議。每日熱量與營養需求會因年齡、性別、體重、活動量及健康狀況而不同。餐點營養數值依常見食材份量估算，實際數值會因品牌、份量與烹調方式而異。',
                ),
                const SizedBox(height: 12),
                const Text(
                  '孕婦、未成年人、糖尿病患者、有飲食失調病史、正在服藥或有其他健康疑慮者，在減重或斷食前應先諮詢醫師或合格營養師。',
                ),
                const SizedBox(height: 16),
                const Text('參考資料',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ..._nutritionSources.map(
                  (source) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(source.title),
                    subtitle: Text(source.supports),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => launchUrl(
                      Uri.parse(source.url),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('關閉')),
        ],
      ),
    );
  }
}

const _nutritionSources = [
  (
    title: 'International Society of Sports Nutrition：蛋白質與運動',
    supports: '運動成人的每日蛋白質攝取範圍與運動前後攝取原則',
    url: 'https://pubmed.ncbi.nlm.nih.gov/28642676/',
  ),
  (
    title: '美國 CDC：健康減重步驟',
    supports: '緩慢、穩定減重及影響體重管理的個人因素',
    url: 'https://www.cdc.gov/healthy-weight-growth/losing-weight/index.html',
  ),
  (
    title: '美國國家老化研究所：熱量限制與斷食',
    supports: '間歇性斷食的形式、證據限制與安全注意事項',
    url:
        'https://www.nia.nih.gov/news/calorie-restriction-and-fasting-diets-what-do-we-know',
  ),
  (
    title: 'USDA FoodData Central',
    supports: '食材與營養成分估算的參考資料庫',
    url: 'https://fdc.nal.usda.gov/',
  ),
];

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
          Container(
              width: 4,
              height: 20,
              color: color,
              margin: const EdgeInsets.only(right: 10)),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
