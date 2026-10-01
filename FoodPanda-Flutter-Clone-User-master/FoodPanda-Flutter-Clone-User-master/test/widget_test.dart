import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodpanda_user/main.dart';

void main() {
  testWidgets('students can browse and request a rental', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('flexshare-logo')), findsOneWidget);
    expect(find.text('Available nearby'), findsOneWidget);

    final item = find.text('Casio fx-991EX ClassWiz');
    await tester.scrollUntilVisible(
      item,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(item);
    await tester.pumpAndSettle();

    expect(find.text('P48'), findsOneWidget);
    await tester.tap(find.text('Hourly'));
    await tester.pumpAndSettle();
    expect(find.text('P9'), findsOneWidget);
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    final requestButton = find.text('Request to rent');
    await tester.ensureVisible(requestButton);
    await tester.pumpAndSettle();
    await tester.tap(requestButton);
    await tester.pumpAndSettle();
    expect(find.text('Request sent - pickup QR needed - 1 day'), findsOneWidget);

    await tester.tap(find.text('Scan pickup QR'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm pickup'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(
      FilledButton,
      'Confirm pickup',
    )).onPressed, isNull);

    await tester.tap(find.text('Capture condition photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm pickup'));
    await tester.pumpAndSettle();
    expect(find.text('Checked out - return QR needed - 1 day'), findsOneWidget);
    expect(find.text('Scan return QR'), findsOneWidget);
  });

  testWidgets('campus map tab opens', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Campus map'));
    await tester.pumpAndSettle();

    expect(find.text('Main campus map'), findsOneWidget);
    expect(find.text('MAIN GATE'), findsOneWidget);
    expect(find.text('Available on this map'), findsOneWidget);
    expect(find.text('Casio fx-991EX ClassWiz'), findsOneWidget);

    await tester.tap(find.text('Casio fx-991EX ClassWiz'));
    await tester.pumpAndSettle();
    expect(find.text('Request to rent'), findsOneWidget);
  });
}
