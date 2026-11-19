import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paulino_navigation_app/demo_auth.dart';
import 'package:paulino_navigation_app/main.dart';

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.currentUsername = null;
  });

  testWidgets('Integration Activity - Complete test of all 14 required behaviors',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Open the application. Login appears first.
    await tester.pumpWidget(const StudentApp());
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);

    final usernameField = find.widgetWithText(TextFormField, 'Username');
    final passwordField = find.widgetWithText(TextFormField, 'Password');

    // 2. Submit empty login fields. Validation messages appear.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);

    // 3. Enter incorrect credentials. Login is rejected.
    await tester.enterText(usernameField, 'wronguser');
    await tester.enterText(passwordField, 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid username or password.'), findsOneWidget);

    // Dismiss snackbar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 4. Enter admin / admin123. Dashboard opens.
    await tester.enterText(usernameField, 'admin');
    await tester.enterText(passwordField, 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // 5. Read the dashboard greeting. Displays Welcome, admin!
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Welcome, admin!'), findsOneWidget);

    // 6. Open Calculator and calculate 10 + 5. Displays 15.0.
    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    expect(find.text('My Stateful Calculator'), findsOneWidget);

    final calcFirstField = find.widgetWithText(TextField, 'First Number');
    final calcSecondField = find.widgetWithText(TextField, 'Second Number');
    await tester.enterText(calcFirstField, '10');
    await tester.enterText(calcSecondField, '5');
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pumpAndSettle();
    expect(find.text('15.0'), findsOneWidget);

    // 7. Switch tabs and return to Calculator. Inputs and result remain.
    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    expect(find.text('15.0'), findsOneWidget);

    // 8. Open Social and create a social post. Post displays the logged-in username.
    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();
    expect(find.text('JohnDoe'), findsOneWidget);

    // Open Create Post Sheet
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    final captionField = find.widgetWithText(TextField, 'Caption');
    final urlField = find.widgetWithText(TextField, 'Image URL');
    await tester.enterText(captionField, 'My first Flutter social media post!');
    await tester.enterText(urlField, 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Verify post displays admin
    expect(find.text('admin'), findsOneWidget);
    expect(find.text('My first Flutter social media post!'), findsOneWidget);

    // 9. Like a post and add a comment. Both interactions update correctly.
    await tester.tap(find.widgetWithText(TextButton, 'Like').first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);

    final commentField = find.widgetWithText(TextField, 'Add a comment...').first;
    final sendButton = find.byTooltip('Send comment').first;
    await tester.enterText(commentField, 'Awesome photo!');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(find.text('1 Comments'), findsOneWidget);
    expect(find.text('Awesome photo!'), findsOneWidget);

    // 10. Switch tabs and return to Social. Posts, likes, and comments remain.
    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();

    expect(find.text('admin'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);
    expect(find.text('Awesome photo!'), findsOneWidget);

    // 11. Open Profile. Student information and username appear.
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Student Profile'), findsOneWidget);
    expect(find.text('Wacky Yuan Dwayne Paulino'), findsOneWidget);
    expect(find.text('Logged in as: admin'), findsOneWidget);
    expect(find.text('553682'), findsOneWidget);

    // 12. Tap Logout. Login appears; Back does not reopen MainScreen.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back!'), findsOneWidget);

    // 13. Register a valid account and log in. Dashboard displays the registered username.
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    final regUserField = find.widgetWithText(TextFormField, 'Username');
    final regPassField = find.widgetWithText(TextFormField, 'Password');
    final regConfirmField = find.widgetWithText(TextFormField, 'Confirm Password');

    await tester.enterText(regUserField, 'wackypaulino');
    await tester.enterText(regPassField, 'password123');
    await tester.enterText(regConfirmField, 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Back on Login
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Dismiss registration snackbar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    final loginUser = find.widgetWithText(TextFormField, 'Username');
    final loginPass = find.widgetWithText(TextFormField, 'Password');
    await tester.enterText(loginUser, 'wackypaulino');
    await tester.enterText(loginPass, 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Verify dashboard displays registered username
    expect(find.text('Welcome, wackypaulino!'), findsOneWidget);

    // 14. Create a post using the registered account. Post displays registered username.
    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Caption'), 'Post from newly registered user!');
    await tester.enterText(find.widgetWithText(TextField, 'Image URL'), 'https://picsum.photos/id/24/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    expect(find.text('wackypaulino'), findsOneWidget);
    expect(find.text('Post from newly registered user!'), findsOneWidget);
  });
}
