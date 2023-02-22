import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_kart/provider/product.dart';

import '../provider/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-products';
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  Product _editedProduct =
      Product(id: '', title: '', description: '', price: 0.0, imageUrl: '');

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() {
    _formKey.currentState?.save();
    setState(() {
      isLoading = true;
    });
    _formKey.currentState?.validate();
    Provider.of<Products>(context, listen: false)
        .addProduct(_editedProduct)
        .catchError((error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Some Error Ocuured!!'),
          content: Text(error.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: const Text('Ok')),
          ],
        ),
      );
    });
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.done))
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (newValue) {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              title: newValue!,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter a Title!";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Price'),
                        focusNode: _priceFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (newValue) {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: double.parse(newValue!),
                              imageUrl: _editedProduct.imageUrl);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter a Price!";
                          } else if (double.tryParse(value) == null) {
                            return "Enter Valid Price";
                          } else if (double.parse(value) < 0) {
                            return "Price Shouldbe greater than 0.";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        focusNode: _descriptionFocusNode,
                        keyboardType: TextInputType.multiline,
                        onSaved: (newValue) {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: newValue!,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter a Description!";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                        ),
                        child: _imageUrlController.text.isEmpty
                            ? const Center(child: Text('Enter Url'))
                            : FittedBox(
                                child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Image Url'),
                        keyboardType: TextInputType.url,
                        controller: _imageUrlController,
                        textInputAction: TextInputAction.done,
                        onSaved: (newValue) {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: newValue!);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter a Image Url!";
                          }
                          // else if (!value.endsWith('.png') &&
                          //     !value.endsWith('.jpg') &&
                          //     !value.endsWith('.jpeg')) {
                          //   return "Please Enter Valid Url";
                          // }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
