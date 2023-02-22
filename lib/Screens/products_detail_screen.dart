import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = 'product-detail';

  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findByID(productId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30.0),
              Text(loadedProduct.title),
              const SizedBox(height: 10.0),
              Image.network(loadedProduct.imageUrl, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 10.0),
              Text(loadedProduct.description),
              const SizedBox(height: 10.0),
              Text(loadedProduct.price.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
