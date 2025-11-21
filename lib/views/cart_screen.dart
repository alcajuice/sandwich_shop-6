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
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Remove ${entry.key.name}?'),
                                      content: Text(
                                          'Remove ${entry.value} ${_getSizeText(entry.key.isFootlong)} ${entry.key.name} from your cart?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
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
                            // numeric input dialog
                            final TextEditingController controller =
                                TextEditingController(
                                    text: entry.value.toString());
                            final result = await showDialog<int?>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title:
                                    Text('Set quantity for ${entry.key.name}'),
                                content: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText:
                                          'Enter quantity (1-${widget.maxQuantity})'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(null),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final parsed =
                                          int.tryParse(controller.text);
                                      Navigator.of(context).pop(parsed);
                                    },
                                    child: const Text('Set'),
                                  ),
                                ],
                              ),
                            );

                            if (result != null) {
                              if (result <= 0) {
                                // prompt removal
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Remove ${entry.key.name}?'),
                                    content: Text(
                                        'Set quantity to ${result} will remove the item. Remove?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Remove')),
                                    ],
                                  ),
                                );
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Maximum ${widget.maxQuantity} allowed per item')),
                                );
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
