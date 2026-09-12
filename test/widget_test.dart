import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trimly/app/app.dart';

void main() {
  testWidgets('Trimly foundation starts', (WidgetTester tester) async {
    await tester.pumpWidget(const TrimlyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
