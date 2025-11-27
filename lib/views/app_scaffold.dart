import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/app_styles.dart';
// No direct cart model import here; use named routes to navigate between pages.
// Auth import removed because login control moved out of scaffold

enum AppPage { order, cart, checkout, about }

class AppScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final AppPage selectedPage;
  final int maxQuantity;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.selectedPage,
    this.maxQuantity = 10,
    this.actions,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  void _navigateTo(AppPage page) {
    if (page == widget.selectedPage) return;
    String route;
    switch (page) {
      case AppPage.order:
        route = '/';
        break;
      case AppPage.cart:
        route = '/cart';
        break;
      case AppPage.checkout:
        route = '/checkout';
        break;
      case AppPage.about:
      default:
        route = '/about';
        break;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  Widget _buildDrawerContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.transparent),
          child: SizedBox(height: 72),
        ),
        ListTile(
          leading: const Icon(Icons.store),
          title: const Text('Order'),
          selected: widget.selectedPage == AppPage.order,
          onTap: () => _navigateTo(AppPage.order),
        ),
        ListTile(
          leading: const Icon(Icons.shopping_cart),
          title: const Text('Cart'),
          selected: widget.selectedPage == AppPage.cart,
          onTap: () => _navigateTo(AppPage.cart),
        ),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Checkout'),
          selected: widget.selectedPage == AppPage.checkout,
          onTap: () => _navigateTo(AppPage.checkout),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          selected: widget.selectedPage == AppPage.about,
          onTap: () => _navigateTo(AppPage.about),
        ),
        const Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    // Responsive: below 700 use Drawer; >=700 show NavigationRail permanently
    if (width < 700) {
      return Scaffold(
        appBar: AppBar(
          leading: SizedBox(
            width: 96,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                      height: 36,
                      width: 36,
                      child: Image.asset('assets/images/logo.png')),
                ),
                Builder(builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                }),
              ],
            ),
          ),
          title: Text(widget.title, style: heading1),
          centerTitle: true,
          actions: widget.actions,
        ),
        drawer: Drawer(child: _buildDrawerContent(context)),
        body: widget.body,
      );
    }

    // Wide layout: NavigationRail on the left, logo above it
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            height: 40,
            width: 40,
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        title: Text(widget.title, style: heading1),
        centerTitle: true,
        actions: widget.actions,
      ),
      body: Row(
        children: [
          // Left column with logo and navigation rail
          Container(
            width: 120,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                // Logo moved to AppBar title; keep spacing here for visual balance
                const SizedBox(height: 12),
                Expanded(
                  child: NavigationRail(
                    selectedIndex: AppPage.values.indexOf(widget.selectedPage),
                    onDestinationSelected: (index) =>
                        _navigateTo(AppPage.values[index]),
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                          icon: Icon(Icons.store), label: Text('Order')),
                      NavigationRailDestination(
                          icon: Icon(Icons.shopping_cart), label: Text('Cart')),
                      NavigationRailDestination(
                          icon: Icon(Icons.payment), label: Text('Checkout')),
                      NavigationRailDestination(
                          icon: Icon(Icons.info), label: Text('About')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: widget.body),
        ],
      ),
    );
  }
}
