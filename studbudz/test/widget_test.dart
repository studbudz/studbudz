import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studubdz/main.dart';
import 'package:studubdz/notifier.dart';
import 'package:studubdz/UI/sign_in_page.dart';
import 'package:studubdz/UI/home_page.dart';

void main() {
  testWidgets('App opens and displays the correct initial page',
      (WidgetTester tester) async {
    // Initialize the Controller
    final controller = Controller();

    // Set the initial page to SignInPage
    controller.currentPage = AppPage.signIn;

    // Build the app with the real Controller
    await tester.pumpWidget(
      ChangeNotifierProvider<Controller>.value(
        value: controller,
        child: const MyApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the SignInPage is displayed
    expect(find.byType(SignInPage), findsOneWidget);

    // Simulate navigation to HomePage
    controller.setPage(AppPage.home);
    controller.notifyListeners(); // Notify listeners of the change
    await tester.pumpAndSettle(); // Wait for animations to complete

    // Verify that the HomePage is displayed
    expect(find.byType(HomePage), findsOneWidget);
  });
}
