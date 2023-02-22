import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 1299.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 1599.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 199.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 1449.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // bool _showOnlyFavoruite = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoruiuteItems {
    return _items.where((element) => element.isFavorite == true).toList();
  }

  Product findByID(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  // void showOnlyFavoruites() {
  //   _showOnlyFavoruite = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showOnlyFavoruite = false;
  //   notifyListeners();
  // }
  String authToken;
  String userId;
  Products(this.authToken, this.userId, this._items);

  Future<void> loadAndSetProducts() async {
    try {
      String url =
          "https://my-shop-4782e-default-rtdb.firebaseio.com/products.json?auth=$authToken";
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData['error'] != null) {
        return;
      }
      url =
          "https://my-shop-4782e-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken&orderBy='userId'&equalTo='$userId'";
      final responseFav = await http.get(Uri.parse(url));
      final favoriteData = json.decode(responseFav.body);
      List<Product> loadedProducts = [];
      if (extractedData.isEmpty) {
        return;
      }
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite: favoriteData == null
                ? false
                : favoriteData[productId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://my-shop-4782e-default-rtdb.firebaseio.com/products.json?auth=$authToken";
    try {
      await http.post(
        Uri.parse(url),
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'userId': userId
        }),
      );
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  void updateProducts(String productId, Product product) {
    final productIndex =
        _items.indexWhere((element) => element.id == productId);
    if (productIndex >= 0) {
      _items[productIndex] = product;
      notifyListeners();
      //http.patch(url,json.encode({//'data':updatedData//}));
    }
  }

  void deleteProduct(String id) async {
    await http
        .delete(
          Uri.parse(
              'https://my-shop-4782e-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'),
        )
        .then((_) => _items.removeWhere((element) => element.id == id))
        .catchError((error) {
      // handle error here...
    });

    notifyListeners();
  }
}
