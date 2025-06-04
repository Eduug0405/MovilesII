import 'package:flutter/material.dart';
import '../models/api_product.dart';
import '../cart/cart.dart'; 

class ApiProductDetailScreen extends StatelessWidget {
  final ApiProduct product;

  const ApiProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.network(product.image, height: 180)),
            SizedBox(height: 16),
            Text(product.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              'Precio: \$${product.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Cart.addFromApi(product); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${product.title} agregado al carrito')),
                      );
                    },
                    child: Text('Agregar al carrito'),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Producto comprado exitosamente')),
                      );
                    },
                    child: Text('Comprar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
