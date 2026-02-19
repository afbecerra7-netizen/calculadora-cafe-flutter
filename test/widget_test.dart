import 'package:cafe_flutter_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders app shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CafeApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
