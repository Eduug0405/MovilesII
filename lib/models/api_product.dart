// lib/models/api_product.dart
class ApiProduct {
  final int id;
  final String title;
  final String description;
  final String category;
  final String image;
  final double price;
  final double rating;

  ApiProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
    required this.price,
    required this.rating,
  });

  factory ApiProduct.fromMap(Map<String, dynamic> map) {
    return ApiProduct(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      image: map['image'] as String,
      price: (map['price'] as num).toDouble(),
      rating: (map['rating']?['rate'] ?? 0).toDouble(),
    );
  }

  /// 👇 Alias para que `ApiService` compile:
  factory ApiProduct.fromJson(Map<String, dynamic> json) => ApiProduct.fromMap(json);
}
