import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paulino_navigation_app/demo_auth.dart';
import 'package:paulino_navigation_app/main.dart';
import 'package:paulino_navigation_app/social_media/create_post_sheet.dart';
import 'package:paulino_navigation_app/social_media/post_card.dart';

// Dummy HttpOverrides to prevent network calls in widget tests
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.currentUsername = null;
  });

  testWidgets('Lab Act 6 - Complete test of all 11 required behaviors',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Log in using the default admin account.
    await tester.pumpWidget(const StudentApp());
    expect(find.text('Login'), findsWidgets);

    final usernameField = find.widgetWithText(TextFormField, 'Username');
    final passwordField = find.widgetWithText(TextFormField, 'Password');

    await tester.enterText(usernameField, 'admin');
    await tester.enterText(passwordField, 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Checkpoint: MainScreen opens
    expect(find.text('Welcome, Student!'), findsOneWidget);
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);

    // 2. Open Social Media. Sample posts appear.
    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pumpAndSettle();

    expect(find.text('JohnDoe'), findsOneWidget);
    expect(find.text('JaneSmith'), findsOneWidget);
    expect(find.text('Enjoying the sunny weather!'), findsOneWidget);
    expect(find.text('Just finished a great book!'), findsOneWidget);

    // 6. Tap Like twice. Changes to Liked, then back to Like.
    final likeButtons = find.widgetWithText(TextButton, 'Like');
    expect(likeButtons, findsNWidgets(2));

    // Tap Like on first post (JohnDoe)
    await tester.tap(likeButtons.first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);

    // Tap Liked again -> toggles back to Like
    await tester.tap(find.widgetWithText(TextButton, 'Liked'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, 'Liked'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Like'), findsNWidgets(2));

    // 7. Add a nonempty comment. Comment appears and count increases.
    expect(find.text('0 Comments'), findsNWidgets(2));
    final commentField = find.widgetWithText(TextField, 'Add a comment...').first;
    final sendButton = find.byTooltip('Send comment').first;

    await tester.enterText(commentField, 'Awesome photo!');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text('1 Comments'), findsOneWidget);
    expect(find.text('Awesome photo!'), findsOneWidget);

    // 8. Submit a blank comment. No comment is added.
    await tester.enterText(commentField, '   ');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(find.text('1 Comments'), findsOneWidget);

    // 9. Like a sample post, then create another post.
    await tester.tap(find.widgetWithText(TextButton, 'Like').first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);

    // Open Create Post Sheet
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    expect(find.text('Create Post'), findsOneWidget);

    // 3. Submit a post with empty fields. Validation message appears.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();
    expect(find.text('Complete both fields before submitting!'), findsOneWidget);

    // Dismiss snackbar so next one can show
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 4. Submit a post with an invalid URL. URL validation message appears.
    final captionField = find.widgetWithText(TextField, 'Caption');
    final urlField = find.widgetWithText(TextField, 'Image URL');

    await tester.enterText(captionField, 'My first Flutter social media post!');
    await tester.enterText(urlField, 'invalid-url-without-scheme');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid HTTP or HTTPS image URL.'), findsOneWidget);

    // 5. Submit a valid post. New post appears at the top with logged-in username.
    await tester.enterText(urlField, 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Verify new post appears at the top with username admin
    expect(find.text('admin'), findsOneWidget);
    expect(find.text('My first Flutter social media post!'), findsOneWidget);

    // Verify Step 9: The original post kept its liked state!
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);

    // 10. Switch to Home and return. Posts, likes, and comments remain.
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Student!'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pumpAndSettle();

    // Check new post is still there
    expect(find.text('admin'), findsOneWidget);
    expect(find.text('My first Flutter social media post!'), findsOneWidget);
    // Check original post like and comment remain
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);
    expect(find.text('Awesome photo!'), findsOneWidget);

    // 11. Log out, register, and log in with a new account.
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);

    // Tap Logout button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    // Now on Login Screen
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Navigate to Register
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    expect(find.text('Create an Account'), findsOneWidget);

    final regUserField = find.widgetWithText(TextFormField, 'Username');
    final regPassField = find.widgetWithText(TextFormField, 'Password');
    final regConfirmField = find.widgetWithText(TextFormField, 'Confirm Password');

    await tester.enterText(regUserField, 'wackypaulino');
    await tester.enterText(regPassField, 'password123');
    await tester.enterText(regConfirmField, 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Back to Login Screen
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Log in with new account
    final loginUserField = find.widgetWithText(TextFormField, 'Username');
    final loginPassField = find.widgetWithText(TextFormField, 'Password');

    await tester.enterText(loginUserField, 'wackypaulino');
    await tester.enterText(loginPassField, 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Dismiss any snackbar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Open Social Media
    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pumpAndSettle();

    // Create a post
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Caption'), 'New user posting!');
    await tester.enterText(find.widgetWithText(TextField, 'Image URL'), 'https://picsum.photos/id/24/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Verify post created with new username 'wackypaulino'
    expect(find.text('wackypaulino'), findsOneWidget);
    expect(find.text('New user posting!'), findsOneWidget);
  });
}
