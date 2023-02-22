import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../provider/order.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});
  static const routeName = '/order-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      drawer: const AppDrawer(),
      body: FutureBuilder(
          future:
              Provider.of<Order>(context, listen: false).fetchAndSetOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.error != null) {
              return const Center(child: Text('Some Error has Occurd!'));
            } else {
              return Consumer<Order>(
                builder: (context, orderData, child) {
                  return orderData.orders.isEmpty
                      ? const Center(
                          child: Text('No Orders Yet!!'),
                        )
                      : ListView.builder(
                          itemBuilder: (context, index) =>
                              OrderItems(order: orderData.orders[index]),
                          itemCount: orderData.orders.length,
                        );
                },
              );
            }
          }),
    );
  }
}
