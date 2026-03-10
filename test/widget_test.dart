import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/core/constants/app_strings.dart';

void main() {
  testWidgets('app title renders in a basic scaffold', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text(AppStrings.appTitle)),
        ),
      ),
    );

    expect(find.text(AppStrings.appTitle), findsOneWidget);
  });
}
