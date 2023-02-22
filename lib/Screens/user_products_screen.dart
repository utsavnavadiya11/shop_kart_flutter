import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_kart/Screens/edit_product_screen.dart';
import 'package:shop_kart/widgets/app_drawer.dart';

import '../provider/products.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  const UserProductsScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).loadAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: (_, index) {
              return Column(
                children: [
                  UserProductItem(
                      id: productsData.items[index].id,
                      title: productsData.items[index].title,
                      imageUrl: productsData.items[index].imageUrl),
                  const Divider(
                    thickness: 1.5,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
