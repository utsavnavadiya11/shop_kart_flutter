import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/products.dart';
import '../widgets/app_drawer.dart';
import '../Screens/cart_screen.dart';
import '../provider/cart.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

enum FilterValue {
  // ignore: constant_identifier_names
  Favoruites,
  // ignore: constant_identifier_names
  All
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});
  static const routeName = '/product-overview';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavoruites = false;
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).loadAndSetProducts().then((_) {
          _isLoading = false;
      }).catchError((error) {
          _isLoading = false;
        // ignore: invalid_return_type_for_catch_error
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('Some Error has Occured!!'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        child: const Text('Ok'))
                  ],
                ));
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ShopKart',
          style: TextStyle(fontSize: 25, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            onSelected: (FilterValue selectedValue) {
              setState(() {
                if (selectedValue == FilterValue.Favoruites) {
                  _showOnlyFavoruites = true;
                } else {
                  _showOnlyFavoruites = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterValue.Favoruites,
                child: Text('Only Favoruites'),
              ),
              const PopupMenuItem(
                value: FilterValue.All,
                child: Text('Show All'),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              value: cart.itemCount.toString(),
              color: Theme.of(context).colorScheme.secondary,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: const Icon(Icons.shopping_cart),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductsGrid(showFavs: _showOnlyFavoruites),
    );
  }
}
