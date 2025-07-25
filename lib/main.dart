import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'consolidated_cart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open the box before runApp
  await Hive.openBox('cartBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consolidated Shopping Cart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ShoppingCartHome(),
    );
  }
}
