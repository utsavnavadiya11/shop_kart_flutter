import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './provider/auth.dart';
import './provider/order.dart';
import './provider/cart.dart';
import './provider/products.dart';
import './Screens/splash_screen.dart';
import './Screens/products_overview_screen.dart';
import './Screens/edit_product_screen.dart';
import './Screens/user_products_screen.dart';
import './Screens/orders_screen.dart';
import './Screens/cart_screen.dart';
import './Screens/products_detail_screen.dart';
import './Screens/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products('', '', []),
          update: (_, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts != null ? [] : previousProducts!.items),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (context) => Order('', []),
          update: (_, auth, previousOrders) => Order(
              auth.token, previousOrders != null ? [] : previousOrders!.orders),
        ),
        ChangeNotifierProvider.value(value: Cart()),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                .copyWith(secondary: Colors.white),
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.autoLogin(context),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            ProductsOverviewScreen.routeName: (ctx) =>
                const ProductsOverviewScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrderScreen.routeName: (ctx) => const OrderScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
          },
        ),
      ),
    );
  }
}
