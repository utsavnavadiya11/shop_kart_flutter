import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../provider/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime time;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.time});
}

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];
  bool isLoading = false;
  final String token;

  Order(this.token, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        "https://my-shop-4782e-default-rtdb.firebaseio.com/orders.json?auth=$token";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedOrders =
          json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> dummyOrderList = [];
      if (extractedOrders.isEmpty) {
        return;
      }
      extractedOrders.forEach((id, orderItem) {
        dummyOrderList.add(OrderItem(
            id: id,
            amount: orderItem['amount'],
            products: (orderItem['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price']))
                .toList(),
            time: DateTime.parse(orderItem['dateTime'])));
      });
      _orders = dummyOrderList.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    isLoading = true;
    final url =
        "https://my-shop-4782e-default-rtdb.firebaseio.com/orders.json?auth=$token";
    final timeStamp = DateTime.now();
    try {
      await http
          .post(
            Uri.parse(url),
            body: json.encode({
              'amount': total,
              'dateTime': timeStamp.toIso8601String(),
              'products': cartProducts
                  .map((e) => {
                        'id': e.id,
                        'title': e.title,
                        'quantity': e.quantity,
                        'price': e.price,
                      })
                  .toList(),
            }),
          )
          .then((response) => {
                if (response.statusCode < 400)
                  {
                    _orders.insert(
                        0,
                        OrderItem(
                          id: json.decode(response.body)['name'],
                          amount: total,
                          products: cartProducts,
                          time: timeStamp,
                        )),
                    isLoading = false,
                    notifyListeners(),
                  }
              });
    } catch (error) {
      isLoading = false;
      rethrow;
    }
  }
}
