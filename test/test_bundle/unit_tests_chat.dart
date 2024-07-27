import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orbital/pages/chat.dart'; // Replace with your actual import path
import 'package:orbital/Profile.dart'; // Replace with your actual import path

// Mock SharedPreferences for testing purposes
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Mock HTTP client for mocking network requests
class MockClient extends Mock implements http.Client {}

void main() {
  group('myChat Widget Tests', () {
    late MockSharedPreferences mockSharedPreferences;
    late MockClient mockClient;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockClient = MockClient();
    });

    testWidgets('AppBar displays correct profile information', (WidgetTester tester) async {
      // Create a mock profile
      Profile mockProfile = Profile(
        'John Doe',
        '1',
        25,
        'Software Developer',
        'http://example.com/profile.jpg',
      );

      // Mock necessary data and preferences
      when(mockSharedPreferences.getString('id')).thenReturn('mocked_id');

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              settings: RouteSettings(arguments: {'oppProfile' : mockProfile}),
              builder: (context) {
                return myChat();
              },
            );
          },
        ));

      // Verify that the app bar shows the correct profile information
      expect(find.text(mockProfile.name), findsOneWidget);
      expect(find.text('Software Developer'), findsOneWidget); // Check bio
      expect(find.byType(Image), findsOneWidget); // Check profile picture
    });

    testWidgets('Sending a message updates the UI', (WidgetTester tester) async {
      // Create a mock profile
      Profile mockProfile = Profile(
        'John Doe',
        '1',
        25,
        'Software Developer',
        'http://example.com/profile.jpg',
      );

      // Mock the sendMessage function response
      when(mockClient.post(Uri.parse('http://13.231.75.235:8080/sendMessage'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode({
                'err_msg': 'ok',
                'body': [
                  {
                    'id_from': 'mocked_id',
                    'id_to': mockProfile.id,
                    'msg': 'Hello',
                    'time_sent': DateTime.now().toIso8601String(),
                    'msg_id': '1',
                  }
                ]
              }), 200));

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              settings: RouteSettings(arguments: {'oppProfile' : mockProfile}),
              builder: (context) {
                return myChat();
              },
            );
          },
        ));

      // Enter text in the message field and tap send button
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify that the sent message appears in the UI
      expect(find.text('Hello'), findsOneWidget);
    });

    // Add more tests for other scenarios as needed
  });
}
