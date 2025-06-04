import '../models/product.dart';
import '../models/api_product.dart';

class Cart {
  static final List<Map<String, dynamic>> _items = [];

  // Para productos locales
  static void add(Product product) {
    _items.add({
      'name': product.name,
      'description': product.description,
      'price': product.price,
    });
  }

  // ✅ Para productos desde la API
  static void addFromApi(ApiProduct product) {
    _items.add({
      'name': product.title,
      'description': product.description,
      'price': product.price,
    });
  }

  static List<Map<String, dynamic>> get items => _items;

  static void clear() => _items.clear();
}
