// lib/screens/product_list_screen.dart
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_product.dart';             
import '../services/auth_service.dart';
import 'api_product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProductListScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final authService = AuthService();
  List<ApiProduct> products = [];           // 👉 list de objetos
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


  @override
  Widget build(BuildContext context) {
    final user = widget.userData['name'] ?? 'Usuario';
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text('Hola, $user ',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white)),
            const Icon(Icons.waving_hand, color: Colors.amber, size: 20),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded, color: Colors.pinkAccent),
            onPressed: _logout,
          ),
          IconButton(
            tooltip: 'Carrito (${cart.length})',
            icon:
                const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: _showCart,
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF1B1B2F), Color(0xFF15151F)],
                  radius: 1.2,
                ),
              ),
            ),
          ),
          products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.only(
                      top: kToolbarHeight + 16, bottom: 32),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => _ProductTile(
                    product: products[i],
                    onAdd: _addToCart,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ApiProductDetailScreen(product: products[i]),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showCart() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF26263C), Color(0xFF20202F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: cart
                .map((p) => ListTile(
                      leading: Image.network(p.image, width: 40),
                      title: Text(p.title,
                          style: const TextStyle(color: Colors.white70)),
                      trailing: Text('\$${p.price}',
                          style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

/* -- tile futurista ---------------------------------------------------- */
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: ListTile(
                leading: Image.network(product.image, width: 48),
                title: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '\$${product.price}',
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add_shopping_cart_rounded,
                      color: Colors.cyanAccent),
                  onPressed: () => onAdd(product),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
