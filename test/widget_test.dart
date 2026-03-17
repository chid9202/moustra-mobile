import 'package:flutter_test/flutter_test.dart';

import 'package:grid_view/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // App should show the Moustra title in the AppBar
    expect(find.text('Moustra'), findsOneWidget);
  });
}
