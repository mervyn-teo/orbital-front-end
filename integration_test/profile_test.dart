import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignores overflow errors
void ignoreOverflowErrors(
    FlutterErrorDetails details, {
    bool forceReport = false,
  }) {
    final originalOnError = FlutterError.onError!;

    bool ifIsOverflowError = false;
    bool isUnableToLoadAsset = false;
    // Detect overflow error.
    var exception = details.exception;
    if (exception is FlutterError) {
      ifIsOverflowError = !exception.diagnostics.any(
        (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
      );
      isUnableToLoadAsset = !exception.diagnostics.any(
        (e) => e.value.toString().startsWith("Unable to load asset"),
      );
    }

    // Ignore if is overflow error.
    if (ifIsOverflowError || isUnableToLoadAsset) {
      debugPrint('Ignored Error');
    } else {
      originalOnError(details);
    }
}


void main() {
  SharedPreferences prefs; 

  setUp(() async {
    prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', 'Bob');
    await prefs.setString('bio', 'Bob the builder');
    await prefs.setInt('age', 12);
    await prefs.setString('id', '69');
    await prefs.setString('pfp', 'https://robohash.org/cumblanditiisnecessitatibus.png?size=50x50&set=set1');
    await prefs.setBool('hasLoggedIn', true);
  });

  testWidgets('Finding safe area (ensures that everything runs)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: homePage(),
      ));
      await tester.pump();

      expect(find.byType(SafeArea), findsAny);
  });

  testWidgets('Navigation to profile page', (WidgetTester tester) async {
    FlutterError.onError = ignoreOverflowErrors;

    await tester.pumpWidget(const MaterialApp(
      home: homePage(),
    ));
    await tester.pump();

    await tester.tap(find.ancestor(
      of: find.text('Profile'),
      matching: find.byType(NavigationDestination),
    ));

    await tester.pumpAndSettle();

  });

    testWidgets('add tags', (WidgetTester tester) async {

    await tester.pumpWidget(const MaterialApp(
      home: homePage(),
    ));
    await tester.pump();

    await tester.tap(find.ancestor(
      of: find.text('Profile'),
      matching: find.byType(NavigationDestination),
    ));

    await tester.pumpAndSettle();

    await tester.tap(find.ancestor(
      of: find.text('+'),
      matching: find.byType(Card),
    ));

    await tester.pumpAndSettle();
    
    await tester.enterText(find.ancestor(
      of: find.text('e.g. fishing'),
      matching: find.byType(TextField),
    ), "eating");

    await tester.tap(find.ancestor(
      of: find.text('OK'),
      matching: find.byType(MaterialButton),
    ));

    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.text("eating"), findsAny);
  });
}