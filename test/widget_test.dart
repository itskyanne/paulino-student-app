import 'package:flutter_test/flutter_test.dart';
import 'package:paulino_navigation_app/main.dart';

void main() {
  testWidgets('App smoke test loads LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
