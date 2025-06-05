// lib/screens/product_list_screen.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_product.dart';
import '../services/auth_service.dart';
import 'api_product_detail_screen.dart';

/* ==================== pantalla ==================== */
class ProductListScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProductListScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final authService = AuthService();
  List<ApiProduct> products = [];
  final List<ApiProduct> cart = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final resp = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (resp.statusCode == 200) {
      final List list = json.decode(resp.body);
      setState(() => products =
          list.map((e) => ApiProduct.fromMap(e as Map<String, dynamic>)).toList());
    } else {
      throw Exception('Failed to load products');
    }
  }

  void _addToCart(ApiProduct p) {
    setState(() => cart.add(p));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${p.title} añadido 🛒')));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString('name') ?? '').contains('Google')) {
      await authService.signOut();
    }
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  /* -------------------- UI -------------------- */
  @override
  Widget build(BuildContext context) {
    final user = widget.userData['name'] ?? 'Usuario';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9900), // Naranja Amazon
        title: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text('Hola, $user',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                tooltip: 'Carrito (${cart.length})',
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: _showCart,
              ),
              if (cart.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 6),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${cart.length}',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ProductTile(
                product: products[i],
                onAdd: _addToCart,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApiProductDetailScreen(product: products[i]),
                  ),
                ),
              ),
            ),
    );
  }

  /* ---------- modal carrito ---------- */
  void _showCart() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: cart
            .map((p) => ListTile(
                  leading: Image.network(p.image, width: 40),
                  title: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text('\$${p.price.toStringAsFixed(2)}'),
                  dense: true,
                ))
            .toList(),
      ),
    );
  }
}

/* ==================== tile estilo Amazon ==================== */
class _ProductTile extends StatelessWidget {
  final ApiProduct product;
  final void Function(ApiProduct) onAdd;
  final VoidCallback onTap;
  const _ProductTile({
    required this.product,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(product.image, width: 70, height: 70, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('\$${product.price}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB12704))), // rojo-precio Amazon
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_shopping_cart_rounded,
                    color: Color(0xFFFF9900)),
                onPressed: () => onAdd(product),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
