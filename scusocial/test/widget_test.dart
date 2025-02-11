import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scusocial/main.dart';

// Tests the MyCustomForm class
void main() {
  // Checks form is correctly formatted
  testWidgets('MyCustomForm has a title and a form',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify the title is displayed
    expect(find.text('Form Validation Demo'), findsOneWidget);

    // Verify the form fields are displayed
    expect(find.byType(TextFormField), findsNWidgets(3));
  });
  // verifies validation logic works
  testWidgets('Form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap the submit button without entering any text
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify the validation messages are displayed
    expect(find.text('Group Name'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);

    // Enter text into the form fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Group');
    await tester.enterText(find.byType(TextFormField).at(1), 'Active');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'This is a test group.');

    // Tap the submit button again
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify the validation messages are not displayed
    expect(find.text('Group Name'), findsNothing);
    expect(find.text('Status'), findsNothing);
    expect(find.text('Description'), findsNothing);

    // Verify the snackbar is displayed
    expect(find.text('Submitted'), findsOneWidget);
  });
  // error messages are displayed when fields are empty
  testWidgets('Form displays error messages when fields are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap the submit button without entering any text
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify the validation messages are displayed
    expect(find.text('Group Name'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });
  // no error messages are shown when the form fields are filled
  testWidgets('Form does not display error messages when fields are filled',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Enter text into the form fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Group');
    await tester.enterText(find.byType(TextFormField).at(1), 'Active');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'This is a test group.');

    // Tap the submit button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify the validation messages are not displayed
    expect(find.text('Group Name'), findsNothing);
    expect(find.text('Status'), findsNothing);
    expect(find.text('Description'), findsNothing);
  });

  // Cecks snackbar is displayed
  testWidgets('Submit text is displayed when form is valid',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Enter text into the form fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Group');
    await tester.enterText(find.byType(TextFormField).at(1), 'Active');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'This is a test group.');

    // Tap the submit button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify the snackbar is displayed
    expect(find.text('Submitted'), findsOneWidget);
  });
  // Form field are cleared once form is submitted
  testWidgets('Form fields can be cleared', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Enter text into the form fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Group');
    await tester.enterText(find.byType(TextFormField).at(1), 'Active');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'This is a test group.');

    // Clear the form fields
    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.enterText(find.byType(TextFormField).at(2), '');

    // Verify the form fields are empty
    expect(find.text('Test Group'), findsNothing);
    expect(find.text('Active'), findsNothing);
    expect(find.text('This is a test group.'), findsNothing);
  });
}
