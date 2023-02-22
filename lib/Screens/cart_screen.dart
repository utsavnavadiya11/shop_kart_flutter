import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_item.dart';
import '../provider/cart.dart' show Cart;
import '../provider/order.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final order = Provider.of<Order>(context);
    final currentContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '₹${(cart.totalAmount).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  TextButton(
                      onPressed: cart.totalAmount <= 0
                          ? null
                          : () {
                              Provider.of<Order>(context, listen: false)
                                  .addOrder(cart.items.values.toList(),
                                      cart.totalAmount)
                                  .then((_) => {
                                        ScaffoldMessenger.of(currentContext)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                          'Order Placed Succesfully!',
                                          textAlign: TextAlign.center,
                                        )))
                                      });
                              cart.clear();
                            },
                      child: order.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Text(
                              'ORDER NOW',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ))
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) => CartItems(
                  id: cart.items.values.toList()[index].id,
                  productId: cart.items.keys.toList()[index],
                  title: cart.items.values.toList()[index].title,
                  quantity: cart.items.values.toList()[index].quantity,
                  price: cart.items.values.toList()[index].price),
              itemCount: cart.items.length,
            ),
          ),
        ],
      ),
    );
  }
}
