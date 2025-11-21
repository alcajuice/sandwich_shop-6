import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/main.dart';
import 'package:sandwich_shop/views/order_screen.dart';

void main() {
  group('App', () {
    testWidgets('renders OrderScreen as the home screen',
        (WidgetTester tester) async {
      const App app = App();
      await tester.pumpWidget(app);
      expect(find.byType(OrderScreen), findsOneWidget);
    });
  });
}
