import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/views/cart_screen.dart';

void main() {
  group('CartScreen widget tests', () {
    testWidgets(
        'increment, decrement and remove flow (with confirmation + snackbar undo)',
        (WidgetTester tester) async {
      final cart = Cart();

      final tuna = Sandwich(
        type: SandwichType.tunaMelt,
        isFootlong: false,
        breadType: BreadType.white,
      );

      cart.add(tuna, quantity: 1);

      await tester.pumpWidget(
          MaterialApp(home: CartScreen(cart: cart, maxQuantity: 5)));

      // initial quantity shown
      expect(find.text('Qty: 1'), findsOneWidget);

      // Tap the + icon to increase quantity to 2
      final addFinder = find.byIcon(Icons.add).first;
      await tester.tap(addFinder);
      await tester.pumpAndSettle();

      expect(find.text('Qty: 2'), findsOneWidget);

      // Tap the - icon once to decrement back to 1
      final removeFinder = find.byIcon(Icons.remove).first;
      await tester.tap(removeFinder);
      await tester.pumpAndSettle();

      expect(find.text('Qty: 1'), findsOneWidget);

      // Tap the - icon again to trigger the remove confirmation dialog
      await tester.tap(removeFinder);
      await tester.pump(); // show dialog

      // Confirm dialog present and tap the 'Remove' button
      expect(find.text('Remove'), findsWidgets); // at least the dialog button
      final removeButton = find.widgetWithText(TextButton, 'Remove').first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Item should be removed from the list
      expect(find.text(tuna.name), findsNothing);

      // Snackbar with removed message should be visible
      expect(find.text('${tuna.name} removed'), findsOneWidget);

      // Tap the Undo action on the snackbar
      final undoFinder = find.text('Undo');
      expect(undoFinder, findsOneWidget);
      await tester.tap(undoFinder);
      await tester.pumpAndSettle();

      // Item should be restored with previous quantity
      expect(find.text(tuna.name), findsOneWidget);
      expect(find.text('Qty: 1'), findsOneWidget);
    });
  });
}
