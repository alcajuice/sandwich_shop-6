import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/app_styles.dart';
import 'package:sandwich_shop/models/auth.dart';
import 'package:sandwich_shop/views/login_screen.dart';
import 'package:sandwich_shop/views/order_screen.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';
import 'package:sandwich_shop/views/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;
  final int maxQuantity;

  const CartScreen({super.key, required this.cart, this.maxQuantity = 10});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _onCartChanged() => setState(() {});
  void _onAuthChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.cart.addListener(_onCartChanged);
    Auth.instance.addListener(_onAuthChanged);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _clampQuantitiesIfNeeded());
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
    Auth.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _goBack() => Navigator.pop(context);

  void _clampQuantitiesIfNeeded() {
    final List<String> clampedItems = [];
    for (final entry in widget.cart.items.entries) {
      final int qty = entry.value;
      if (qty > widget.maxQuantity) {
        widget.cart.updateItemQuantity(entry.key, widget.maxQuantity,
            maxQuantity: widget.maxQuantity);
        clampedItems.add(entry.key.name);
      }
    }

    if (clampedItems.isNotEmpty) {
      final names = clampedItems.take(3).join(', ');
      final more =
          clampedItems.length > 3 ? ' and ${clampedItems.length - 3} more' : '';
      _showMessage(
          'Some quantities reduced to max (${widget.maxQuantity}): $names$more');
    }
  }

  Future<bool> _showRemoveConfirmation(Sandwich sandwich, int quantity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${sandwich.name}?'),
        content: Text(
            'Remove $quantity ${_getSizeText(sandwich.isFootlong)} ${sandwich.name} from your cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove')),
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
                  decoration: InputDecoration(
                      hintText: 'Enter quantity (1-${widget.maxQuantity})',
                      errorText: errorText),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  final parsed = int.tryParse(controller.text);
                  if (parsed == null) {
                    setState(() => errorText = 'Please enter a number');
                    return;
                  }
                  if (parsed < 0) {
                    setState(
                        () => errorText = 'Number must be zero or greater');
                    return;
                  }
                  if (parsed > widget.maxQuantity) {
                    setState(() =>
                        errorText = 'Maximum ${widget.maxQuantity} allowed');
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

  Future<void> _navigateToCheckout() async {
    if (widget.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: widget.cart),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        widget.cart.clear();
      });

      final String orderId = result['orderId'] as String;
      final String estimatedTime = result['estimatedTime'] as String;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Order $orderId confirmed! Estimated time: $estimatedTime'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)));
  }

  String _getSizeText(bool isFootlong) => isFootlong ? 'Footlong' : 'Six-inch';

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
            height: 72,
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cart View',
              style: heading1,
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/about'),
              child: const Text(
                'about us',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                setState(() {});
              },
              child: Text(
                  Auth.instance.isLoggedIn ? Auth.instance.username! : 'Login'),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Builder(
                builder: (BuildContext context) {
                  final bool cartHasItems = widget.cart.items.isNotEmpty;
                  if (cartHasItems) {
                    return StyledButton(
                      onPressed: _navigateToCheckout,
                      icon: Icons.payment,
                      label: 'Checkout',
                      backgroundColor: Colors.orange,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
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
                                  widget.cart.updateItemQuantity(
                                    entry.key,
                                    entry.value - 1,
                                    maxQuantity: widget.maxQuantity,
                                  );
                                }
                              : () async {
                                  final confirmed =
                                      await _showRemoveConfirmation(
                                          entry.key, entry.value);
                                  if (confirmed == true) {
                                    final previousQty =
                                        widget.cart.removeCompletely(entry.key);
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('${entry.key.name} removed'),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: () {
                                            if (previousQty > 0) {
                                              widget.cart.add(entry.key,
                                                  quantity: previousQty);
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
                            final result = await _showQuantityInputDialog(
                                entry.key, entry.value);
                            if (result != null) {
                              if (result <= 0) {
                                final confirmed = await _showRemoveConfirmation(
                                    entry.key, result);
                                if (confirmed == true) {
                                  final previousQty =
                                      widget.cart.removeCompletely(entry.key);
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('${entry.key.name} removed'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          if (previousQty > 0) {
                                            widget.cart.add(entry.key,
                                                quantity: previousQty);
                                          }
                                        },
                                      ),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              } else if (result > widget.maxQuantity) {
                                _showMessage(
                                    'Maximum ${widget.maxQuantity} allowed per item');
                                widget.cart.updateItemQuantity(
                                    entry.key, widget.maxQuantity,
                                    maxQuantity: widget.maxQuantity);
                              } else {
                                widget.cart.updateItemQuantity(
                                    entry.key, result,
                                    maxQuantity: widget.maxQuantity);
                              }
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
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
                        Text(
                            '£${_getItemPrice(entry.key, entry.value).toStringAsFixed(2)}',
                            style: normalText),
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
