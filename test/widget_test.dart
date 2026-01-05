// Basic app smoke test
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads without crashing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
