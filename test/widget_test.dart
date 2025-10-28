// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Build a simple test widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test App')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Welcome to'),
                Text('Üçgül Forever', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify that our widget displays the expected text
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Üçgül Forever'), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });
}
