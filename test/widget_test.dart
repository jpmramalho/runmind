import 'package:flutter_test/flutter_test.dart';
import 'package:runmind/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
  });
}
