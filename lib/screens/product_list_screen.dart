import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class ProductListScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProductListScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];
  List<dynamic> cart = [];
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      throw Exception('Fallo al cargar productos');
    }
  }

  void addToCart(product) {
    setState(() {
      cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product["title"]} agregado al carrito')),
    );
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? '';

    if (name.contains("Google")) {
   await authService.signOut();

    }

    await prefs.remove('token');
    await prefs.remove('name');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String username = widget.userData["name"] ?? "Usuario";

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $username 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => ListView(
                  children: cart.map((item) => ListTile(title: Text(item["title"]))).toList(),
                ),
              );
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(product["image"], width: 50, height: 50),
                    title: Text(product["title"]),
                    subtitle: Text("\$${product["price"]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => addToCart(product),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
