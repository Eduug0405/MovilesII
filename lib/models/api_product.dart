class ApiProduct {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;

  ApiProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
    );
  }
}
