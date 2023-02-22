import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  String? userId;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.userId,
      this.isFavorite = false});

  void toggleIsFavoruite(String token, String userId, Product product) async {
    final url =
        'https://my-shop-4782e-default-rtdb.firebaseio.com/userFavorites/$userId/${product.id}.json?auth=$token';
    http
        .put(Uri.parse(url), body: json.encode(isFavorite))
        .then((_) => isFavorite = !isFavorite)
        .catchError((error) {
      //handle error!!
    });
    notifyListeners();
  }
}
