import 'package:flutter/foundation.dart';
import 'sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

class Cart extends ChangeNotifier {
  final Map<Sandwich, int> _items = {};

  // Returns a read-only copy of the items and their quantities
  Map<Sandwich, int> get items => Map.unmodifiable(_items);

  /// Adds [quantity] of [sandwich] to the cart.
  /// Notifies listeners after mutation.
  void add(Sandwich sandwich, {int quantity = 1}) {
    if (_items.containsKey(sandwich)) {
      _items[sandwich] = _items[sandwich]! + quantity;
    } else {
      _items[sandwich] = quantity;
    }
    notifyListeners();
  }

  /// Removes [quantity] of [sandwich] from the cart. If quantity drops to
  /// zero or below the item is removed completely. Notifies listeners.
  void remove(Sandwich sandwich, {int quantity = 1}) {
    if (_items.containsKey(sandwich)) {
      final currentQty = _items[sandwich]!;
      if (currentQty > quantity) {
        _items[sandwich] = currentQty - quantity;
      } else {
        _items.remove(sandwich);
      }
      notifyListeners();
    }
  }

  /// Removes the item entirely and returns its previous quantity (0 if not present).
  /// Useful for implementing undo in the UI.
  int removeCompletely(Sandwich sandwich) {
    final previous = _items.remove(sandwich) ?? 0;
    if (previous > 0) notifyListeners();
    return previous;
  }

  /// Update the quantity of an existing item to [quantity]. If quantity <= 0
  /// the item is removed. Optionally provide [maxQuantity] to clamp the value.
  /// Returns the final quantity for the item (0 if removed).
  int updateItemQuantity(Sandwich sandwich, int quantity, {int? maxQuantity}) {
    if (quantity <= 0) {
      final removed = _items.remove(sandwich) ?? 0;
      if (removed > 0) notifyListeners();
      return 0;
    }

    int finalQty = quantity;
    if (maxQuantity != null && finalQty > maxQuantity) {
      finalQty = maxQuantity;
    }

    _items[sandwich] = finalQty;
    notifyListeners();
    return finalQty;
  }

  /// Edit an existing item [oldSandwich] to become [newSandwich]. If another
  /// identical [newSandwich] already exists in the cart the quantities are
  /// merged. If [maxQuantity] is provided the merged quantity will be clamped.
  /// Returns a map with keys:
  /// - 'merged': bool whether a merge happened
  /// - 'finalQuantity': int final quantity for the newSandwich entry
  Map<String, dynamic> editItem(Sandwich oldSandwich, Sandwich newSandwich, {int? maxQuantity}) {
    if (!_items.containsKey(oldSandwich)) {
      return {'merged': false, 'finalQuantity': 0};
    }

    final int oldQty = _items.remove(oldSandwich)!;

    if (_items.containsKey(newSandwich)) {
      int combined = _items[newSandwich]! + oldQty;
      if (maxQuantity != null && combined > maxQuantity) {
        combined = maxQuantity;
      }
      _items[newSandwich] = combined;
      notifyListeners();
      return {'merged': true, 'finalQuantity': combined};
    } else {
      int qtyToSet = oldQty;
      if (maxQuantity != null && qtyToSet > maxQuantity) {
        qtyToSet = maxQuantity;
      }
      _items[newSandwich] = qtyToSet;
      notifyListeners();
      return {'merged': false, 'finalQuantity': qtyToSet};
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    final pricingRepository = PricingRepository();
    double total = 0.0;

    for (Sandwich sandwich in _items.keys) {
      int quantity = _items[sandwich]!;
      total += pricingRepository.calculatePrice(
        quantity: quantity,
        isFootlong: sandwich.isFootlong,
      );
    }

    return total;
  }

  bool get isEmpty => _items.isEmpty;

  int get length => _items.length;

  int get countOfItems {
    int total = 0;
    for (Sandwich sandwich in _items.keys) {
      total += _items[sandwich]!;
    }
    return total;
  }

  int getQuantity(Sandwich sandwich) {
    if (_items.containsKey(sandwich)) {
      return _items[sandwich]!;
    }
    return 0;
  }
}
