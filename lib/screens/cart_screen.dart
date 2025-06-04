import 'package:flutter/material.dart';
import '../cart/cart.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = Cart.items;
    final total = items.fold(0.0, (sum, item) => sum + item['price']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de Compras'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Cart.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Carrito vaciado')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(child: Text('El carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final product = items[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: ListTile(
                          title: Text(product['name']),
                          subtitle: Text(product['description']),
                          trailing: Text('\$${product['price'].toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }
}
                        