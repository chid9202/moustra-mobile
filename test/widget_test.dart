// Basic app smoke test
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moustra/main.dart';

void main() {
  setUpAll(() async {
    // Initialize dotenv - try loading .env file if it exists, otherwise use empty initialization
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file doesn't exist or can't be loaded, initialize with empty values
      // Env class will use fallback values
      dotenv.env.clear();
    }
  });

  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the app loads without crashing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
