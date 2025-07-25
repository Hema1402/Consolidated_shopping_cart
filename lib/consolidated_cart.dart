import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ShoppingCartHome extends StatefulWidget {
  final String? c0;
  final String? c1;
  final String? o1;
  final String? o2;
  final String? sessionId;

  const ShoppingCartHome({
    Key? key,
    this.c0,
    this.c1,
    this.o1,
    this.o2,
    this.sessionId,
  }) : super(key: key);

  @override
  State<ShoppingCartHome> createState() => _ShoppingCartHomeState();
}

class _ShoppingCartHomeState extends State<ShoppingCartHome> {
  late Box box;
  List<Map<String, dynamic>> carts = [];

  late String? c0;
  late String? c1;
  late String? o1;
  late String? o2;

  @override
  void initState() {
    super.initState();
    box = Hive.box('cartBox');
    c0 = widget.c0;
    c1 = widget.c1;
    o1 = widget.o1;
    o2 = widget.o2;
    loadCarts();
  }

  void loadCarts() {
    final saved = box.get('carts');
    if (saved != null && saved is List) {
      carts = List<Map<String, dynamic>>.from(
        saved.map((e) => Map<String, dynamic>.from(e)),
      );
    }
    setState(() {});
  }

  void saveCarts() {
    box.put('carts', carts);
  }

  void updateField(int index, String key, dynamic value) {
    carts[index][key] = value;
    saveCarts();
    setState(() {});
  }

  void addNewCart() {
    carts.add({
      'ref': 'A00${carts.length + 1}',
      'buyerName': '',
      'notes': '',
      'itemAmount': 0.0,
      'discount': 0.0,
      'salesTax': 0.0,
      'paidSalesTax': false,
    });
    saveCarts();
    setState(() {});
  }

  void deleteCart(int index) {
    carts.removeAt(index);
    saveCarts();
    setState(() {});
  }

  double calcGross(Map<String, dynamic> cart) =>
      (cart['itemAmount'] ?? 0.0) - (cart['discount'] ?? 0.0);

  double calcFinal(Map<String, dynamic> cart) =>
      calcGross(cart) + (cart['salesTax'] ?? 0.0);

  Widget buildCartTile(int index) {
    final cart = carts[index];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("🛒 Ref: ${cart['ref']}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => deleteCart(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              )
            ],
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Buyer Name"),
            controller: TextEditingController(text: cart['buyerName'])
              ..selection = TextSelection.collapsed(
                  offset: cart['buyerName']?.length ?? 0),
            onChanged: (v) => updateField(index, 'buyerName', v),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Item Amount"),
                  controller: TextEditingController(
                      text: "${cart['itemAmount'] ?? 0}")
                    ..selection = TextSelection.collapsed(
                        offset: "${cart['itemAmount']}".length),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => updateField(
                      index, 'itemAmount', double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Discount"),
                  controller: TextEditingController(
                      text: "${cart['discount'] ?? 0}")
                    ..selection = TextSelection.collapsed(
                        offset: "${cart['discount']}".length),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      updateField(index, 'discount', double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Sales Tax"),
                  controller: TextEditingController(
                      text: "${cart['salesTax'] ?? 0}")
                    ..selection = TextSelection.collapsed(
                        offset: "${cart['salesTax']}".length),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      updateField(index, 'salesTax', double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Paid Tax"),
                  Switch(
                    value: cart['paidSalesTax'] ?? false,
                    onChanged: (val) =>
                        updateField(index, 'paidSalesTax', val),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("Gross: ₹${calcGross(cart).toStringAsFixed(2)}"),
          Text("Final: ₹${calcFinal(cart).toStringAsFixed(2)}"),
          const SizedBox(height: 4),
          TextField(
            decoration: const InputDecoration(labelText: "Notes"),
            controller: TextEditingController(text: cart['notes'])
              ..selection =
                  TextSelection.collapsed(offset: cart['notes']?.length ?? 0),
            onChanged: (v) => updateField(index, 'notes', v),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛍 Consolidated Cart"),
        backgroundColor: const Color(0xFFFF9E80),
        foregroundColor: Colors.black,
      ),
      body: carts.isEmpty
          ? const Center(
              child: Text("No carts yet. Tap ➕ below to add one!",
                  style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              itemCount: carts.length,
              itemBuilder: (_, index) => buildCartTile(index),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNewCart,
        label: const Text("Add Cart"),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: const Color(0xFFFF9E80),
        foregroundColor: Colors.black,
      ),
    );
  }
}
