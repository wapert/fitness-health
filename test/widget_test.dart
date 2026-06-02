import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_health/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessApp());
    expect(find.byType(FitnessApp), findsOneWidget);
  });
}
