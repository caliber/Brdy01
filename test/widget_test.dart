import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brdy01/app/app.dart';

void main() {
  testWidgets('BrdyApp renders without crashing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BrdyApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
