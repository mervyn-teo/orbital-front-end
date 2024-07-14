import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbital/main.dart';
import 'package:orbital/pages/home.dart';
import 'package:orbital/pages/login.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void ignoreOverflowErrors(
  FlutterErrorDetails details, {
    bool forceReport = false,
  }) {
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
      FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
    }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late NavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

    testWidgets('Finding email', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: login(),
      ));
      await tester.pump();

      expect(find.byType(SafeArea), findsAny);
    });

    testWidgets('Login test with empty email', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      String sampleEmail = '';
      String samplePassword = 'asdfghj';

      await tester.pumpWidget(const MaterialApp(
        home: login(),
      ));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('login_email')), sampleEmail);
      await tester.enterText(find.byKey(const Key('login_password'),), samplePassword);
      await tester.tap(find.byKey(const Key('login_button')));

      await tester.pumpAndSettle();
      expect(find.byKey(const Key("empty_email_popup")), findsOneWidget);
  });

    testWidgets('Login test with empty password', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      String sampleEmail = 'testtest123@abc.com';
      String samplePassword = '';

      await tester.pumpWidget(const MaterialApp(
        home: login(),
      ));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('login_email')), sampleEmail);
      await tester.enterText(find.byKey(const Key('login_password'),), samplePassword);
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('login_button')));
        });
      await tester.pumpAndSettle();
      expect(find.byKey(const Key("empty_password_popup")), findsOneWidget);
  });

    testWidgets('Login test with illegal email', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      String sampleEmail = 'testtest123abccom';
      String samplePassword = 'asdfghj';

      await tester.pumpWidget(const MaterialApp(
        home: login(),
      ));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('login_email')), sampleEmail);
      await tester.enterText(find.byKey(const Key('login_password'),), samplePassword);
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('login_button')));
        });
      await tester.pumpAndSettle();
      expect(find.byKey(const Key("error_email_popup")), findsOneWidget);
  });

    testWidgets('Login test with incorrect email', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      String sampleEmail = 'testtest123@abc.com';
      String samplePassword = 'asdfghj';

      await tester.pumpWidget(MaterialApp(
        home: login(),
        navigatorObservers: [mockObserver],
      ));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('login_email')), sampleEmail);
      await tester.enterText(find.byKey(const Key('login_password'),), samplePassword);
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('login_button')));
        });
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const Key('error_login_failed')), findsOneWidget);
  });

    testWidgets('Login test with valid email', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      String sampleEmail = 'testtes123@abc.com';
      String samplePassword = 'asdfghj';

      await tester.pumpWidget(MaterialApp(
        home: login(),
        navigatorObservers: [mockObserver],
      ));
      await tester.pump();

      await tester.enterText(find.ancestor(
        of: find.text('E-mail'),
        matching: find.byType(TextField),
        ), sampleEmail);
      await tester.enterText(find.ancestor(
        of: find.text('Password'),
        matching: find.byType(TextField),
        ), samplePassword);
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('login_button')));
        });
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // expect(find.byKey(const Key('home_page')), findsAny);
  });
}