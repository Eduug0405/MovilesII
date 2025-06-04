import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_product.dart';

class ApiService {
  static Future<List<ApiProduct>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => ApiProduct.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar productos desde la API');
    }
  }
}
