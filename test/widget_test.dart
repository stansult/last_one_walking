import 'package:flutter_test/flutter_test.dart';

import 'package:last_one_walking/app/app.dart';

void main() {
  testWidgets('Create Walk screen builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Create Walk'), findsAtLeastNWidgets(1));
  });
}
