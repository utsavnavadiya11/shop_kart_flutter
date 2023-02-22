import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../provider/order.dart' as ord;

class OrderItems extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItems({super.key, required this.order});

  @override
  State<OrderItems> createState() => _OrderItemsState();
}

class _OrderItemsState extends State<OrderItems> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          ListTile(
            title: Text('₹${widget.order.amount.toStringAsFixed(2)}'),
            subtitle:
                Text(DateFormat('dd-M-yyyy, hh:mm').format(widget.order.time)),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
              ),
            ),
          ),
          if (_expanded)
            Container(
              height: min(widget.order.products.length * 35.0 + 10, 180),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: ListView(
                children: widget.order.products
                    .map(
                      (product) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${product.quantity}x ₹${product.price}',
                            style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey),
                          )
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
