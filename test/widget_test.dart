import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukl_kelas11/main.dart';

void main() {
  testWidgets('app builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const LabTrackApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
