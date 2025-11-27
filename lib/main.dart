import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/order_screen.dart';
import 'package:sandwich_shop/views/about_screen.dart';
import 'package:sandwich_shop/views/cart_screen.dart';
import 'package:sandwich_shop/views/checkout_screen.dart';
import 'package:sandwich_shop/views/login_screen.dart';
import 'package:sandwich_shop/models/cart.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sandwich Shop App',
      home: const OrderScreen(maxQuantity: 5),
      routes: {
        '/about': (context) => const AboutScreen(),
        '/cart': (context) => CartScreen(cart: appCart, maxQuantity: 5),
        '/checkout': (context) => CheckoutScreen(cart: appCart),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
