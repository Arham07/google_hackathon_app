import 'package:flutter_test/flutter_test.dart';
import 'package:google_hackathon_app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('App shows onboarding first', (WidgetTester tester) async {
    await tester.pumpWidget(const CiroApp());
    await tester.pumpAndSettle();

    expect(find.text('Pakistan needs you prepared'), findsOneWidget);
  });
}
