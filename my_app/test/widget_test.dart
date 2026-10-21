import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('ServiceDeskApp renders login or main shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ServiceDeskApp());
    expect(find.text('IT Service Desk'), findsWidgets);
  });
}
