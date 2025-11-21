import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/app_styles.dart';
import 'package:sandwich_shop/views/order_screen.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;
  final int maxQuantity;

  const CartScreen({super.key, required this.cart, this.maxQuantity = 10});

  @override
  State<CartScreen> createState() {
    return _CartScreenState();
  }
}

class _CartScreenState extends State<CartScreen> {
  void _onCartChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.cart.addListener(_onCartChanged);
    // Ensure existing cart quantities respect the current maxQuantity.
    WidgetsBinding.instance.addPostFrameCallback((_) => _clampQuantitiesIfNeeded());
  }

  @override
  import 'package:flutter/material.dart';
  import 'package:sandwich_shop/views/app_styles.dart';
  import 'package:sandwich_shop/views/order_screen.dart';
  import 'package:sandwich_shop/models/cart.dart';
  import 'package:sandwich_shop/models/sandwich.dart';
  import 'package:sandwich_shop/repositories/pricing_repository.dart';

  class CartScreen extends StatefulWidget {
    final Cart cart;
    final int maxQuantity;

    const CartScreen({super.key, required this.cart, this.maxQuantity = 10});

    @override
    State<CartScreen> createState() {
      return _CartScreenState();
    }
  }

  class _CartScreenState extends State<CartScreen> {
    void _onCartChanged() => setState(() {});

    @override
    void initState() {
      super.initState();
      widget.cart.addListener(_onCartChanged);
      // Ensure existing cart quantities respect the current maxQuantity.
      WidgetsBinding.instance.addPostFrameCallback((_) => _clampQuantitiesIfNeeded());
    }

    @override
    void didUpdateWidget(covariant CartScreen oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (oldWidget.cart != widget.cart) {
        oldWidget.cart.removeListener(_onCartChanged);
        widget.cart.addListener(_onCartChanged);
      }
    }

    @override
    void dispose() {
      widget.cart.removeListener(_onCartChanged);
      super.dispose();
    }

    void _goBack() {
      Navigator.pop(context);
    }

    // Clamp quantities that exceed maxQuantity and notify the user once.
    void _clampQuantitiesIfNeeded() {
      final List<String> clampedItems = [];
      for (final entry in widget.cart.items.entries) {
        final int qty = entry.value;
        if (qty > widget.maxQuantity) {
          widget.cart.updateItemQuantity(entry.key, widget.maxQuantity, maxQuantity: widget.maxQuantity);
          clampedItems.add(entry.key.name);
        }
      }

      if (clampedItems.isNotEmpty) {
        final names = clampedItems.take(3).join(', ');
        final more = clampedItems.length > 3 ? ' and ${clampedItems.length - 3} more' : '';
        _showMessage('Some quantities reduced to max (${widget.maxQuantity}): $names$more');
      }
    }

    Future<bool> _showRemoveConfirmation(Sandwich sandwich, int quantity) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Remove ${sandwich.name}?'),
          content: Text('Remove $quantity ${_getSizeText(sandwich.isFootlong)} ${sandwich.name} from your cart?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Remove')),
          ],
        ),
      );
      return confirmed == true;
    }

    Future<int?> _showQuantityInputDialog(Sandwich sandwich, int current) async {
      final controller = TextEditingController(text: current.toString());
      String? errorText;

      final result = await showDialog<int?>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Set quantity for ${sandwich.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Enter quantity (1-${widget.maxQuantity})', errorText: errorText),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    final parsed = int.tryParse(controller.text);
                    if (parsed == null) {
                      setState(() => errorText = 'Please enter a number');
                      return;
                    }
                    if (parsed < 0) {
                      setState(() => errorText = 'Number must be zero or greater');
                      return;
                    }
                    if (parsed > widget.maxQuantity) {
                      setState(() => errorText = 'Maximum ${widget.maxQuantity} allowed');
                      return;
                    }
                    Navigator.of(context).pop(parsed);
                  },
                  child: const Text('Set'),
                ),
              ],
            );
          });
        },
      );

      return result;
    }

    void _showMessage(String message) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 3)));
    }

    String _getSizeText(bool isFootlong) {
      if (isFootlong) {
        return 'Footlong';
      } else {
        return 'Six-inch';
      }
    }

    double _getItemPrice(Sandwich sandwich, int quantity) {
      final PricingRepository pricingRepository = PricingRepository();
      return pricingRepository.calculatePrice(
        quantity: quantity,
        isFootlong: sandwich.isFootlong,
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 100,
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          title: const Text(
            'Cart View',
            style: heading1,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                for (MapEntry<Sandwich, int> entry in widget.cart.items.entries)
                  Column(
                    children: [
                      Text(entry.key.name, style: heading2),
                      Text(
                        '${_getSizeText(entry.key.isFootlong)} on ${entry.key.breadType.name} bread',
                        style: normalText,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: 'Decrease quantity',
                            onPressed: entry.value > 1
                                ? () {
                                    // decrement by 1
                                    widget.cart.updateItemQuantity(
                                      entry.key,
                                      entry.value - 1,
                                      maxQuantity: widget.maxQuantity,
                                    );
                                  }
                                : () async {
                                    // if at 1, confirm removal
                                    final confirmed = await _showRemoveConfirmation(entry.key, entry.value);
                                    if (confirmed == true) {
                                      final previousQty = widget.cart.removeCompletely(entry.key);
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${entry.key.name} removed'),
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () {
                                              if (previousQty > 0) {
                                                widget.cart.add(entry.key, quantity: previousQty);
                                              }
                                            },
                                          ),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.remove),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final result = await _showQuantityInputDialog(entry.key, entry.value);
                              if (result != null) {
                                if (result <= 0) {
                                  final confirmed = await _showRemoveConfirmation(entry.key, result);
                                  if (confirmed == true) {
                                    final previousQty = widget.cart.removeCompletely(entry.key);
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${entry.key.name} removed'),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: () {
                                            if (previousQty > 0) {
                                              widget.cart.add(entry.key, quantity: previousQty);
                                            }
                                          },
                                        ),
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                } else if (result > widget.maxQuantity) {
                                  _showMessage('Maximum ${widget.maxQuantity} allowed per item');
                                  widget.cart.updateItemQuantity(entry.key, widget.maxQuantity, maxQuantity: widget.maxQuantity);
                                } else {
                                  widget.cart.updateItemQuantity(entry.key, result, maxQuantity: widget.maxQuantity);
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text('Qty: ${entry.value}', style: heading2),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Increase quantity',
                            onPressed: entry.value < widget.maxQuantity
                                ? () {
                                    widget.cart.updateItemQuantity(
                                      entry.key,
                                      entry.value + 1,
                                      maxQuantity: widget.maxQuantity,
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                          const SizedBox(width: 12),
                          Text('£${_getItemPrice(entry.key, entry.value).toStringAsFixed(2)}', style: normalText),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                Text(
                  'Total: £${widget.cart.totalPrice.toStringAsFixed(2)}',
                  style: heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                StyledButton(
                  onPressed: _goBack,
                  icon: Icons.arrow_back,
                  label: 'Back to Order',
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }
  }
}
