import 'package:flutter_test/flutter_test.dart';
import 'package:google_hackathon_app/main.dart';

void main() {
  testWidgets('App loads map screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Karachi flood alerts'), findsOneWidget);
  });
}
