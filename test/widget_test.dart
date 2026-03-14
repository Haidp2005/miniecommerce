import 'package:flutter_test/flutter_test.dart';

import 'package:miniecommerce/app.dart';

void main() {
  testWidgets('app boots and renders home title', (WidgetTester tester) async {
    await tester.pumpWidget(const MiniEcommerceApp());
    await tester.pumpAndSettle();

    expect(find.text('TH4 - Nhom [So nhom]'), findsOneWidget);
  });
}
